"! <p class="shorttext synchronized" lang="en">abapGit User Exits</p>
CLASS zcl_abapgit_user_exit DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.

    INTERFACES zif_abapgit_exit ALL METHODS FINAL.

  PROTECTED SECTION.

  PRIVATE SECTION.

    TYPES:
      BEGIN OF ty_method_block,
        name   TYPE string,
        source TYPE zif_abapgit_definitions=>ty_string_tt,
      END OF ty_method_block,
      ty_method_blocks TYPE SORTED TABLE OF ty_method_block WITH UNIQUE KEY name.

    METHODS normalize_implementation_line
      IMPORTING
        iv_clsname       TYPE abap_classname
        it_source        TYPE zif_abapgit_definitions=>ty_string_tt
      RETURNING
        VALUE(rt_source) TYPE zif_abapgit_definitions=>ty_string_tt.

    METHODS sort_method_implementations
      IMPORTING
        it_source        TYPE zif_abapgit_definitions=>ty_string_tt
      RETURNING
        VALUE(rt_source) TYPE zif_abapgit_definitions=>ty_string_tt.

ENDCLASS.



CLASS zcl_abapgit_user_exit IMPLEMENTATION.


  METHOD zif_abapgit_exit~adjust_display_commit_url.
  ENDMETHOD.


  METHOD zif_abapgit_exit~adjust_display_filename.
  ENDMETHOD.


  METHOD zif_abapgit_exit~allow_sap_objects.

    RETURN abap_true.

  ENDMETHOD.


  METHOD zif_abapgit_exit~change_committer_info.
  ENDMETHOD.


  METHOD zif_abapgit_exit~change_local_host.
  ENDMETHOD.


  METHOD zif_abapgit_exit~change_max_parallel_processes.

    cv_max_processes *= EXACT decfloat16( '1.5' ).

  ENDMETHOD.


  METHOD zif_abapgit_exit~change_proxy_authentication.
  ENDMETHOD.


  METHOD zif_abapgit_exit~change_proxy_port.
  ENDMETHOD.


  METHOD zif_abapgit_exit~change_proxy_url.
  ENDMETHOD.


  METHOD zif_abapgit_exit~change_rfc_server_group.
  ENDMETHOD.


  METHOD zif_abapgit_exit~change_supported_data_objects.
  ENDMETHOD.


  METHOD zif_abapgit_exit~change_supported_object_types.
  ENDMETHOD.


  METHOD zif_abapgit_exit~change_tadir.
  ENDMETHOD.


  METHOD zif_abapgit_exit~create_http_client.
  ENDMETHOD.


  METHOD zif_abapgit_exit~custom_serialize_abap_clif.

