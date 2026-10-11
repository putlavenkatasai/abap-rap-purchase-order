# Purchase Order Management (ABAP RAP, ABAP Cloud)

A Fiori Elements app built with the ABAP RESTful Application Programming Model (RAP) on SAP BTP ABAP Environment. A user creates a purchase order header with several item lines. The total is calculated automatically, input is validated, and the PO moves through Submit / Approve / Reject.

## Features
- Managed RAP business object with **draft**, header → item **composition**
- **Determinations**: initial status, PO number, item amount (Quantity × Unit Price), PO total
- **Validations**: supplier, quantity > 0, unit price > 0
- **Actions**: Submit, Approve, Reject, with instance feature control
- **Side effects**: item changes refresh item amount and header total
- Fiori Elements list report and object page (metadata extensions), status criticality colours
- OData V4 UI service

## Object overview (suffix `_036`, package `ZPO_MGMT_036`)
| Type | Objects |
|---|---|
| Tables | `ZPO_HDR_036`, `ZPO_ITEM_036` (plus draft tables) |
| CDS interface views | `ZI_PO_036`, `ZI_POITEM_036` |
| CDS projection views | `ZC_PO_036`, `ZC_POITEM_036` |
| Metadata extensions | `ZC_PO_036`, `ZC_POITEM_036` |
| Behavior definitions | `ZI_PO_036` (managed, draft), `ZC_PO_036` (projection) |
| Behavior class | `ZBP_I_PO_036` |
| Service | `ZUI_PO_036` (definition), OData V4 UI binding |

## Screenshots
![PO List](images/list.png)

![PO Object Page](images/object-page.png)

![Items](images/items.png)

## How to use
1. Import this repository into your BTP ABAP Environment with abapGit (ADT).
2. Activate all objects.
3. Publish the service binding and open the PO entity preview.

## Tech
ABAP Cloud, RAP, CDS view entities, Fiori Elements, abapGit.
