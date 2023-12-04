SELECT * FROM ALL_DIRECTORIES WHERE DIRECTORY_NAME = 'XML_DIR';
----------------------------------------------------------------

select * from BOOKING_STATE_XML;

CREATE TABLE BOOKING_STATE_XML (
    booking_state_id NUMBER(1) GENERATED AS IDENTITY(START WITH 1 INCREMENT BY 1),
    booking_state NVARCHAR2(100) NOT NULL,
    CONSTRAINT booking_state_xml_pk PRIMARY KEY (booking_state_id)
) tablespace HOTEL_TS;
--C:\Users\XE\ora21\admin\orcl\dpdump

CREATE OR REPLACE DIRECTORY XML_DIR AS 'C:\Users\XE\ora21\admin\orcl\dpdump';
--CREATE OR REPLACE DIRECTORY XML_DIR AS 'E:\CourseProj\Hotel_DB\XML_DIR';

CREATE OR REPLACE PROCEDURE EXPORT_BOOKING_STATE_XML AS
  v_file UTL_FILE.FILE_TYPE;
  v_xml_data CLOB;
BEGIN
  -- Создаем файл для записи
  v_file := UTL_FILE.FOPEN('XML_DIR', 'booking_state_export.xml', 'W');

  -- Генерируем XML данные с использованием DBMS_XMLGEN
  SELECT XMLELEMENT("BOOKING_STATE",
                  XMLAGG(XMLELEMENT("BOOKING_STATE_ENTRY",
                           XMLFOREST(booking_state_id AS "BOOKING_STATE_ID",
                                     booking_state AS "BOOKING_STATE")
                           )
                  )
         ).getClobVal()
  INTO v_xml_data
  FROM BOOKING_STATE;

  -- Записываем XML данные в файл
  UTL_FILE.PUT_LINE(v_file, v_xml_data);

  -- Закрываем файл
  UTL_FILE.FCLOSE(v_file);

  DBMS_OUTPUT.PUT_LINE('Export successful: booking_state_export.xml');
EXCEPTION
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('Error during export: ' || SQLERRM);
END EXPORT_BOOKING_STATE_XML;
/

begin
    EXPORT_BOOKING_STATE_XML;
end;

----------------------------------------------------------------
-- а теперь импорт
CREATE OR REPLACE PROCEDURE IMPORT_BOOKING_STATE_XML AS
  v_xml_data CLOB;
  v_booking_state NVARCHAR2(100);
BEGIN
  -- Читаем XML-файл в CLOB
  SELECT XMLTYPE(BFILENAME('XML_DIR', 'booking_state_export.xml'), NLS_CHARSET_ID('UTF8')).getClobVal()
  INTO v_xml_data
  FROM DUAL;

  -- Извлекаем данные и вставляем их в таблицу
  FOR r IN (SELECT
              EXTRACTVALUE(VALUE(t), '/BOOKING_STATE_ENTRY/BOOKING_STATE') AS booking_state
            FROM TABLE(XMLSequence(EXTRACT(XMLTYPE(v_xml_data), '/BOOKING_STATE/BOOKING_STATE_ENTRY'))) t) LOOP
    v_booking_state := r.booking_state;

    -- Вставляем данные в таблицу BOOKING_STATE_XML
    INSERT INTO BOOKING_STATE_XML (booking_state)
    VALUES (v_booking_state);
  END LOOP;

  DBMS_OUTPUT.PUT_LINE('Import successful.');
EXCEPTION
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('Error during import: ' || SQLERRM);
END IMPORT_BOOKING_STATE_XML;
/




begin
    IMPORT_BOOKING_STATE_XML;
end;
