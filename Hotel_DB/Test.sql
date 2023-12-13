select * from all_users;
    DELETE FROM USERS WHERE lower(username) = lower(user2);


--1.
BEGIN
    ADMIN.HotelAdminPackageCRUD.InsertEmployee(
    p_name => 'Виктор',
    p_surname => 'Якушик',
    p_position => 'Водитель',
    p_email => 'sdfghjk.fjdnvk@example.com',
    p_hire_date => TO_DATE('2023-02-07', 'YYYY-MM-DD'),
    p_birth_date => TO_DATE('1998-07-09', 'YYYY-MM-DD')
  );
END;
/
--c синонимом
BEGIN
    A_ADD_EMPLOYEE(
    p_name => 'Рита',
    p_surname => 'Волкова',
    p_position => 'повар',
    p_email => 'sdfghjk.fjdnvk@example.com',
    p_hire_date => TO_DATE('2022-02-07', 'YYYY-MM-DD'),
    p_birth_date => TO_DATE('1999-04-09', 'YYYY-MM-DD')
  );
END;
/

-- фото
-- declare
--     v_photo_source BLOB := EMPTY_BLOB(); -- Замените на фактический BLOB
-- BEGIN
--     HotelAdminPackageCRUD.InsertPhoto(
--         p_photo_room_type_id => 1,
--         p_photo_source => v_photo_source);
-- END;
-- /

select * from PHOTO;
select PHOTO_SOURCE from PHOTO;

--1.
BEGIN
    ADMIN.HotelAdminPackageCRUD.INSERTTARIFFTYPE(
      p_tariff_type_name =>'имя тарифа',
      p_tariff_type_description =>'описание',
      p_tariff_type_daily_price =>12.3
  );
END;


----------------------------------------------------------------
--пользователь

BEGIN
    ADMIN.UserPack.PreBooking(
        p_room_id => 1,
        p_guest_id => 1,
        p_start_date => TO_DATE('2023-12-01', 'YYYY-MM-DD'),
        p_end_date => TO_DATE('2023-12-05', 'YYYY-MM-DD'),
        p_tariff_id => 1
    );
END;
/


BEGIN
    ADMIN.UserPack.BOOKINGNOW(
        p_room_id => 1,
        p_guest_id => 2,
        p_end_date => TO_DATE('2023-12-10', 'YYYY-MM-DD'),
        p_tariff_id => 2
    );
END;
/

DECLARE
    v_room_id NUMBER := 3; -- замените на реальный ID номера
    v_guest_id NUMBER := 3; -- замените на реальный ID гостя
    v_end_date DATE := TO_DATE('2023-12-24', 'YYYY-MM-DD'); -- укажите желаемую дату окончания
    v_tariff_id NUMBER := 4; -- замените на реальный ID тарифа
    v_booking_id NUMBER;
BEGIN
    ADMIN.UserPack.BOOKINGNOW(
        p_room_id => v_room_id,
        p_guest_id => v_guest_id,
        p_end_date => v_end_date,
        p_tariff_id => v_tariff_id,
        p_booking_id => v_booking_id
    );
    -- здесь вы можете использовать v_booking_id по вашему усмотрению
END;
/
commit;
select * from rooms;




create or replace PROCEDURE Test1
AS
BEGIN
    select USERNAME from GUESTS;
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Произошла ошибка: ' || SQLERRM);
        ROLLBACK;

END Test1;

begin
    Test1;
end;



CREATE OR REPLACE FUNCTION GetAllGuestsCursor RETURN SYS_REFCURSOR IS
    v_result_cursor SYS_REFCURSOR;
BEGIN
    OPEN v_result_cursor FOR
        SELECT * FROM GUESTS;

    RETURN v_result_cursor;
END GetAllGuestsCursor;
/

drop FUNCTION GetAllGuests;

CREATE OR REPLACE PROCEDURE GetAllGuests AS
    guest_cursor SYS_REFCURSOR;
    v_guest_info GUESTS%ROWTYPE;
