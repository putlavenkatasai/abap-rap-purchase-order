@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'PO Item'
define view entity ZI_POITEM_036
  as select from zpo_item_036
  association to parent ZI_PO_036 as _PO
    on $projection.PoUuid = _PO.PoUuid
{
  key item_uuid         as ItemUuid,
      po_uuid           as PoUuid,
      item_no           as ItemNo,
      material_desc     as MaterialDesc,
      quantity          as Quantity,
      unit              as Unit,
      currency_code     as CurrencyCode,
      @Semantics.amount.currencyCode: 'CurrencyCode'
      unit_price        as UnitPrice,
      @Semantics.amount.currencyCode: 'CurrencyCode'
      item_amount       as ItemAmount,
      local_last_changed_at as LocalLastChangedAt,
      _PO
}
