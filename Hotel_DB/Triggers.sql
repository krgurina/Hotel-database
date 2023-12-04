CREATE OR REPLACE TRIGGER BookingStatusTrigger
BEFORE INSERT ON BOOKING
FOR EACH ROW
BEGIN
    :NEW.BOOKING_STATE := 2;
    DBMS_OUTPUT.PUT_LINE('Бронь с ID: ' || :NEW.BOOKING_ID || ' Одобрена администратором');

    EXCEPTION
        WHEN OTHERS THEN
            -- В случае ошибки, можно вывести сообщение или предпринять другие действия
            DBMS_OUTPUT.PUT_LINE('Произошла ошибка при вставке: ' || SQLERRM);
END;
/

----------------------------------------------------------------

CREATE OR REPLACE TRIGGER AFTER_DELETE_USER_TRIGGER
AFTER DELETE ON GUESTS
FOR EACH ROW
DECLARE
BEGIN
  EXECUTE IMMEDIATE 'DROP USER ' || :OLD.USERNAME || ' CASCADE';
EXCEPTION
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('Произошла ошибка при удалении гостя: ' || SQLERRM);
END AFTER_DELETE_USER_TRIGGER;
/

----------------------------------------------------------------
CREATE OR REPLACE TRIGGER AFTER_INSERT_GUEST_TRIGGER
AFTER INSERT ON GUESTS
FOR EACH ROW
DECLARE
BEGIN
  EXECUTE IMMEDIATE 'CREATE USER ' || :NEW.USERNAME ||
                    ' IDENTIFIED BY ' || :NEW.USERNAME ||
                    ' DEFAULT TABLESPACE HOTEL_TS' ||
                    ' TEMPORARY TABLESPACE HOTEL_TEMP_TS';

  EXECUTE IMMEDIATE 'GRANT Employee_role TO ' || :NEW.USERNAME;
EXCEPTION
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('Произошла ошибка при добавлении гостя: ' || SQLERRM);
END AFTER_INSERT_GUEST_TRIGGER;
/