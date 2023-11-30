CREATE OR REPLACE DIRECTORY XML_DIR AS 'E:\CourseProj\Hotel_DB\XML_DIR';

CREATE OR REPLACE PROCEDURE SAVE_GUESTS_XML AS
    v_xml XMLType;
    v_file UTL_FILE.file_type;
BEGIN
    v_file := UTL_FILE.FOPEN('XML_DIR', 'guests.xml', 'W');

    UTL_FILE.PUT_LINE(v_file, '<?xml version="1.0" encoding="utf-8"?>');
    UTL_FILE.PUT_LINE(v_file, '<guests>');

    FOR rec IN (SELECT guest_id, guest_email, guest_name, guest_surname FROM Guests)
    LOOP
        v_xml := XMLType.createXML('<guest>' ||
            '<id>' || rec.guest_id || '</id>' ||
            '<email>' || rec.guest_email || '</email>' ||
            '<name>' || rec.guest_name || '</name>' ||
            '<surname>' || rec.guest_surname || '</surname>' ||
            '</guest>');

        UTL_FILE.put_line(v_file, v_xml.getClobVal());
    END LOOP;

    UTL_FILE.PUT_LINE(v_file, '</guests>');

    UTL_FILE.FCLOSE(v_file);
END;
/






-- CREATE TABLE GUESTS (
--     guest_id NUMBER(10) GENERATED AS IDENTITY(START WITH 1 INCREMENT BY 1),
--     guest_email NVARCHAR2(50) NOT NULL,
--     guest_name NVARCHAR2(50) NOT NULL,
--     guest_surname NVARCHAR2(50) NOT NULL,
--     CONSTRAINT guest_pk PRIMARY KEY (guest_id)
-- );


CREATE OR REPLACE PROCEDURE EXSPORT_GUESTS AS
    v_xml XMLType;
    v_file UTL_FILE.file_type;
BEGIN
    v_file := UTL_FILE.FOPEN('XML_DIR', 'auction_items.xml', 'W');

    UTL_FILE.PUT_LINE(v_file, '<?xml version="1.0" encoding="utf-8"?>');
    UTL_FILE.PUT_LINE(v_file, '<guests>');

    FOR rec IN (SELECT xml_data FROM Guests_XML)
    LOOP
        v_xml := rec.xml_data;
        UTL_FILE.put_line(v_file, v_xml.getClobVal());
    END LOOP;

    UTL_FILE.PUT_LINE(v_file, '</guests>');

    UTL_FILE.FCLOSE(v_file);
END;
/

CREATE OR REPLACE TRIGGER trg_auctions_update
AFTER UPDATE ON Auctions
FOR EACH ROW
DECLARE
  v_xml XMLType;
BEGIN
  SELECT XMLType(
           '<auction>' ||
           '<auction_id>' || :new.auction_id || '</auction_id>' ||
           '<auction_name>' || :new.auction_name || '</auction_name>' ||
           '<auction_date>' || :new.auction_date || '</auction_date>' ||
           '<auction_time>' || :new.auction_time || '</auction_time>' ||
           '<auction_location>' || :new.auction_location || '</auction_location>' ||
           '<seller_id>' || :new.seller_id || '</seller_id>' ||
           '</auction>'
         )
  INTO v_xml
  FROM dual;

  INSERT INTO Auctions_XML (xml_data) VALUES (v_xml);
END;

DROP DIRECTORY XML_DIR;
CREATE DIRECTORY XML_DIR AS 'E:\CourseProj\Hotel_DB\XML_DIR';

DECLARE
  v_file  UTL_FILE.FILE_TYPE;
  v_data  CLOB;
BEGIN
  -- Получаем данные из таблицы в формате XML
  SELECT DBMS_XMLGEN.GETXML('SELECT * FROM GUESTS').getClobVal() INTO v_data FROM dual;

  -- Открываем файл для записи
  v_file := UTL_FILE.FILE_OPEN('XML_DIR', 'guest.xml', 'w');

  -- Записываем данные в файл
  UTL_FILE.PUT(v_file, v_data);

  -- Закрываем файл
  UTL_FILE.FCLOSE(v_file);
END;







































create or replace PROCEDURE EXPORT_TO_FILE(
    p_query IN VARCHAR22,
    p_filename IN VARCHAR22
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
    EXPORT_TO_FILE('select * from policies where rownum <=50', 'rakadabra');
end;