BEGIN
    guest_cursor := GetAllGuestsCursor;

    LOOP
        FETCH guest_cursor INTO v_guest_info;
        EXIT WHEN guest_cursor%NOTFOUND;

        DBMS_OUTPUT.PUT_LINE('Guest ID: ' || v_guest_info.GUEST_ID ||
                             ', Email: ' || v_guest_info.GUEST_EMAIL ||
                             ', Name: ' || v_guest_info.GUEST_NAME ||
                             ', Surname: ' || v_guest_info.GUEST_SURNAME ||
                             ', Username: ' || v_guest_info.USERNAME);
    END LOOP;

    CLOSE guest_cursor;
END GetAllGuests;
/




begin
    ShowAllGuests;
end;




CREATE OR REPLACE FUNCTION GetPhoto(
    p_room_type_id IN NUMBER
) RETURN BLOB
IS
    v_photo BLOB;
BEGIN
    SELECT PHOTO_SOURCE INTO v_photo
    FROM PHOTO
    WHERE PHOTO_ROOM_TYPE_ID = p_room_type_id;
    RETURN v_photo;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('Данные не найдены');
        RETURN NULL;
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('OpenPoster: ' || SQLERRM);
        RETURN NULL;
END GetPhoto;

    select GetPhoto(1) from dual;
----------------------------------------------------------------

CREATE OR REPLACE FUNCTION GetPhotos(
    p_room_type_id IN NUMBER
) RETURN PHOTO%ROWTYPE
IS
    v_photo PHOTO%ROWTYPE;
BEGIN
    SELECT *
    INTO v_photo
    FROM PHOTO
    WHERE PHOTO_ID = p_room_type_id;

    RETURN v_photo;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('Фотографии не найдены');
        RETURN NULL;
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('GetPhotos: ' || SQLERRM);
        RETURN NULL;
END GetPhotos;
/

select * from GetPhotos(1);



--------------------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION GetAllEmployeesCursor(p_employee_id NUMBER DEFAULT NULL) RETURN SYS_REFCURSOR IS
    result_cursor SYS_REFCURSOR;
BEGIN
    IF p_employee_id IS NOT NULL THEN
        OPEN result_cursor FOR
            SELECT * FROM Employees WHERE Employee_ID = p_employee_id;
    ELSE
        OPEN result_cursor FOR
            SELECT * FROM Employees;
    END IF;

    RETURN result_cursor;
END GetAllEmployeesCursor;
/

CREATE OR REPLACE PROCEDURE GetAllEmployees(p_employee_id NUMBER DEFAULT NULL) AS
    v_employee_cursor SYS_REFCURSOR;
    v_employee_info EMPLOYEES%ROWTYPE;
BEGIN
    v_employee_cursor := GetAllEmployeesCursor(p_employee_id);

    LOOP
        FETCH v_employee_cursor INTO v_employee_info;
        EXIT WHEN v_employee_cursor%NOTFOUND;

        DBMS_OUTPUT.PUT_LINE('ID сотрудника: ' || v_employee_info.EMPLOYEE_ID ||
                             ', Имя: ' || v_employee_info.EMPLOYEE_NAME ||
                             ', Фамилия: ' || v_employee_info.EMPLOYEE_SURNAME ||
                             ', Должность: ' || v_employee_info.EMPLOYEE_POSITION ||
                             ', Email: ' || v_employee_info.EMPLOYEE_EMAIL ||
                             ', Дата найма: ' || v_employee_info.EMPLOYEE_HIRE_DATE ||
                             ', Дата рождения: ' || v_employee_info.EMPLOYEE_BIRTH_DATE);
    END LOOP;

    CLOSE v_employee_cursor;
END GetAllEmployees;
/

begin
    INSERT_BOOKING_STATE('fix');
end;



CREATE OR REPLACE PROCEDURE INSERT_BOOKING_STATE (
    p_booking_state NVARCHAR2
) AS
BEGIN
    -- Вставка данных в таблицу
    INSERT INTO BOOKING_STATE (booking_state)
    VALUES (p_booking_state);

    -- Фиксация транзакции
    COMMIT;

    DBMS_OUTPUT.PUT_LINE('Вставка успешно завершена: ' || p_booking_state);
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Ошибка вставки: ' || SQLERRM);
        -- Откат изменений в случае ошибки
        ROLLBACK;
END INSERT_BOOKING_STATE;
/