*    " 1st call has no source: abapGit serializes as usual. 2nd call gets the
*    " serialized source. SAP may return it differently on each system (e.g.
*    " after a transport): the class name case and blank lines around
*    " CLASS ... IMPLEMENTATION, and the method order. Normalize it to keep
*    " files comparable. abapGit's own classes stay as they are to match upstream.
*    IF it_source IS INITIAL
*    OR is_class_key-clsname CP 'ZCL_ABAPGIT*'
*    OR is_class_key-clsname CP 'ZCX_ABAPGIT*'.
*      RETURN.
*    ENDIF.
*
*    rt_source = sort_method_implementations(
*      normalize_implementation_line( iv_clsname = is_class_key-clsname
*                                     it_source  = it_source ) ).

  ENDMETHOD.


  METHOD zif_abapgit_exit~deserialize_postprocess.
  ENDMETHOD.


  METHOD zif_abapgit_exit~determine_transport_request.
  ENDMETHOD.


  METHOD zif_abapgit_exit~enhance_any_toolbar.
  ENDMETHOD.


  METHOD zif_abapgit_exit~enhance_repo_toolbar.
  ENDMETHOD.


  METHOD zif_abapgit_exit~get_ci_tests.
  ENDMETHOD.


  METHOD zif_abapgit_exit~get_ssl_id.
  ENDMETHOD.


  METHOD zif_abapgit_exit~http_client.
  ENDMETHOD.


  METHOD zif_abapgit_exit~on_event.
  ENDMETHOD.


  METHOD zif_abapgit_exit~pre_calculate_repo_status.
  ENDMETHOD.


  METHOD zif_abapgit_exit~serialize_postprocess.
  ENDMETHOD.


  METHOD zif_abapgit_exit~validate_before_push.
  ENDMETHOD.


  METHOD zif_abapgit_exit~wall_message_list.
  ENDMETHOD.


  METHOD zif_abapgit_exit~wall_message_repo.

    CHECK is_repo_meta-dot_abapgit-version_constant IS NOT INITIAL.

    SPLIT is_repo_meta-dot_abapgit-version_constant
       AT '=>' INTO TABLE FINAL(lt_vers_const).
    CHECK lines( lt_vers_const ) = 2.

    SELECT SINGLE FROM vseoattrib
      FIELDS attvalue
      WHERE clsname    = @( lt_vers_const[ 1 ] )
        AND cmpname    = @( lt_vers_const[ 2 ] )
        AND version    = '1'  " => Active
        AND attdecltyp = '2'  " => Constant
      INTO @DATA(lv_vers_const).
    lv_vers_const = translate( val  = lv_vers_const
                               from = `'`
                               to   = space ).
    CHECK lv_vers_const IS NOT INITIAL.

    ii_html->add( |<hr/>| ).
    ii_html->add( |<span>| ).
    ii_html->add_icon( 'info-circle-solid/blue' ).
    ii_html->add( |Currently installed version: { lv_vers_const }| ).
    ii_html->add( |</span>| ).
    ii_html->add( |<hr/>| ).

  ENDMETHOD.


  METHOD zif_abapgit_exit~validate_after_push.
  ENDMETHOD.


  METHOD zif_abapgit_exit~change_password_popup_username.
  ENDMETHOD.


  METHOD zif_abapgit_exit~adjust_commit_message.
  ENDMETHOD.


  METHOD zif_abapgit_exit~enable_adjust_commit_message.
  ENDMETHOD.


  METHOD zif_abapgit_exit~post_pull.
  ENDMETHOD.


  METHOD normalize_implementation_line.

    " Always "CLASS z_class_name IMPLEMENTATION.", with exactly 3 blank lines
    " after the ENDCLASS of the definition

    DATA lv_impl_line TYPE i.

    FINAL(lv_implementation) = |CLASS { to_lower( iv_clsname ) } IMPLEMENTATION.|.
    DATA(lt_source) = it_source.
    REPLACE FIRST OCCURRENCE OF PCRE `^\s*CLASS\s+\S+\s+IMPLEMENTATION\s*\.`
      IN TABLE lt_source WITH lv_implementation IGNORING CASE
      REPLACEMENT LINE lv_impl_line.
    IF sy-subrc <> 0.
      RETURN it_source. " interface
    ENDIF.

    DATA(lv_definition_end) = 0.
    DATA(lv_last_statement) = ``.
    LOOP AT lt_source INTO DATA(lv_line) TO lv_impl_line - 1.
      IF NOT matches( val = lv_line pcre = `\s*` ).
        lv_definition_end = sy-tabix.
        lv_last_statement = lv_line.
      ENDIF.
    ENDLOOP.
    IF NOT matches( val  = lv_last_statement
                    pcre = `\s*ENDCLASS\s*\..*`
                    case = abap_false ).
      RETURN lt_source. " not only blank lines in between
    ENDIF.

    rt_source = VALUE #( ( LINES OF lt_source TO lv_definition_end )
                         ( `` )
                         ( `` )
                         ( `` )
                         ( LINES OF lt_source FROM lv_impl_line ) ).

  ENDMETHOD.


  METHOD sort_method_implementations.

    " Line-based on purpose: in the source SAP returns, METHOD and ENDMETHOD
    " start their own lines. Anything that doesn't fit is returned unchanged.

    DATA lt_blocks TYPE ty_method_blocks.
    DATA ls_block  TYPE ty_method_block.

    rt_source = it_source.

    " The implementation part runs from CLASS ... IMPLEMENTATION to the last ENDCLASS
    DATA(lv_impl_from) = 0.
    DATA(lv_impl_to) = 0.
    LOOP AT it_source INTO DATA(lv_line).
      IF lv_impl_from = 0.
        IF matches( val  = lv_line
                    pcre = `\s*CLASS\s+\S+\s+IMPLEMENTATION\s*\..*`
                    case = abap_false ).
          lv_impl_from = sy-tabix.
        ENDIF.
      ELSEIF matches( val  = lv_line
                      pcre = `\s*ENDCLASS\s*\..*`
                      case = abap_false ).
        lv_impl_to = sy-tabix.
      ENDIF.
    ENDLOOP.
    IF lv_impl_to = 0.
      RETURN. " interface
    ENDIF.

    " Cut the implementation part into one block per method
    LOOP AT it_source INTO lv_line FROM lv_impl_from + 1 TO lv_impl_to - 1.
      IF matches( val = lv_line pcre = `\s*` ).
        IF ls_block-source IS NOT INITIAL.
          APPEND lv_line TO ls_block-source.
        ENDIF.
        CONTINUE. " blank lines between methods are added again below
      ENDIF.

      APPEND lv_line TO ls_block-source.
      IF matches( val = lv_line pcre = `\*.*|\s*".*` ).
        CONTINUE. " comments above a METHOD statement stay with that method
      ENDIF.

      IF ls_block-name IS INITIAL.
        FIND PCRE `^\s*METHOD\s+([^\s.]+)` IN lv_line
          IGNORING CASE SUBMATCHES ls_block-name.
        IF sy-subrc <> 0.
          RETURN. " code outside a method
        ENDIF.
        ls_block-name = to_upper( ls_block-name ).
      ENDIF.

      IF matches( val  = lv_line
                  pcre = `(.*\.)?\s*ENDMETHOD\s*\.\s*(".*)?`
                  case = abap_false ).
        INSERT ls_block INTO TABLE lt_blocks.
        IF sy-subrc <> 0.
          RETURN. " same method twice
        ENDIF.
        CLEAR ls_block.
      ENDIF.
    ENDLOOP.
    IF lt_blocks IS INITIAL OR ls_block-name IS NOT INITIAL.
      RETURN. " no methods, or the last one isn't closed
    ENDIF.

    " Same layout as abapGit's own output: two blank lines before each method,
    " ENDCLASS right after the last one. Comments left over in ls_block stay
    " at the end.
    rt_source = VALUE #( ( LINES OF it_source TO lv_impl_from ) ).
    LOOP AT lt_blocks ASSIGNING FIELD-SYMBOL(<ls_block>).
      APPEND INITIAL LINE TO rt_source.
      APPEND INITIAL LINE TO rt_source.
      APPEND LINES OF <ls_block>-source TO rt_source.
    ENDLOOP.
    IF ls_block-source IS NOT INITIAL.
      APPEND INITIAL LINE TO rt_source.
      APPEND INITIAL LINE TO rt_source.
      APPEND LINES OF ls_block-source TO rt_source.
    ENDIF.
    APPEND LINES OF it_source FROM lv_impl_to TO rt_source.

  ENDMETHOD.


  METHOD zif_abapgit_exit~validate_before_pull.
  ENDMETHOD.


ENDCLASS.
