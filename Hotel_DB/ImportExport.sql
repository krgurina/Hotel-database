----------------------------------------------------------------
-- Вызов
--------------------------------------------------------------
BEGIN
    EXPORT_GUESTS_XML;
END;

BEGIN
    IMPORT_GUESTS_XML;
END;



SELECT object_name, procedure_name
FROM all_procedures
WHERE object_name='IMPORT_GUESTS_XML';

SELECT object_name, procedure_name
FROM all_procedures
WHERE object_type = 'PROCEDURE';



SELECT * FROM GUESTS;
SELECT * FROM ALL_DIRECTORIES WHERE DIRECTORY_NAME = 'XML_DIR';


----------------------------------------------------------------
-- Экспорт
----------------------------------------------------------------
CREATE OR REPLACE DIRECTORY XML_DIR AS 'C:\Users\XE\ora21\admin\orcl\dpdump';

--вроде работает
CREATE OR REPLACE PROCEDURE EXPORT_GUESTS_XML AS
  v_file UTL_FILE.FILE_TYPE;
  v_cursor SYS_REFCURSOR;
  v_guest_record GUESTS%ROWTYPE;
BEGIN
  -- Создаем файл для записи
  v_file := UTL_FILE.FOPEN('XML_DIR', 'guests_export.xml', 'W');

  -- Открываем курсор для выборки данных из таблицы
  OPEN v_cursor FOR
    SELECT * FROM GUESTS;

  -- Цикл по каждой записи
  LOOP
    -- Извлекаем запись из курсора
    FETCH v_cursor INTO v_guest_record;

    -- Выход из цикла при окончании данных
    EXIT WHEN v_cursor%NOTFOUND;

    -- Генерируем XML данные для текущей записи
    UTL_FILE.PUT_LINE(v_file, '<GUEST>');
    UTL_FILE.PUT_LINE(v_file, '  <GUEST_ID>' || v_guest_record.guest_id || '</GUEST_ID>');
    UTL_FILE.PUT_LINE(v_file, '  <GUEST_EMAIL>' || v_guest_record.guest_email || '</GUEST_EMAIL>');
    UTL_FILE.PUT_LINE(v_file, '  <GUEST_NAME>' || v_guest_record.guest_name || '</GUEST_NAME>');
    UTL_FILE.PUT_LINE(v_file, '  <GUEST_SURNAME>' || v_guest_record.guest_surname || '</GUEST_SURNAME>');
    UTL_FILE.PUT_LINE(v_file, '  <USERNAME>' || v_guest_record.username || '</USERNAME>');
    UTL_FILE.PUT_LINE(v_file, '</GUEST>');
  END LOOP;

  -- Закрываем курсор
  CLOSE v_cursor;

  -- Закрываем файл
  UTL_FILE.FCLOSE(v_file);

  DBMS_OUTPUT.PUT_LINE('Export successful: guests_export.xml');
EXCEPTION
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('Error during export: ' || SQLERRM);
    UTL_FILE.FCLOSE(v_file);

END EXPORT_GUESTS_XML;
/
----------------------------------------------------------------
CREATE OR REPLACE PROCEDURE EXPORT_GUESTS_XML AS
  v_file UTL_FILE.FILE_TYPE;
  v_data CLOB;
BEGIN
  -- Получаем данные из таблицы в формате XML
  SELECT DBMS_XMLGEN.GETXML('SELECT * FROM GUESTS') INTO v_data FROM DUAL;

  -- Создаем файл для записи
  v_file := UTL_FILE.FOPEN('XML_DIR', 'guests_export.xml', 'W');

  -- Записываем данные в файл
  UTL_FILE.PUT_LINE(v_file, v_data);

  -- Закрываем файл
  UTL_FILE.FCLOSE(v_file);

  DBMS_OUTPUT.PUT_LINE('Export successful: guests_export.xml');
EXCEPTION
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('Error during export: ' || SQLERRM);
    UTL_FILE.FCLOSE(v_file);
END EXPORT_GUESTS_XML;
/



----------------------------------------------------------------
-- Импорт
----------------------------------------------------------------
CREATE OR REPLACE PROCEDURE IMPORT_GUESTS_XML AS
  v_file BFILE;
  v_data CLOB;
  v_xml XMLTYPE;
BEGIN
  -- Открываем файл для чтения
  v_file := BFILENAME('XML_DIR', 'guests_export.xml');

  -- Загружаем содержимое файла в переменную CLOB
  DBMS_LOB.CREATETEMPORARY(v_data, TRUE);
  DBMS_LOB.FILEOPEN(v_file, DBMS_LOB.FILE_READONLY);
  DBMS_LOB.LOADFROMFILE(v_data, v_file, DBMS_LOB.GETLENGTH(v_file));
  DBMS_LOB.FILECLOSE(v_file);

  -- Преобразуем данные CLOB в XMLTYPE
  v_xml := XMLTYPE(v_data);

  -- Читаем данные из XML и вставляем их в таблицу
  FOR r IN (
    SELECT
      EXTRACTVALUE(VALUE(p), '/ROWSET/ROW/GUEST/GUEST_ID') AS guest_id,
      EXTRACTVALUE(VALUE(p), '/ROWSET/ROW/GUEST/GUEST_EMAIL') AS guest_email,
      EXTRACTVALUE(VALUE(p), '/ROWSET/ROW/GUEST/GUEST_NAME') AS guest_name,
      EXTRACTVALUE(VALUE(p), '/ROWSET/ROW/GUEST/GUEST_SURNAME') AS guest_surname,
      EXTRACTVALUE(VALUE(p), '/ROWSET/ROW/GUEST/USERNAME') AS username
    FROM TABLE(XMLSEQUENCE(EXTRACT(v_xml, '/GUEST'))) p
  )
  LOOP
    INSERT INTO GUESTS_XML (guest_id, guest_email, guest_name, guest_surname, username)
    VALUES (r.guest_id, r.guest_email, r.guest_name, r.guest_surname, r.username);
  END LOOP;

  DBMS_OUTPUT.PUT_LINE('Import successful: guests_export.xml');
EXCEPTION
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('Error during import: ' || SQLERRM);
END IMPORT_GUESTS_XML;
/















----------------------------------------------------------------
-- Таблицы
----------------------------------------------------------------
CREATE TABLE GUESTS_XML (
    guest_id NUMBER(10) GENERATED AS IDENTITY(START WITH 1 INCREMENT BY 1),
    guest_email NVARCHAR2(50) NOT NULL,
    guest_name NVARCHAR2(50) NOT NULL,
    guest_surname NVARCHAR2(50) NOT NULL,
    username NVARCHAR2(50) NOT NULL UNIQUE,
    CONSTRAINT guest_xml_pk PRIMARY KEY (guest_id)
) tablespace HOTEL_TS;

select * from GUESTS_XML;