----------------------------------------------------------------
-- ИМПОРТ ЭКСПОРТ
----------------------------------------------------------------
CREATE OR REPLACE PROCEDURE Export_GUESTS_XML AS
    DOC DBMS_XMLDOM.DOMDocument;
    XDATA XMLTYPE;
    CURSOR XMLCUR IS
        SELECT XMLELEMENT("GUESTS",
            XMLAttributes('http://www.w3.org/2001/XMLSchema' AS "xmlns:xsi",
                           'http://www.oracle.com/Users.xsd' AS "xsi:nonamespaceSchemaLocation"),
            XMLAGG(XMLELEMENT("GUEST",
                    xmlelement("ID", GUESTS.GUEST_ID),
                    xmlelement("NAME", GUESTS.GUEST_NAME),
                    xmlelement("SURNAME", GUESTS.GUEST_SURNAME),
                    xmlelement("EMAIL", GUESTS.GUEST_EMAIL),
                    xmlelement("USERNAME", GUESTS.USERNAME)
            ))
        ) FROM GUESTS;
BEGIN
    OPEN XMLCUR;
    FETCH XMLCUR INTO XDATA;
    CLOSE XMLCUR;

    DOC := DBMS_XMLDOM.NewDOMDocument(XDATA);
    DBMS_XMLDOM.WRITETOFILE(DOC, 'XML_DIR/GUESTS.xml');
END Export_GUESTS_XML;
/


begin
    Export_GUESTS_XML();
end;



CREATE OR REPLACE PROCEDURE Import_GUESTS_Xml AS
    L_CLOB CLOB;
    L_BFILE BFILE := BFILENAME('XML_DIR', 'GUESTS.xml');

    L_DEST_OFFSET INTEGER := 1;
    L_SRC_OFFSET INTEGER := 1;
    L_BFILE_CSID NUMBER := 0;
    L_LANG_CONTEXT INTEGER := 0;
    L_WARNING INTEGER := 0;

--     p_email NVARCHAR2;
--     p_name NVARCHAR2;
--     p_surname NVARCHAR2;
--     p_username NVARCHAR2;

    P DBMS_XMLPARSER.PARSER;
    v_doc dbms_xmldom.domdocument;
    v_root_element dbms_xmldom.domelement;
    V_CHILD_NODES DBMS_XMLDOM.DOMNODELIST;
    V_CURRENT_NODE DBMS_XMLDOM.DOMNODE;

    GUEST GUESTS%rowtype;
begin
    DBMS_LOB.CREATETEMPORARY (L_CLOB, TRUE);
    DBMS_LOB.FILEOPEN(L_BFILE, DBMS_LOB.FILE_READONLY);

    DBMS_LOB.LOADCLOBFROMFILE (DEST_LOB => L_CLOB, SRC_BFILE => L_BFILE, AMOUNT => DBMS_LOB.LOBMAXSIZE,
    DEST_OFFSET => L_DEST_OFFSET, SRC_OFFSET => L_SRC_OFFSET, BFILE_CSID => L_BFILE_CSID,
    LANG_CONTEXT => L_LANG_CONTEXT, WARNING => L_WARNING);
    DBMS_LOB.FILECLOSE(L_BFILE);
    COMMIT;

    P := Dbms_Xmlparser.Newparser;
    DBMS_XMLPARSER.PARSECLOB(P, L_CLOB);
    V_DOC := DBMS_XMLPARSER.GETDOCUMENT(P);
    V_ROOT_ELEMENT := DBMS_XMLDOM.Getdocumentelement(v_Doc);
    V_CHILD_NODES := DBMS_XMLDOM.GETCHILDRENBYTAGNAME(V_ROOT_ELEMENT,'*');

    FOR i IN 0 .. DBMS_XMLDOM.GETLENGTH(V_CHILD_NODES) - 1
    LOOP
        V_CURRENT_NODE := DBMS_XMLDOM.ITEM(V_CHILD_NODES,i);

