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
* Data Declarations
*---------------------------------------------------------------------*
DATA:
  gt_stock     TYPE TABLE OF ty_stock,
  gt_fieldcat  TYPE slis_t_fieldcat_alv,
  gt_sort      TYPE slis_t_sortinfo_alv,
  gs_layout    TYPE slis_layout_alv,
  gt_events    TYPE slis_t_event,
  gv_repid     TYPE sy-repid.

*---------------------------------------------------------------------*
* Selection Screen
*---------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE text-001.
SELECT-OPTIONS:
  s_matnr FOR mara-matnr,
  s_werks FOR mard-werks.
SELECTION-SCREEN END OF BLOCK b1.

INITIALIZATION.
  gv_repid = sy-repid.
  text-001 = 'Inventory Selection'.

*---------------------------------------------------------------------*
* Start-of-Selection
*---------------------------------------------------------------------*
START-OF-SELECTION.
  PERFORM fetch_data.
  PERFORM process_data.
  PERFORM display_alv.

*---------------------------------------------------------------------*
* Fetch Data (JOIN)
*---------------------------------------------------------------------*
FORM fetch_data.

  SELECT mara~matnr makt~maktx
         mard~werks mard~lgort mard~labst
         mara~ersda
    INTO CORRESPONDING FIELDS OF TABLE gt_stock
    FROM mara
    INNER JOIN mard ON mara~matnr = mard~matnr
    LEFT JOIN makt ON mara~matnr = makt~matnr
                    AND makt~spras = sy-langu
    WHERE mara~matnr IN s_matnr
      AND mard~werks IN s_werks.

  IF sy-subrc <> 0.
    MESSAGE 'No data found' TYPE 'E'.
  ENDIF.

ENDFORM.

*---------------------------------------------------------------------*
* Process Data (Business Logic)
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
* Build Field Catalog
*---------------------------------------------------------------------*
FORM build_fieldcat.

  DATA ls TYPE slis_fieldcat_alv.
  CLEAR gt_fieldcat.

  DEFINE add_field.
    CLEAR ls.
    ls-fieldname = &1.
    ls-seltext_m = &2.
    ls-col_pos = &3.
    ls-outputlen = &4.
    APPEND ls TO gt_fieldcat.
  END-OF-DEFINITION.

  add_field 'MATNR' 'Material' 1 18.
  add_field 'MAKTX' 'Description' 2 30.
  add_field 'WERKS' 'Plant' 3 6.
  add_field 'LGORT' 'Storage' 4 6.
  add_field 'LABST' 'Stock' 5 15.
  add_field 'ERSDA' 'Created On' 6 10.
  add_field 'DAYS_OLD' 'Days Old' 7 6.
  add_field 'CATEGORY' 'Category' 8 15.

ENDFORM.

*---------------------------------------------------------------------*
* Build Layout
*---------------------------------------------------------------------*
FORM build_layout.

  gs_layout-zebra = 'X'.
  gs_layout-colwidth_optimize = 'X'.
  gs_layout-info_fieldname = 'COLOR'.

ENDFORM.

*---------------------------------------------------------------------*
* Build Sort
*---------------------------------------------------------------------*
FORM build_sort.

  DATA ls_sort TYPE slis_sortinfo_alv.

  CLEAR gt_sort.

  ls_sort-fieldname = 'WERKS'.
  ls_sort-up = 'X'.
  ls_sort-subtot = 'X'.
  APPEND ls_sort TO gt_sort.

ENDFORM.

*---------------------------------------------------------------------*
* Build Events
*---------------------------------------------------------------------*
FORM build_events.

  CALL FUNCTION 'REUSE_ALV_EVENTS_GET'
    EXPORTING
      i_list_type = 0
    IMPORTING
      et_events = gt_events.

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
      i_callback_program = gv_repid
      i_callback_top_of_page = 'TOP_OF_PAGE'
      is_layout = gs_layout
      it_fieldcat = gt_fieldcat
      it_sort = gt_sort
      it_events = gt_events
    TABLES
      t_outtab = gt_stock.

ENDFORM.

*---------------------------------------------------------------------*
* Top of Page
*---------------------------------------------------------------------*
FORM top_of_page.

  DATA: lt_header TYPE slis_t_listheader,
        ls_header TYPE slis_listheader.

  CLEAR ls_header.
  ls_header-typ = 'H'.
  ls_header-info = 'Inventory Aging Dashboard'.
  APPEND ls_header TO lt_header.

  CLEAR ls_header.
  ls_header-typ = 'S'.
  ls_header-key = 'Date:'.
  WRITE sy-datum TO ls_header-info.
  APPEND ls_header TO lt_header.

  CALL FUNCTION 'REUSE_ALV_COMMENTARY_WRITE'
    EXPORTING it_list_commentary = lt_header.

ENDFORM.

*---------------------------------------------------------------------*
* User Command (Interaction)
*---------------------------------------------------------------------*
FORM user_command USING r_ucomm LIKE sy-ucomm
                        rs_selfield TYPE slis_selfield.

  CASE r_ucomm.
    WHEN '&IC1'.
      IF rs_selfield-fieldname = 'MATNR'.
        SET PARAMETER ID 'MAT' FIELD rs_selfield-value.
        CALL TRANSACTION 'MM03' AND SKIP FIRST SCREEN.
      ENDIF.
  ENDCASE.

ENDFORM.