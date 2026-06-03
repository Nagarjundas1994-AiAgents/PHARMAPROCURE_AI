using {compharmaprocure as mydbschema} from '../db/schema';
using {Money} from '../db/types';

@path: '/analytics'
service AnalyticsService @(requires: 'authenticated-user') {

    @readonly
    entity SpendByDepartment   as
        select from mydbschema.PurchaseOrders {
            department,
            sum(totalAmount) as totalSpend : Money,
            count( * )       as poCount    : Integer,
            avg(totalAmount) as avgPO      : Money
        }
        group by
            department;

    @readonly
    entity POsByStatus         as
        select from mydbschema.PurchaseOrders {
            status,
            count( * )       as count      : Integer,
            sum(totalAmount) as totalValue : Money
        }
        group by
            status;

    @readonly
    entity VendorSpendAnalysis as
        select from mydbschema.PurchaseOrders
        left join mydbschema.Vendors
            on PurchaseOrders.vendor.ID = Vendors.ID
        {
            Vendors.name                    as vendorName,
            Vendors.riskLevel,
            count(PurchaseOrders.ID)        as poCount    : Integer,
            sum(PurchaseOrders.totalAmount) as totalSpend : Money
        }
        group by
            Vendors.ID,
            Vendors.name,
            Vendors.riskLevel;
}
