const cds = require('@sap/cds');

module.exports = class ProcurementService extends cds.ApplicationService {

    async init() {
        const { POs, POItemsList, VendorsList } = this.entities;

        // ═══════════════════════════════════════════
        // BEFORE HANDLERS — Validation
        // ═══════════════════════════════════════════

        // Runs before EVERY create of a PO
        this.before('CREATE', POs, async (req) => {
            const data = req.data;

            // Rule 1: Title is required
            if (!data.title || data.title.trim() === '') {
                req.error(400, 'PO title cannot be empty');
                return;
            }

            // Rule 2: Must have at least one item
            if (!data.items || data.items.length === 0) {
                req.error(400, 'PO must have at least one item');
                return;
            }

            // Rule 3: Check if vendor is blacklisted
            if (data.vendor_ID) {
                const vendor = await SELECT.one.from('Vendors')
                    .where({ ID: data.vendor_ID });

                if (vendor?.isBlacklisted) {
                    req.error(409, `Vendor "${vendor.name}" is blacklisted.`);
                    return;
                }
            }

            // Rule 4: Auto-generate PO number before insert
            const count = await SELECT.one.from('PurchaseOrders')
                .columns('count(*) as total');
            data.poNumber = `PO-${new Date().getFullYear()}-${String(count.total + 1).padStart(5, '0')}`;
        });

        // Validate before UPDATE too
        this.before('UPDATE', POs, async (req) => {
            const { ID } = req.data;
            const existing = await SELECT.one.from('PurchaseOrders').where({ ID });

            // Can't edit an approved PO
            if (existing?.status === 'APPROVED') {
                req.error(409, 'Cannot modify an approved Purchase Order');
                return;
            }

            // Can't edit if AI review is in progress
            if (existing?.status === 'AI_REVIEW') {
                req.error(409, 'AI review is in progress. Please wait.');
            }
        });


        // Override READ to add virtual fields + hide soft-deleted
        this.on('READ', POs, async (req, next) => {
            // Modify the query to exclude soft-deleted records
            req.query.where({ isDeleted: false });

            // Let CAP do the actual database read (calling next!)
            const pos = await next();

            // After read, calculate virtual fields
            for (const po of Array.isArray(pos) ? pos : [pos]) {
                if (po) {
                    // Virtual: is this PO urgent?
                    po.isUrgent = po.priority === 'Urgent' ||
                        (po.requiredByDate &&
                            new Date(po.requiredByDate) < new Date(Date.now() + 3 * 24 * 60 * 60 * 1000));

                    // Virtual: budget status
                    po.budgetStatus = await this._checkBudgetStatus(po.totalAmount, po.department);
                }
            }

            return pos;
        });

        // ═══════════════════════════════════════════
        // ON: Custom Bound Action — ApprovePO
        // (no next() here — this IS the custom logic)
        // ═══════════════════════════════════════════

        this.on('ApprovePO', async (req) => {
            const { ID } = req.params[0];
            const { remarks } = req.data;

            // Step 1: Fetch current PO
            const po = await SELECT.one.from('PurchaseOrders')
                .where({ ID }).columns('*');

            if (!po) {
                req.error(404, `PO ${ID} not found`);
                return;
            }

            // Step 2: Can only approve if AI has reviewed
            if (po.status !== 'SUBMITTED' && po.status !== 'AI_REVIEW') {
                req.error(409, `PO must be in SUBMITTED status. Current: ${po.status}`);
                return;
            }

            // Step 3: Warn if AI said to reject (but allow human override)
            if (po.aiRecommendation === 'REJECT') {
                console.warn(`[WARNING] Approving PO ${po.poNumber} against AI recommendation`);
            }

            // Step 4: Update the PO status
            await UPDATE('PurchaseOrders')
                .set({
                    status: 'APPROVED',
                    approvedBy: req.user.id,
                    approvedAt: new Date()
                })
                .where({ ID });

            // Step 5: Update budget's usedBudget
            if (po.budget_ID) {
                await UPDATE('Budgets')
                    .set({ usedBudget: { '+=': po.totalAmount } })
                    .where({ ID: po.budget_ID });
            }

            // Step 6: Emit event so other services know
            await this.emit('POApproved', {
                poId: ID,
                poNumber: po.poNumber,
                approvedBy: req.user.id,
                amount: po.totalAmount,
                vendor: po.vendor_ID
            });

            // Step 7: Return updated PO
            return SELECT.one.from('PurchaseOrders').where({ ID });
        });


        this.on('RunAIReview', async (req) => {
            const { ID } = req.params[0];

            const po = await SELECT.one.from('PurchaseOrders').where({ ID });

            if (!po) {
                req.error(404, 'PO not found');
                return;
            }

            // Mark as AI_REVIEW immediately (real-time UI update via SideEffects)
            await UPDATE('PurchaseOrders')
                .set({ status: 'AI_REVIEW' })
                .where({ ID });

            // Call the orchestrator agent
            const { runPOOrchestrator } = require('../agents/orchestrator');

            const threadId = `po-review-${ID}-${Date.now()}`;
            const result = await runPOOrchestrator(po, threadId);

            // Save agent results back to PO
            await UPDATE('PurchaseOrders')
                .set({
                    aiRecommendation: result.decision,
                    aiConfidenceScore: result.confidenceScore,
                    aiReasoningSummary: result.summary,
                    aiReviewedAt: new Date(),
                    agentThreadId: threadId,
                    status: 'SUBMITTED'
                })
                .where({ ID });

            // Log to audit trail
            await INSERT.into('AIRecommendationLog').entries({
                po_ID: ID,
                agentName: 'Orchestrator',
                decision: result.decision,
                confidenceScore: result.confidenceScore,
                reasoning: result.summary,
                toolsUsed: JSON.stringify(result.toolsUsed),
                tokensUsed: result.tokensUsed,
                latencyMs: result.latencyMs
            });

            return {
                decision: result.decision,
                confidenceScore: result.confidenceScore,
                summary: result.summary
            };
        });


        // ═══════════════════════════════════════════
        // ON: Unbound Action — BulkApprove
        // ═══════════════════════════════════════════

        this.on('BulkApprove', async (req) => {
            const { poIds, remarks } = req.data;

            let approved = 0, failed = 0;
            const details = [];

            for (const poId of poIds) {
                try {
                    const fakePOReq = {
                        params: [{ ID: poId }],
                        data: { remarks },
                        user: req.user
                    };
                    await this.dispatch({ event: 'ApprovePO', ...fakePOReq });
                    approved++;
                    details.push({ id: poId, status: 'approved' });
                } catch (err) {
                    failed++;
                    details.push({ id: poId, status: 'failed', error: err.message });
                }
            }

            return { approved, failed, details: JSON.stringify(details) };
        });

        // ═══════════════════════════════════════════
        // ON: Unbound Function — GetBudgetSummary
        // Functions = Read only (GET), no side effects
        // ═══════════════════════════════════════════

        this.on('GetBudgetSummary', async (req) => {
            const { department, fiscalYear } = req.data;

            const budget = await SELECT.one.from('Budgets')
                .where({ department, fiscalYear });

            if (!budget) {
                return {
                    totalBudget: 0, usedBudget: 0,
                    availableBudget: 0, utilizationPct: 0
                };
            }

            return {
                totalBudget: budget.totalBudget,
                usedBudget: budget.usedBudget,
                availableBudget: budget.totalBudget - budget.usedBudget,
                utilizationPct: (budget.usedBudget / budget.totalBudget) * 100
            };
        });


        // ═══════════════════════════════════════════
        // AFTER HANDLER — Enrich READ response
        // AFTER handlers receive the RESULT, not the request
        // ═══════════════════════════════════════════

        this.after('READ', POs, (pos, req) => {
            const poList = Array.isArray(pos) ? pos : [pos];

            for (const po of poList) {
                if (!po) continue;

                // Add human-readable status label
                po.statusLabel = {
                    'DRAFT': '📝 Draft',
                    'SUBMITTED': '📤 Pending Review',
                    'AI_REVIEW': '🤖 AI Reviewing...',
                    'APPROVED': '✅ Approved',
                    'REJECTED': '❌ Rejected',
                    'CANCELLED': '🚫 Cancelled'
                }[po.status] || po.status;

                // Mask AI reasoning for non-managers
                if (!req.user.is('Manager') && !req.user.is('admin')) {
                    delete po.aiReasoningSummary;
                }
            }
        });


        // ═══════════════════════════════════════════
        // AFTER: Soft Delete Override
        // ═══════════════════════════════════════════

        this.on('DELETE', POs, async (req) => {
            const { ID } = req.data;

            // DON'T call next() — we never want real DELETE
            // Instead, soft-delete it
            await UPDATE('PurchaseOrders')
                .set({
                    isDeleted: true,
                    deletedAt: new Date(),
                    deletedBy: req.user.id
                })
                .where({ ID });

            // Emit event for downstream cleanup
            await this.emit('PODeleted', { poId: ID });
        });

        // ═══════════════════════════════════════════
        // MESSAGING: Listen for events from other services
        // ═══════════════════════════════════════════

        // const messaging = await cds.connect.to('messaging');

        // // When external vendor system confirms delivery
        // messaging.on('VendorDeliveryConfirmed', async (msg) => {
        //     const { poId, itemId, deliveredQty } = msg.data;

        //     await UPDATE('POItems')
        //         .set({ deliveredQty, deliveryStatus: 'Delivered' })
        //         .where({ ID: itemId, po_ID: poId });

        //     console.log(`Delivery confirmed for PO item ${itemId}`);
        // });

    }
}