--         DBMS_XSLPROCESSOR.VALUEOF(V_CURRENT_NODE,
--         'ID/text()',GUEST.GUEST_NAME);
        DBMS_XSLPROCESSOR.VALUEOF(V_Current_Node, 'GUEST_NAME/text()',GUEST.GUEST_NAME);
        DBMS_XSLPROCESSOR.VALUEOF(V_Current_Node, 'GUEST_SURNAME/text()',GUEST.GUEST_SURNAME);
        DBMS_XSLPROCESSOR.VALUEOF(v_current_node, 'GUEST_EMAIL/text()',GUEST.GUEST_EMAIL);
        DBMS_XSLPROCESSOR.VALUEOF(v_current_node, 'USERNAME/text()',GUEST.USERNAME);

        INSERT INTO GUEST(GUEST_NAME, GUEST_SURNAME, GUEST_EMAIL, USERNAME)
        VALUES(GUEST.GUEST_NAME, GUEST.USERNAME, GUEST.GUEST_EMAIL, GUEST.USERNAME);
    END LOOP;

    DBMS_LOB.FREETEMPORARY(L_CLOB);
    DBMS_XMLPARSER.FREEPARSER(P);
    DBMS_XMLDOM.FREEDOCUMENT(V_DOC);
    COMMIT;
END Import_GUESTS_Xml;

BEGIN
    Import_GUESTS_Xml();
END;

----------------------------------------------------------------

CREATE OR REPLACE PROCEDURE import_from_xml IS
    v_file BFILE;
    v_content CLOB;
    v_parser DBMS_XMLPARSER.parser;
    v_doc DBMS_XMLDOM.DOMDocument;
    v_nl DBMS_XMLDOM.DOMNodeList;
    v_node DBMS_XMLDOM.DOMNode;
    v_child_nodes DBMS_XMLDOM.DOMNodeList;
    v_child_node DBMS_XMLDOM.DOMNode;
    v_guest_email VARCHAR2(100);
    v_guest_name VARCHAR2(100);
    v_guest_surname VARCHAR2(100);
    v_username VARCHAR2(100);
    v_dest_offset INTEGER := 1;
    v_src_offset INTEGER := 1;
    v_lang_context INTEGER := DBMS_LOB.default_lang_ctx;
    v_warning INTEGER;
BEGIN
    -- Открываем файл
    v_file := BFILENAME('XML_DIR', 'GUESTS.xml');
    DBMS_LOB.fileopen(v_file, DBMS_LOB.file_readonly);

    -- Читаем содержимое файла
    DBMS_LOB.createtemporary(v_content, TRUE);
    DBMS_LOB.loadclobfromfile(v_content, v_file, DBMS_LOB.getlength(v_file), v_dest_offset, v_src_offset, DBMS_LOB.file_readonly, v_lang_context, v_warning);
    DBMS_LOB.fileclose(v_file);

    -- Парсим XML
    v_parser := DBMS_XMLPARSER.newparser;
    DBMS_XMLPARSER.parseclob(v_parser, v_content);
    v_doc := DBMS_XMLPARSER.getdocument(v_parser);

    -- Получаем список узлов
    v_nl := DBMS_XMLDOM.getElementsByTagName(v_doc, 'GUEST');

    FOR i IN 0..DBMS_XMLDOM.getLength(v_nl)-1 LOOP
        v_node := DBMS_XMLDOM.item(v_nl, i);

        -- Получаем дочерние узлы каждого узла и вставляем в таблицу
        v_guest_email := DBMS_XMLDOM.getNodeValue(DBMS_XMLDOM.item(DBMS_XMLDOM.getElementsByTagName(v_node, 'EMAIL'), 0));
        v_guest_name := DBMS_XMLDOM.getNodeValue(DBMS_XMLDOM.item(DBMS_XMLDOM.getElementsByTagName(v_node, 'NAME'), 0));
        v_guest_surname := DBMS_XMLDOM.getNodeValue(DBMS_XMLDOM.item(DBMS_XMLDOM.getElementsByTagName(v_node, 'SURNAME'), 0));
        v_username := DBMS_XMLDOM.getNodeValue(DBMS_XMLDOM.item(DBMS_XMLDOM.getElementsByTagName(v_node, 'USERNAME'), 0));

        INSERT INTO GUESTS (guest_email, guest_name, guest_surname, username) VALUES (v_guest_email, v_guest_name, v_guest_surname, v_username);
    END LOOP;

    -- Освобождаем ресурсы
    DBMS_XMLDOM.freeNodeList(v_nl);
    DBMS_XMLDOM.freeDocument(v_doc);
    DBMS_XMLPARSER.freeparser(v_parser);
    DBMS_LOB.freetemporary(v_content);
END import_from_xml;

CALL import_from_xml();
COMMIT ;
SELECT * FROM GUESTS;
SELECT * FROM GUESTS_XML;