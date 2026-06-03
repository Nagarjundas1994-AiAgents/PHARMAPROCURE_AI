using {compharmaprocure as mydbschema} from '../db/schema';

@path: '/admin'
service AdminService @(requires: 'admin') {

    entity Vendors          as projection on mydbschema.Vendors;
    entity PurchaseOrders   as projection on mydbschema.PurchaseOrders;
    entity AILogs           as projection on mydbschema.AIRecommendationLog;
    entity Contracts        as projection on mydbschema.Contracts;
    entity Budgets          as projection on mydbschema.Budgets;

    action BlacklistVendor(vendorId: UUID, reason: String) returns Vendors;
    action ResetAIReview(poId: UUID) returns PurchaseOrders;
    action RecalculateAllRiskScores() returns { updated: Integer };
}