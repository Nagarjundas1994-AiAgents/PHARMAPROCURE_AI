using {compharmaprocure as mydbschema} from '../db/schema';


@path: '/procurement'
service ProcurementService @(requires: 'authenticated-user') {
    entity POs            as projection on mydbschema.PurchaseOrders
        actions {
            // BOUND ACTION: operates on ONE PO instance
            action ApprovePO(remarks: String)            returns POs;
            action RejectPO(reason: String not null)     returns POs;
            action RunAIReview()                         returns {
                decision        : String;
                confidenceScore : Decimal;
                summary         : String;
            };
            action SendBackForRevision(comments: String) returns POs;
        };


    @readonly
    entity VendorsList    as
        projection on mydbschema.Vendors
        excluding {
            riskScore,
            isBlacklisted
        };

    @readonly
    entity ProductCatalog as projection on mydbschema.Products;

    @readonly
    entity Contracts      as projection on mydbschema.Contracts;

    entity POItemsList    as projection on mydbschema.POItems;
    entity ComplianceView as projection on mydbschema.ComplianceChecks;


    /// UNBOUND ACTION: no specific PO instance needed
    action   BulkApprove(poIds: many UUID,remarks: String)          
    returns {
        approved : Integer;
        failed   : Integer;
        details  : LargeString;
    };

    // UNBOUND FUNCTION: read-only, like a custom GET
    function GetBudgetSummary(department: String,
                              fiscalYear: Integer) returns {
        totalBudget     : Decimal;
        usedBudget      : Decimal;
        availableBudget : Decimal;
        utilizationPct  : Decimal;
    };

    function GetVendorRiskScore(vendorId: UUID)    returns {
        score   : Decimal;
        level   : String;
        factors : LargeString;
    };

}
