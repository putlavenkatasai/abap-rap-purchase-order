@EndUserText.label: 'PO Item Projection'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@Metadata.allowExtensions: true
define view entity ZC_POITEM_036
  as projection on ZI_POITEM_036
{
  key ItemUuid,
      PoUuid,
      @EndUserText.label: 'Item No'
      ItemNo,
      @EndUserText.label: 'Material Description'
      MaterialDesc,
      @EndUserText.label: 'Quantity'
      Quantity,
      @EndUserText.label: 'Unit'
      Unit,
      @EndUserText.label: 'Currency'
      CurrencyCode,
      @EndUserText.label: 'Unit Price'
      UnitPrice,
      @EndUserText.label: 'Item Amount'
      ItemAmount,
      LocalLastChangedAt,
      _PO : redirected to parent ZC_PO_036
}
