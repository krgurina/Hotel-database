----------------------------------------------------------------
-- Вызов
----------------------------------------------------------------
begin
    IMPORT_GUESTS_XML('Guests');
end;
select * from GUESTS_XML;

----------------------------------------------------------------
-- Пустые таблички
----------------------------------------------------------------
CREATE TABLE GUESTS_XML (
    guest_id NUMBER(10) GENERATED AS IDENTITY(START WITH 1 INCREMENT BY 1),
    guest_email NVARCHAR2(50) NOT NULL,
    guest_name NVARCHAR2(50) NOT NULL,
    guest_surname NVARCHAR2(50) NOT NULL,
    username NVARCHAR2(50) NOT NULL UNIQUE,
    CONSTRAINT guest_pk_xml PRIMARY KEY (guest_id)
) tablespace HOTEL_TS;

select * from GUESTS_XML;
delete from GUESTS_XML;
drop table GUESTS_XML;

----------------------------------------------------------------
CREATE TABLE EMPLOYEES_XML (
    employee_id NUMBER(10) GENERATED AS IDENTITY(START WITH 1 INCREMENT BY 1),
    employee_name NVARCHAR2(50) NOT NULL,
    employee_surname NVARCHAR2(50) NOT NULL,
    employee_position NVARCHAR2(50) NOT NULL,
    employee_email NVARCHAR2(50) NOT NULL,
    employee_hire_date DATE NOT NULL,
    employee_birth_date DATE NOT NULL,
    username NVARCHAR2(50) NOT NULL UNIQUE,
    CONSTRAINT employee_pk_xml PRIMARY KEY (employee_id)
) tablespace HOTEL_TS;

select * from EMPLOYEES_XML;
delete from EMPLOYEES_XML;
drop table EMPLOYEES_XML;

----------------------------------------------------------------
-- экспорт
----------------------------------------------------------------
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
            DBMS_OUTPUT.PUT_LINE('Ошибка записи в файл.');
    END;
    UTL_FILE.FCLOSE(v_file);
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('Запрос не вернул данных.');
    WHEN UTL_FILE.INVALID_PATH THEN
        DBMS_OUTPUT.PUT_LINE('Неверный путь к директории.');
    WHEN UTL_FILE.INVALID_MODE THEN
        DBMS_OUTPUT.PUT_LINE('Неверный режим записи файла.');
    WHEN UTL_FILE.INVALID_FILEHANDLE THEN
        DBMS_OUTPUT.PUT_LINE('Неверный идентификатор файла.');
    WHEN UTL_FILE.INVALID_OPERATION THEN
        DBMS_OUTPUT.PUT_LINE('Неверная операция с файлом.');
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Произошла ошибка: ' || SQLERRM);
END;

begin
    EXPORT_TO_FILE('select * from employees', 'Employees');
end;

----------------------------------------------------------------
-- FILE_TO_CLOB
----------------------------------------------------------------
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

----------------------------------------------------------------
-- Импорт гостей
----------------------------------------------------------------
CREATE OR REPLACE PROCEDURE IMPORT_GUESTS_XML(p_file IN NVARCHAR2) AS
    v_clob CLOB;
    v_xml XMLTYPE;-- := XMLTYPE(p_file);
BEGIN
        FILE_TO_CLOB(p_file, v_clob);
    v_xml:= XMLTYPE(v_clob);
 FOR item IN (
    SELECT extractvalue(value(r), '/ROW/GUEST_ID')          AS id,
           extractvalue(value(r), '/ROW/GUEST_EMAIL')       AS email,
           extractvalue(value(r), '/ROW/GUEST_NAME')        AS name,
           extractvalue(value(r), '/ROW/GUEST_SURNAME')     AS surname,
           extractvalue(value(r), '/ROW/USERNAME')          AS username

    FROM TABLE (XMLSEQUENCE(EXTRACT(v_xml, '/ROWSET/ROW'))) r
  )

  LOOP
        INSERT INTO GUESTS_XML (guest_email, guest_name, guest_surname, USERNAME)
        VALUES (item.email, item.name, item.surname, item.username);
  END LOOP;

  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('Произошла ошибка: ' || SQLERRM);
END;




begin
    IMPORT_GUESTS_XML('Guests');
end;


----------------------------------------------------------------
-- Импорт сотрудников
----------------------------------------------------------------
CREATE OR REPLACE PROCEDURE IMPORT_EMPLOYEE_XML(p_file IN NVARCHAR2) AS
    v_clob CLOB;
    v_xml XMLTYPE;-- := XMLTYPE(p_file);
BEGIN
    FILE_TO_CLOB(p_file, v_clob);
    v_xml:= XMLTYPE(v_clob);

  FOR item IN (
    SELECT  extractvalue(value(r), '/ROW/EMPLOYEE_ID')          AS id,
            extractvalue(value(r), '/ROW/EMPLOYEE_EMAIL')       AS email,
            extractvalue(value(r), '/ROW/EMPLOYEE_NAME')        AS name,
            extractvalue(value(r), '/ROW/EMPLOYEE_SURNAME')     AS surname,
            extractvalue(value(r), '/ROW/EMPLOYEE_POSITION')        AS position,
            to_date(extractvalue(value(r), '/ROW/EMPLOYEE_HIRE_DATE'), 'YYYY-MM-DD') AS hire_date,
            to_date(extractvalue(value(r), '/ROW/EMPLOYEE_BIRTH_DATE'), 'YYYY-MM-DD') AS birth_date,
            extractvalue(value(r), '/ROW/USERNAME')          AS username

    FROM TABLE (XMLSEQUENCE(EXTRACT(v_xml, '/ROWSET/ROW'))) r
  )
  LOOP
        INSERT INTO EMPLOYEES_XML (employee_email, employee_name, employee_surname, employee_position, username, employee_hire_date, employee_birth_date)
        VALUES (item.email, item.name, item.surname, item.position, item.username, item.hire_date, item.birth_date);
  END LOOP;

  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('Произошла ошибка: ' || SQLERRM);
END;


begin
    IMPORT_EMPLOYEE_XML('Employees');
end;
