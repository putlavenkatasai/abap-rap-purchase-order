CLASS lhc_po DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.
    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR PO RESULT result.
    METHODS get_instance_features FOR INSTANCE FEATURES
      IMPORTING keys REQUEST requested_features FOR PO RESULT result.
    METHODS setInitialStatus FOR DETERMINE ON MODIFY
      IMPORTING keys FOR PO~setInitialStatus.
    METHODS setPoNumber FOR DETERMINE ON SAVE
      IMPORTING keys FOR PO~setPoNumber.
    METHODS validateSupplier FOR VALIDATE ON SAVE
      IMPORTING keys FOR PO~validateSupplier.
    METHODS submitPO FOR MODIFY
      IMPORTING keys FOR ACTION PO~submitPO RESULT result.
    METHODS approvePO FOR MODIFY
      IMPORTING keys FOR ACTION PO~approvePO RESULT result.
    METHODS rejectPO FOR MODIFY
      IMPORTING keys FOR ACTION PO~rejectPO RESULT result.
ENDCLASS.

CLASS lhc_po IMPLEMENTATION.

  METHOD get_instance_authorizations.
  ENDMETHOD.

  METHOD get_instance_features.
    READ ENTITIES OF zi_po_036 IN LOCAL MODE
      ENTITY PO FIELDS ( PoStatus ) WITH CORRESPONDING #( keys )
      RESULT DATA(pos).

    result = VALUE #( FOR po IN pos
      ( %tky = po-%tky
        %action-submitPO  = COND #( WHEN po-PoStatus = 'D'
                              THEN if_abap_behv=>fc-o-enabled
                              ELSE if_abap_behv=>fc-o-disabled )
        %action-approvePO = COND #( WHEN po-PoStatus = 'S'
                              THEN if_abap_behv=>fc-o-enabled
                              ELSE if_abap_behv=>fc-o-disabled )
        %action-rejectPO  = COND #( WHEN po-PoStatus = 'S'
                              THEN if_abap_behv=>fc-o-enabled
                              ELSE if_abap_behv=>fc-o-disabled ) ) ).
  ENDMETHOD.

  METHOD setInitialStatus.
    READ ENTITIES OF zi_po_036 IN LOCAL MODE
      ENTITY PO
      FIELDS ( PoStatus ) WITH CORRESPONDING #( keys )
      RESULT DATA(pos).

    DELETE pos WHERE PoStatus IS NOT INITIAL.
    CHECK pos IS NOT INITIAL.

    MODIFY ENTITIES OF zi_po_036 IN LOCAL MODE
      ENTITY PO
      UPDATE FIELDS ( PoStatus )
      WITH VALUE #( FOR po IN pos ( %tky = po-%tky PoStatus = 'D' ) ).
  ENDMETHOD.

  METHOD setPoNumber.
    READ ENTITIES OF zi_po_036 IN LOCAL MODE
      ENTITY PO
      FIELDS ( PoNumber ) WITH CORRESPONDING #( keys )
      RESULT DATA(pos).

    DELETE pos WHERE PoNumber IS NOT INITIAL.
    CHECK pos IS NOT INITIAL.

    SELECT MAX( po_number ) FROM zpo_hdr_036 INTO @DATA(max_number).
    IF max_number IS INITIAL.
      max_number = '4500000000'.
    ENDIF.

    LOOP AT pos INTO DATA(po).
      max_number = max_number + 1.
      MODIFY ENTITIES OF zi_po_036 IN LOCAL MODE
        ENTITY PO
        UPDATE FIELDS ( PoNumber )
        WITH VALUE #( ( %tky = po-%tky PoNumber = max_number ) ).
    ENDLOOP.
  ENDMETHOD.

  METHOD validateSupplier.
    READ ENTITIES OF zi_po_036 IN LOCAL MODE
      ENTITY PO
      FIELDS ( SupplierId ) WITH CORRESPONDING #( keys )
      RESULT DATA(pos).

    LOOP AT pos INTO DATA(po).
      APPEND VALUE #( %tky = po-%tky %state_area = 'VALIDATE_SUPPLIER' )
        TO reported-po.

      IF po-SupplierId IS INITIAL.
        APPEND VALUE #( %tky = po-%tky ) TO failed-po.
        APPEND VALUE #( %tky = po-%tky
                        %state_area = 'VALIDATE_SUPPLIER'
                        %msg = new_message_with_text(
                                 severity = if_abap_behv_message=>severity-error
                                 text     = 'Supplier ID is required' )
                        %element-SupplierId = if_abap_behv=>mk-on )
          TO reported-po.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD submitPO.
    MODIFY ENTITIES OF zi_po_036 IN LOCAL MODE
      ENTITY PO UPDATE FIELDS ( PoStatus )
      WITH VALUE #( FOR key IN keys ( %tky = key-%tky PoStatus = 'S' ) ).
    READ ENTITIES OF zi_po_036 IN LOCAL MODE
      ENTITY PO ALL FIELDS WITH CORRESPONDING #( keys ) RESULT DATA(pos).
    result = VALUE #( FOR po IN pos ( %tky = po-%tky %param = po ) ).
  ENDMETHOD.

  METHOD approvePO.
    MODIFY ENTITIES OF zi_po_036 IN LOCAL MODE
      ENTITY PO UPDATE FIELDS ( PoStatus )
      WITH VALUE #( FOR key IN keys ( %tky = key-%tky PoStatus = 'A' ) ).
    READ ENTITIES OF zi_po_036 IN LOCAL MODE
      ENTITY PO ALL FIELDS WITH CORRESPONDING #( keys ) RESULT DATA(pos).
    result = VALUE #( FOR po IN pos ( %tky = po-%tky %param = po ) ).
  ENDMETHOD.

  METHOD rejectPO.
    MODIFY ENTITIES OF zi_po_036 IN LOCAL MODE
      ENTITY PO UPDATE FIELDS ( PoStatus )
      WITH VALUE #( FOR key IN keys ( %tky = key-%tky PoStatus = 'R' ) ).
    READ ENTITIES OF zi_po_036 IN LOCAL MODE
      ENTITY PO ALL FIELDS WITH CORRESPONDING #( keys ) RESULT DATA(pos).
    result = VALUE #( FOR po IN pos ( %tky = po-%tky %param = po ) ).
  ENDMETHOD.

