// db/types.cds
// ═══════════════════════════════════════════════════
// ALL CUSTOM TYPES & ENUMS
// ═══════════════════════════════════════════════════

// ─────────────────────────────────────────────────
// CUSTOM TYPES
// ─────────────────────────────────────────────────

type Money : Decimal(13,2);
type Email : String(100) @assert.format: '^[a-zA-Z0-9+_.-]+@[a-zA-Z0-9.-]+$';
type PhoneNumber : String(20);
type Percentage : Decimal(5,2) default 0;

// ─────────────────────────────────────────────────
// ENUMS
// ─────────────────────────────────────────────────

type OrderStatus : String enum {
    Draft      = 'DRAFT';
    Submitted  = 'SUBMITTED';
    Processing = 'PROCESSING';
    Shipped    = 'SHIPPED';
    Delivered  = 'DELIVERED';
    Cancelled  = 'CANCELLED';
}

type PaymentMethod : String enum {
    CreditCard   = 'CC';
    BankTransfer = 'BT';
    UPI          = 'UPI';
    Cash         = 'CASH';
}

type Priority : Integer enum {
    Low    = 1;
    Medium = 2;
    High   = 3;
    Urgent = 4;
}

type CustomerType : String enum {
    Individual = 'IND';
    Business   = 'BIZ';
    Government = 'GOV';
}

type POStatus : String enum {
    Draft      = 'DRAFT';
    Submitted  = 'SUBMITTED';
    AIReview   = 'AI_REVIEW';
    Approved   = 'APPROVED';
    Rejected   = 'REJECTED';
    Cancelled  = 'CANCELLED';
};

type RiskLevel : String enum {
    Low      = 'LOW';
    Medium   = 'MEDIUM';
    High     = 'HIGH';
    Critical = 'CRITICAL';
};

type AgentDecision : String enum {
    Approve      = 'APPROVE';
    Reject       = 'REJECT';
    ManualReview = 'MANUAL_REVIEW';
    NeedInfo     = 'NEED_INFO';
};