CREATE OR REPLACE TRIGGER BookingStatusTrigger
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
CREATE OR REPLACE TRIGGER DELETE_ROOM_TYPE_TRIGGER
BEFORE DELETE ON ROOM_TYPES
FOR EACH ROW
BEGIN

    DELETE FROM Rooms WHERE rooms.ROOM_ROOM_TYPE_ID = :OLD.ROOM_TYPE_ID;
    DELETE FROM PHOTO WHERE PHOTO_ROOM_TYPE_ID = :OLD.ROOM_TYPE_ID;

    DBMS_OUTPUT.PUT_LINE('Произошло удаление всех комнат и фото имеющих удаляемый тип');

EXCEPTION
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('Произошла ошибка при удалении комант: ' || SQLERRM);
END DELETE_ROOM_TYPE_TRIGGER;
/

CREATE OR REPLACE TRIGGER DELETE_SERVICE_TYPE_TRIGGER
BEFORE DELETE ON SERVICE_TYPES
FOR EACH ROW
BEGIN
      DELETE FROM SERVICES WHERE SERVICE_TYPE_ID = :OLD.SERVICE_TYPE_ID;

    --DBMS_OUTPUT.PUT_LINE('Произошло удаление всех услуг имеющих удаляемый тип услуги');

EXCEPTION
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('Произошла ошибка при удалении комант: ' || SQLERRM);
END DELETE_SERVICE_TYPE_TRIGGER;
/

----------------------------------------------------------------

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

select * from USER_TRIGGERS
