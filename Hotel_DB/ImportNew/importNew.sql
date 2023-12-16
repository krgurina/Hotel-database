SELECT OBJECT_NAME, PROCEDURE_NAME
FROM ALL_PROCEDURES
WHERE OBJECT_TYPE = 'PROCEDURE' and owner = 'ADMIN'
ORDER BY OBJECT_NAME, PROCEDURE_NAME;

--DROP PROCEDURE SHOWALLGUESTS        ;

-- это работает
create or replace PROCEDURE EXPORT_TO_FILE(
    p_query IN NVARCHAR2,
    p_filename IN NVARCHAR2
)AS
    v_clob NCLOB;
    v_file UTL_FILE.FILE_TYPE;
BEGIN
    SELECT DBMS_XMLGEN.GETXML(p_query) INTO v_clob FROM DUAL;
    v_file := UTL_FILE.FOPEN('XML_DIR', p_filename || '.xml', 'w');
    BEGIN
        UTL_FILE.PUT(v_file, v_clob);
    EXCEPTION
        WHEN UTL_FILE.WRITE_ERROR THEN
            DBMS_OUTPUT.PUT_LINE('Error writing to file');
    END;
    UTL_FILE.FCLOSE(v_file);
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('Query returned no data');
    WHEN UTL_FILE.INVALID_PATH THEN
        DBMS_OUTPUT.PUT_LINE('Invalid path for directory');
    WHEN UTL_FILE.INVALID_MODE THEN
        DBMS_OUTPUT.PUT_LINE('Invalid file mode');
    WHEN UTL_FILE.INVALID_FILEHANDLE THEN
        DBMS_OUTPUT.PUT_LINE('Invalid file handle');
    WHEN UTL_FILE.INVALID_OPERATION THEN
        DBMS_OUTPUT.PUT_LINE('Invalid file operation');
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Unknown error: ' || SQLERRM);
END;

begin
    EXPORT_TO_FILE('select * from guests', 'rakadabra');
end;


--- импорт
CREATE OR REPLACE PROCEDURE import_data_xml(p_file IN NVARCHAR2) AS
  v_xml XMLTYPE := XMLTYPE(p_file);
BEGIN
  FOR item IN (
    SELECT extractvalue(value(r), '/ROW/GUEST_ID')                 AS id,
           extractvalue(value(r), '/ROW/GUEST_EMAIL')         AS email,
           extractvalue(value(r), '/ROW/GUEST_NAME')          AS name,
           extractvalue(value(r), '/ROW/GUEST_SURNAME')            AS surname,
           extractvalue(value(r), '/ROW/USERNAME')              AS username

    FROM TABLE (XMLSEQUENCE(EXTRACT(v_xml, '/ROWSET/ROW'))) r
  )
  LOOP
      DBMS_OUTPUT.PUT_LINE(item.id ||' '|| item.name|| item.surname);
    --INSERT INTO Clients_import (id, first_name, last_name, birth_date, address, phone, email, gender, passport, driver_license_number)
    --VALUES (item.id, item.first_name, item.last_name, item.birth_date, item.address, item.phone, item.email, item.gender, item.passport, item.driver_license_number);
  END LOOP;

  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('Error occurred: ' || SQLERRM);
END;

create PROCEDURE FILE_TO_CLOB(
        p_file_name IN NVARCHAR2,
        p_clob OUT CLOB
    )
    AS
        v_file     UTL_FILE.FILE_TYPE;
        v_filename NVARCHAR2(100);
        v_buffer   NVARCHAR2(32767);
BEGIN
    v_filename := p_file_name || '.xml';

    v_file := UTL_FILE.FOPEN('XML_DIR', v_filename, 'r');
    LOOP
        UTL_FILE.GET_LINE(v_file, v_buffer);
        IF v_buffer = '</ROWSET>' THEN
            p_clob := p_clob || v_buffer;
            EXIT;
        ELSE
            p_clob := p_clob || v_buffer;
        END IF;
    END LOOP;
    UTL_FILE.FCLOSE(v_file);
END;


create or replace PROCEDURE import_data
    IS
    v_clob CLOB;
BEGIN
    FILE_TO_CLOB('rakadabra', v_clob);
    import_data_xml(v_clob);
    commit;
end;

begin
    import_data;
end;