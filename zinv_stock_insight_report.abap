*&---------------------------------------------------------------------*
*& Report ZINV_STOCK_INSIGHT_REPORT
*&---------------------------------------------------------------------*
*& Inventory Aging & Stock Insight Dashboard
*&---------------------------------------------------------------------*

REPORT zinv_stock_insight_report.

*---------------------------------------------------------------------*
* Type Definitions
*---------------------------------------------------------------------*
TYPES: BEGIN OF ty_stock,
         matnr TYPE mara-matnr,
         maktx TYPE makt-maktx,
         werks TYPE mard-werks,
         lgort TYPE mard-lgort,
         labst TYPE mard-labst,
         ersda TYPE mara-ersda,
         days_old TYPE i,
         category TYPE char20,
         color TYPE char4,
       END OF ty_stock.

*---------------------------------------------------------------------*
* Data
*---------------------------------------------------------------------*
DATA: gt_stock     TYPE TABLE OF ty_stock,
      gt_fieldcat  TYPE slis_t_fieldcat_alv,
      gt_sort      TYPE slis_t_sortinfo_alv,
      gs_layout    TYPE slis_layout_alv,
      gs_variant   TYPE disvariant,
      gt_events    TYPE slis_t_event,
      gv_repid     TYPE sy-repid.

*---------------------------------------------------------------------*
* Selection Screen
*---------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE TEXT-001.
  SELECT-OPTIONS:
    s_matnr FOR mara-matnr,
    s_werks FOR mard-werks.
SELECTION-SCREEN END OF BLOCK b1.

SELECTION-SCREEN BEGIN OF BLOCK b2 WITH FRAME TITLE TEXT-002.
  PARAMETERS: p_var TYPE disvariant-variant.
SELECTION-SCREEN END OF BLOCK b2.

INITIALIZATION.
  gv_repid = sy-repid.
  TEXT-001 = 'Inventory Filters'.
  TEXT-002 = 'Display Options'.

*---------------------------------------------------------------------*
* F4 Variant Help
*---------------------------------------------------------------------*
AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_var.
  PERFORM f4_variant.

*---------------------------------------------------------------------*
* Start
*---------------------------------------------------------------------*
START-OF-SELECTION.
  PERFORM fetch_data.
  PERFORM process_data.
  PERFORM display_alv.

*---------------------------------------------------------------------*
* Fetch Data
*---------------------------------------------------------------------*
FORM fetch_data.

  SELECT mara~matnr
         makt~maktx
         mard~werks
         mard~lgort
         mard~labst
         mara~ersda
    INTO CORRESPONDING FIELDS OF TABLE gt_stock
    FROM mara
    INNER JOIN mard ON mara~matnr = mard~matnr
    LEFT JOIN makt ON mara~matnr = makt~matnr
                    AND makt~spras = sy-langu
    WHERE mara~matnr IN s_matnr
      AND mard~werks IN s_werks.

  IF sy-subrc = 0.
    MESSAGE 'Data fetched successfully' TYPE 'I'.
  ELSE.
    MESSAGE 'No data found' TYPE 'E'.
  ENDIF.

ENDFORM.

*---------------------------------------------------------------------*
* Process Data
*---------------------------------------------------------------------*
FORM process_data.

  FIELD-SYMBOLS: <fs> TYPE ty_stock.

  LOOP AT gt_stock ASSIGNING <fs>.

    <fs>-days_old = sy-datum - <fs>-ersda.

    IF <fs>-labst = 0.
      <fs>-category = 'Out of Stock'.
      <fs>-color = 'C610'.
    ELSEIF <fs>-days_old > 365.
      <fs>-category = 'Dead Stock'.
      <fs>-color = 'C620'.
    ELSEIF <fs>-days_old > 180.
      <fs>-category = 'Slow Moving'.
      <fs>-color = 'C310'.
    ELSEIF <fs>-days_old > 60.
      <fs>-category = 'Normal'.
      <fs>-color = 'C510'.
    ELSE.
      <fs>-category = 'Fast Moving'.
      <fs>-color = 'C410'.
    ENDIF.

  ENDLOOP.

ENDFORM.

