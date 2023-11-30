CREATE TABLE Guest_XML (xml_data XMLType) XMLTYPE COLUMN xml_data STORE AS BINARY XML;

CREATE OR REPLACE PROCEDURE EXSPORT_GUESTS AS
    v_xml XMLType;
    v_file UTL_FILE.file_type;
BEGIN
    v_file := UTL_FILE.FOPEN('XML_DIR', 'guests.xml', 'W');

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

-- CREATE TABLE GUESTS (
--     guest_id NUMBER(10) GENERATED AS IDENTITY(START WITH 1 INCREMENT BY 1),
--     guest_email NVARCHAR2(50) NOT NULL,
--     guest_name NVARCHAR2(50) NOT NULL,
--     guest_surname NVARCHAR2(50) NOT NULL,
--     CONSTRAINT guest_pk PRIMARY KEY (guest_id)
-- );



CREATE OR REPLACE TRIGGER trg_insert_guest
AFTER UPDATE ON Guests
FOR EACH ROW
DECLARE
  v_xml XMLType;
BEGIN
  SELECT XMLType(
           '<guest>' ||
           '<guest_id>' || :new.guest_id || '</guest_id>' ||
           '<guest_email>' || :new.guest_email || '</guest_email>' ||
           '<guest_name>' || :new.guest_name || '</guest_name>' ||
           '<guest_surname>' || :new.guest_surname || '</guest_surname>' ||
           '</guest>'
         )
  INTO v_xml
  FROM dual;

  INSERT INTO Guest_XML (xml_data) VALUES (v_xml);
END;

select * from Guest_XML;