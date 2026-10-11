@EndUserText.label: 'Purchase Order Projection'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@Metadata.allowExtensions: true
define root view entity ZC_PO_036
  provider contract transactional_query
  as projection on ZI_PO_036
{
  key PoUuid,
      @EndUserText.label: 'PO Number'
      PoNumber,
      @EndUserText.label: 'Supplier ID'
      SupplierId,
      @EndUserText.label: 'Supplier Name'
      SupplierName,
      @EndUserText.label: 'Order Date'
      OrderDate,
      @EndUserText.label: 'Currency'
      CurrencyCode,
      @EndUserText.label: 'Total Amount'
      TotalAmount,
      @EndUserText.label: 'Status'
      PoStatus,
      PoStatusCriticality,
      LocalLastChangedAt,
      LastChangedAt,
      _Item : redirected to composition child ZC_POITEM_036
}
