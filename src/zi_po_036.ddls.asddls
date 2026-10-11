@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Purchase Order'
define root view entity ZI_PO_036
  as select from zpo_hdr_036
  composition [0..*] of ZI_POITEM_036 as _Item
{
  key po_uuid                as PoUuid,
      po_number              as PoNumber,
      supplier_id            as SupplierId,
      supplier_name          as SupplierName,
      order_date             as OrderDate,
      currency_code          as CurrencyCode,
      @Semantics.amount.currencyCode: 'CurrencyCode'
      total_amount           as TotalAmount,
      po_status              as PoStatus,
      case po_status
        when 'A' then 3
        when 'R' then 1
        when 'S' then 2
        else 0
      end                    as PoStatusCriticality,
      @Semantics.user.createdBy: true
      local_created_by       as LocalCreatedBy,
      @Semantics.systemDateTime.createdAt: true
      local_created_at       as LocalCreatedAt,
      @Semantics.user.localInstanceLastChangedBy: true
      local_last_changed_by  as LocalLastChangedBy,
      @Semantics.systemDateTime.localInstanceLastChangedAt: true
      local_last_changed_at  as LocalLastChangedAt,
      @Semantics.systemDateTime.lastChangedAt: true
      last_changed_at        as LastChangedAt,
      _Item
}
