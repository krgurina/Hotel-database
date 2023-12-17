
DROP TRIGGER CHECK_BOOKING_DATES_TRIGGER;
CREATE OR REPLACE TRIGGER CHECK_BOOKING_DATES_TRIGGER
BEFORE INSERT ON BOOKING
FOR EACH ROW
BEGIN
    IF :NEW.booking_start_date < SYSDATE THEN
        RAISE_APPLICATION_ERROR(-20012, 'Дата начала бронирования должна быть больше или равна текущей дате.');
    END IF;
    IF :NEW.booking_end_date <= :NEW.booking_start_date THEN
        RAISE_APPLICATION_ERROR(-20013, 'Дата окончания бронирования должна быть после даты начала бронирования.');
    END IF;
    IF :NEW.booking_end_date > TO_DATE('2025-01-01', 'YYYY-MM-DD') THEN
        RAISE_APPLICATION_ERROR(-20003, 'На данный момент бронирование на 2025 год и позже недоступно.');
    END IF;
EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Произошла ошибка: ' || SQLERRM);
            raise;
END;


CREATE OR REPLACE TRIGGER BookingStatusTrigger  --убрать
BEFORE INSERT ON BOOKING
FOR EACH ROW
BEGIN
    if:NEW.BOOKING_STATE = 1 then
    :NEW.BOOKING_STATE := 2;
    DBMS_OUTPUT.PUT_LINE('Бронь с ID: ' || :NEW.BOOKING_ID || ' Одобрена администратором');
end if;
    EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Произошла ошибка при вставке: ' || SQLERRM);
END;
/

----------------------------------------------------------------

----------------------------------------------------------------
-- drop trigger DELETE_ROOM_TYPE_TRIGGER;
-- CREATE OR REPLACE TRIGGER DELETE_ROOM_TYPE_TRIGGER
-- BEFORE DELETE ON ROOM_TYPES
-- FOR EACH ROW
-- BEGIN
--
--     DELETE FROM Rooms WHERE rooms.ROOM_ROOM_TYPE_ID = :OLD.ROOM_TYPE_ID;
--     DELETE FROM PHOTO WHERE PHOTO_ROOM_TYPE_ID = :OLD.ROOM_TYPE_ID;
--
--     DBMS_OUTPUT.PUT_LINE('Произошло удаление всех комнат и фото имеющих удаляемый тип');
--
-- EXCEPTION
--   WHEN OTHERS THEN
--     DBMS_OUTPUT.PUT_LINE('Произошла ошибка при удалении комант: ' || SQLERRM);
-- END DELETE_ROOM_TYPE_TRIGGER;
-- /
-- drop trigger DELETE_SERVICE_TYPE_TRIGGER;
-- CREATE OR REPLACE TRIGGER DELETE_SERVICE_TYPE_TRIGGER
-- BEFORE DELETE ON SERVICE_TYPES
-- FOR EACH ROW
-- BEGIN
--       DELETE FROM SERVICES WHERE SERVICE_TYPE_ID = :OLD.SERVICE_TYPE_ID;
--
--     --DBMS_OUTPUT.PUT_LINE('Произошло удаление всех услуг имеющих удаляемый тип услуги');
--
-- EXCEPTION
--   WHEN OTHERS THEN
--     DBMS_OUTPUT.PUT_LINE('Произошла ошибка при удалении комант: ' || SQLERRM);
-- END DELETE_SERVICE_TYPE_TRIGGER;
-- /

----------------------------------------------------------------
-- триггер для экспорта гостей
----------------------------------------------------------------
create or replace trigger UPDATE_GUEST_XML_TRIGGER
    after insert or delete or update
    on GUESTS
begin
    EXPORT_TO_FILE('select * from Guests', 'Guests');
    DBMS_OUTPUT.PUT_LINE('Данные о гостях успешно обновлены');
EXCEPTION
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('Произошла ошибка при экспорте гостей: ' || SQLERRM);
end;

----------------------------------------------------------------
-- триггер для экспорта сотрудников
----------------------------------------------------------------
create or replace trigger UPDATE_EMPLOYEE_XML_TRIGGER
    after insert or delete or update
    on EMPLOYEES
begin
    EXPORT_TO_FILE('select * from EMPLOYEES', 'Employees');
    DBMS_OUTPUT.PUT_LINE('Данные о сотрудников успешно обновлены');
EXCEPTION
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('Произошла ошибка при экспорте сотрудников: ' || SQLERRM);
end;

----------------------------------------------------------------

select * from USER_TRIGGERS
