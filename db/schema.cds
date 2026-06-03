// db/schema.cds
namespace compharmaprocure;

// 1. Added POStatus and RiskLevel to the imports
using {
    Money,
    Email,
    PhoneNumber,
    POStatus,
    AgentDecision,
    RiskLevel
} from './types';

using {
    cuid,
    managed
} from '@sap/cds/common';

// ─────────────────────────────────────────────────
// 2. ADDED MISSING ASPECTS
// ─────────────────────────────────────────────────
aspect addressable {
    street  : String(100);
    city    : String(50);
    country : String(3); // ISO country code
    pincode : String(10);
}

aspect softDelete {
    isDeleted : Boolean default false;
    deletedAt : Timestamp;
    deletedBy : String;
}


// ─────────────────────────────────────────────────
// ENTITY: Vendors — master data
// ─────────────────────────────────────────────────
entity Vendors : cuid, managed, addressable {
    name           : String(100) not null;
    gstNumber      : String(15);
    email          : Email;
    phone          : PhoneNumber;
    riskLevel      : RiskLevel default 'LOW';
    riskScore      : Decimal(5, 2) default 0;
    isBlacklisted  : Boolean default false;
    licenseExpiry  : Date;

    purchaseOrders : Association to many PurchaseOrders
                         on purchaseOrders.vendor = $self;
    contracts      : Association to many Contracts
                         on contracts.vendor = $self;
}

// ─────────────────────────────────────────────────
// ENTITY: Products
// ─────────────────────────────────────────────────
entity Products : cuid, managed {
    name                  : String(200) not null;
    skuCode               : String(50) @unique;
    category              : String(50);
    unitOfMeasure         : String(10);
    unitPrice             : Money;
    stockQty              : Integer default 0;
    reorderPoint          : Integer default 10;
    requiresRefrigeration : Boolean default false;
    narcotic              : Boolean default false;
    hsnCode               : String(10);

    productGroup          : Association to ProductGroups;
}

entity ProductGroups : cuid {
    name            : String(100);
    requiresLicense : Boolean default false;
}

// ─────────────────────────────────────────────────
// ENTITY: Budgets
// ─────────────────────────────────────────────────
entity Budgets : cuid, managed {
    department      : String(100) not null;
    fiscalYear      : Integer not null;
    totalBudget     : Money not null;
    usedBudget      : Money default 0;

    availableBudget : Money = totalBudget - usedBudget;
}

// ─────────────────────────────────────────────────
// ENTITY: PurchaseOrders
// ─────────────────────────────────────────────────
// 3. FIXED THE COMMENT SYNTAX HERE
@odata.draft.enabled // ← Enables draft mode
entity PurchaseOrders : cuid, managed, softDelete {
    poNumber             : String(20) @Core.Computed;
    title                : String(200) not null;
    status               : POStatus default 'DRAFT';
    priority             : String enum {
        Low;
        Medium;
        High;
        Urgent
    } default 'Medium';

    totalAmount          : Money      @Core.Computed;
    currency             : String(3) default 'INR';
    department           : String(100);
    costCenter           : String(20);

    requiredByDate       : Date;
    expectedDelivery     : Date;

    vendor               : Association to Vendors;
    budget               : Association to Budgets;
    items                : Composition of many POItems
                               on items.po = $self;
    complianceCheck      : Composition of one ComplianceChecks
                               on complianceCheck.po = $self;

    aiRecommendation     : AgentDecision;
    aiConfidenceScore    : Decimal(5, 2);
    aiReasoningSummary   : LargeString;
    aiReviewedAt         : Timestamp;
    agentThreadId        : String(100);

    approvedBy           : String(100);
    approvedAt           : Timestamp;
    rejectedReason       : LargeString;

    virtual isUrgent     : Boolean;
    virtual budgetStatus : String;
}

// ─────────────────────────────────────────────────
// ENTITY: POItems
// ─────────────────────────────────────────────────
entity POItems : cuid {
    po             : Association to PurchaseOrders;
    lineNumber     : Integer;
    product        : Association to Products;
    description    : String(500);
    quantity       : Integer not null;
    unitPrice      : Money not null;
    discount       : Decimal(5, 2) default 0;
    taxRate        : Decimal(5, 2) default 18;

    subtotal       : Money = quantity * unitPrice;
    taxAmount      : Money = subtotal * (
        taxRate / 100
    );
    lineTotal      : Money = subtotal + taxAmount - (
        subtotal * discount / 100
    );

    requestedQty   : Integer;
    deliveredQty   : Integer default 0;
    deliveryStatus : String enum {
        Pending;
        PartialDelivery;
        Delivered
    };
}

// ─────────────────────────────────────────────────
// ENTITY: ComplianceChecks
// ─────────────────────────────────────────────────
entity ComplianceChecks : cuid, managed {
    po                   : Association to PurchaseOrders;
    narcoticsApproved    : Boolean default false;
    licenseVerified      : Boolean default false;
    coldChainConfirmed   : Boolean default false;
    serialNumberRequired : Boolean default false;
    regulatoryNotes      : LargeString;
    checkedBy            : String(100);
    checkedAt            : Timestamp;
    status               : String enum {
        Pending;
        Passed;
        Failed;
        NA
    } default 'Pending';
}

// ─────────────────────────────────────────────────
// 4. ADDED MISSING CONTRACTS ENTITY
// ─────────────────────────────────────────────────
entity Contracts : cuid, managed {
    vendor         : Association to Vendors;
    contractNumber : String(50) @unique;
    startDate      : Date;
    endDate        : Date;
    maxValue       : Money;
    currentSpend   : Money default 0;
    status         : String enum {
        Active;
        Expired;
        Terminated
    } default 'Active';
    terms          : LargeString;
}

// ─────────────────────────────────────────────────
// ENTITY: AIRecommendationLog
// ─────────────────────────────────────────────────
entity AIRecommendationLog : cuid, managed {
    po              : Association to PurchaseOrders;
    agentName       : String(50);
    decision        : AgentDecision;
    confidenceScore : Decimal(5, 2);
    reasoning       : LargeString;
    toolsUsed       : LargeString;
    tokensUsed      : Integer;
    latencyMs       : Integer;
}