ENDCLASS.


CLASS lhc_item DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.
    METHODS calculateItemAmount FOR DETERMINE ON MODIFY
      IMPORTING keys FOR Item~calculateItemAmount.
    METHODS calculateTotal FOR DETERMINE ON MODIFY
      IMPORTING keys FOR Item~calculateTotal.
    METHODS validateQuantity FOR VALIDATE ON SAVE
      IMPORTING keys FOR Item~validateQuantity.
    METHODS validatePrice FOR VALIDATE ON SAVE
      IMPORTING keys FOR Item~validatePrice.
ENDCLASS.

CLASS lhc_item IMPLEMENTATION.

  METHOD calculateItemAmount.
    READ ENTITIES OF zi_po_036 IN LOCAL MODE
      ENTITY Item
      FIELDS ( Quantity UnitPrice ) WITH CORRESPONDING #( keys )
      RESULT DATA(items).

    MODIFY ENTITIES OF zi_po_036 IN LOCAL MODE
      ENTITY Item
      UPDATE FIELDS ( ItemAmount )
      WITH VALUE #( FOR item IN items
                    ( %tky       = item-%tky
                      ItemAmount = item-Quantity * item-UnitPrice ) ).
  ENDMETHOD.

  METHOD calculateTotal.
    READ ENTITIES OF zi_po_036 IN LOCAL MODE
      ENTITY Item BY \_PO
      FIELDS ( PoUuid ) WITH CORRESPONDING #( keys )
      RESULT DATA(pos).

    READ ENTITIES OF zi_po_036 IN LOCAL MODE
      ENTITY PO BY \_Item
      FIELDS ( ItemAmount ) WITH CORRESPONDING #( pos )
      RESULT DATA(items)
      LINK DATA(links).

    LOOP AT pos INTO DATA(po).
      DATA total TYPE zpo_hdr_036-total_amount.
      CLEAR total.

      LOOP AT links INTO DATA(link) WHERE source-%tky = po-%tky.
        READ TABLE items INTO DATA(item) WITH KEY %tky = link-target-%tky.
        IF sy-subrc = 0.
          total = total + item-ItemAmount.
        ENDIF.
      ENDLOOP.

      MODIFY ENTITIES OF zi_po_036 IN LOCAL MODE
        ENTITY PO
        UPDATE FIELDS ( TotalAmount )
        WITH VALUE #( ( %tky = po-%tky TotalAmount = total ) ).
    ENDLOOP.
  ENDMETHOD.

  METHOD validateQuantity.
    READ ENTITIES OF zi_po_036 IN LOCAL MODE
      ENTITY Item
      FIELDS ( Quantity ) WITH CORRESPONDING #( keys )
      RESULT DATA(items).

    LOOP AT items INTO DATA(item).
      APPEND VALUE #( %tky = item-%tky %state_area = 'VALIDATE_QUANTITY' )
        TO reported-item.

      IF item-Quantity <= 0.
        APPEND VALUE #( %tky = item-%tky ) TO failed-item.
        APPEND VALUE #( %tky = item-%tky
                        %state_area = 'VALIDATE_QUANTITY'
                        %msg = new_message_with_text(
                                 severity = if_abap_behv_message=>severity-error
                                 text     = 'Quantity must be greater than 0' )
                        %element-Quantity = if_abap_behv=>mk-on )
          TO reported-item.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD validatePrice.
    READ ENTITIES OF zi_po_036 IN LOCAL MODE
      ENTITY Item
      FIELDS ( UnitPrice ) WITH CORRESPONDING #( keys )
      RESULT DATA(items).

    LOOP AT items INTO DATA(item).
      APPEND VALUE #( %tky = item-%tky %state_area = 'VALIDATE_PRICE' )
        TO reported-item.

      IF item-UnitPrice <= 0.
        APPEND VALUE #( %tky = item-%tky ) TO failed-item.
        APPEND VALUE #( %tky = item-%tky
                        %state_area = 'VALIDATE_PRICE'
                        %msg = new_message_with_text(
                                 severity = if_abap_behv_message=>severity-error
                                 text     = 'Unit price must be greater than 0' )
                        %element-UnitPrice = if_abap_behv=>mk-on )
          TO reported-item.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.