*---------------------------------------------------------------------*
* Display ALV
*---------------------------------------------------------------------*
FORM display_alv.

  PERFORM build_fieldcat.
  PERFORM build_layout.
  PERFORM build_sort.
  PERFORM build_events.

  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
    EXPORTING
      i_callback_program       = gv_repid
      i_callback_user_command  = 'USER_COMMAND'
      i_callback_top_of_page   = 'TOP_OF_PAGE'
      is_layout                = gs_layout
      it_fieldcat              = gt_fieldcat
      it_sort                  = gt_sort
      it_events                = gt_events
      is_variant               = gs_variant
      i_save                   = 'A'
    TABLES
      t_outtab                 = gt_stock.

ENDFORM.

*---------------------------------------------------------------------*
* Field Catalog
*---------------------------------------------------------------------*
FORM build_fieldcat.

  DATA ls TYPE slis_fieldcat_alv.
  CLEAR gt_fieldcat.

  DEFINE add.
    CLEAR ls.
    ls-fieldname = &1.
    ls-seltext_m = &2.
    ls-col_pos = &3.
    ls-outputlen = &4.
    APPEND ls TO gt_fieldcat.
  END-OF-DEFINITION.

  add 'MATNR' 'Material' 1 18.
  add 'MAKTX' 'Description' 2 30.
  add 'WERKS' 'Plant' 3 6.
  add 'LGORT' 'Storage' 4 6.
  add 'LABST' 'Stock' 5 15.
  add 'ERSDA' 'Created On' 6 10.
  add 'DAYS_OLD' 'Days Old' 7 6.
  add 'CATEGORY' 'Category' 8 20.

ENDFORM.

*---------------------------------------------------------------------*
* Layout
*---------------------------------------------------------------------*
FORM build_layout.

  gs_layout-zebra = 'X'.
  gs_layout-colwidth_optimize = 'X'.
  gs_layout-info_fieldname = 'COLOR'.

  gs_variant-report = gv_repid.
  gs_variant-variant = p_var.

ENDFORM.

*---------------------------------------------------------------------*
* Sort
*---------------------------------------------------------------------*
FORM build_sort.

  DATA ls TYPE slis_sortinfo_alv.
  CLEAR gt_sort.

  ls-fieldname = 'WERKS'.
  ls-up = 'X'.
  ls-subtot = 'X'.
  APPEND ls TO gt_sort.

ENDFORM.

*---------------------------------------------------------------------*
* Events
*---------------------------------------------------------------------*
FORM build_events.

  CALL FUNCTION 'REUSE_ALV_EVENTS_GET'
    EXPORTING i_list_type = 0
    IMPORTING et_events = gt_events.

ENDFORM.

*---------------------------------------------------------------------*
* F4 Variant
*---------------------------------------------------------------------*
FORM f4_variant.

  DATA ls TYPE disvariant.
  ls-report = gv_repid.

  CALL FUNCTION 'REUSE_ALV_VARIANT_F4'
    EXPORTING is_variant = ls i_save = 'A'
    IMPORTING es_variant = ls.

  p_var = ls-variant.

ENDFORM.

*---------------------------------------------------------------------*
* User Command
*---------------------------------------------------------------------*
FORM user_command USING r_ucomm LIKE sy-ucomm
                        rs_selfield TYPE slis_selfield.

  IF r_ucomm = '&IC1'.
    IF rs_selfield-fieldname = 'MATNR'.
      SET PARAMETER ID 'MAT' FIELD rs_selfield-value.
      CALL TRANSACTION 'MM03' AND SKIP FIRST SCREEN.
    ENDIF.
  ENDIF.

ENDFORM.

*---------------------------------------------------------------------*
* Top of Page
*---------------------------------------------------------------------*
FORM top_of_page.

  DATA: lt TYPE slis_t_listheader,
        ls TYPE slis_listheader.

  ls-typ = 'H'.
  ls-info = 'Inventory Aging Dashboard'.
  APPEND ls TO lt.

  CALL FUNCTION 'REUSE_ALV_COMMENTARY_WRITE'
    EXPORTING it_list_commentary = lt.

ENDFORM.
