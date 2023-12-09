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

----------------------------------------------------------------
CREATE OR REPLACE TRIGGER CREATE_GUEST_USER_TRIGGER
AFTER INSERT ON GUESTS
FOR EACH ROW
DECLARE
BEGIN
--   EXECUTE IMMEDIATE 'CREATE USER ' || :NEW.USERNAME ||
--                     ' IDENTIFIED BY ' || :NEW.USERNAME ||
--                     ' DEFAULT TABLESPACE HOTEL_TS' ||
--                     ' TEMPORARY TABLESPACE HOTEL_TEMP_TS';

  --EXECUTE IMMEDIATE 'GRANT Employee_role TO ' || :NEW.USERNAME;
    DBMS_OUTPUT.PUT_LINE('триггер сработал');

EXCEPTION
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('Произошла ошибка при добавлении гостя: ' || SQLERRM);
END CREATE_GUEST_USER_TRIGGER;
/

----------------------------------------------------------------
CREATE OR REPLACE TRIGGER CREATE_EMPLOYEE_USER_TRIGGER
AFTER INSERT ON EMPLOYEES
FOR EACH ROW
DECLARE
BEGIN
  DBMS_OUTPUT.PUT_LINE('Триггер начал выполнение');
--
--   EXECUTE IMMEDIATE 'CREATE USER ' || :NEW.USERNAME ||
--                     ' IDENTIFIED BY ' || :NEW.USERNAME ||
--                     ' DEFAULT TABLESPACE HOTEL_TS' ||
--                     ' TEMPORARY TABLESPACE HOTEL_TEMP_TS';
--
--   DBMS_OUTPUT.PUT_LINE('CREATE USER выполнен успешно');
--
--   EXECUTE IMMEDIATE 'GRANT Employee_role TO ' || :NEW.USERNAME;
--   DBMS_OUTPUT.PUT_LINE('GRANT выполнен успешно');

EXCEPTION
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('Произошла ошибка: ' || SQLERRM);
END CREATE_EMPLOYEE_USER_TRIGGER;
/


----------------------------------------------------------------
CREATE OR REPLACE TRIGGER DROP_EMPLOYEE_USER_TRIGGER
AFTER DELETE ON EMPLOYEES
FOR EACH ROW
DECLARE
BEGIN
  EXECUTE IMMEDIATE 'DROP USER ' || :OLD.USERNAME || ' CASCADE';
EXCEPTION
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('Произошла ошибка при удалении сотрудника: ' || SQLERRM);
END DROP_EMPLOYEE_USER_TRIGGER;
/

drop trigger DROP_EMPLOYEE_USER_TRIGGER;
-----------------------------------------------------------------

CREATE OR REPLACE TRIGGER DROP_GUEST_USER_TRIGGER
AFTER DELETE ON GUESTS
FOR EACH ROW
DECLARE
BEGIN
  EXECUTE IMMEDIATE 'DROP USER ' || :OLD.USERNAME || ' CASCADE';
EXCEPTION
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('Произошла ошибка при удалении гостя: ' || SQLERRM);
END DROP_GUEST_USER_TRIGGER;
/


select * from USER_TRIGGERS
