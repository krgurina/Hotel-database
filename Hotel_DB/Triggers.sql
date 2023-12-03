CREATE OR REPLACE TRIGGER BookingStatusTrigger
BEFORE INSERT ON BOOKING
FOR EACH ROW
BEGIN
    :NEW.BOOKING_STATE := 1;
    DBMS_OUTPUT.PUT_LINE('Бронь с ID: ' || :NEW.BOOKING_ID || ' Одобрена администратором');

    EXCEPTION
        WHEN OTHERS THEN
            -- В случае ошибки, можно вывести сообщение или предпринять другие действия
            DBMS_OUTPUT.PUT_LINE('Произошла ошибка при вставке: ' || SQLERRM);
END;
/