--инфа о брони
CREATE OR REPLACE FUNCTION GetBookingDetails(
    p_booking_id IN NUMBER
)
RETURN booking_details_view%ROWTYPE
AS
    v_booking_details booking_details_view%ROWTYPE;
BEGIN
    -- Извлекаем информацию о брони с использованием представления
    SELECT *
    INTO v_booking_details
    FROM ADMIN.booking_details_view  -- Укажите правильную схему
    WHERE booking_id = p_booking_id;

    RETURN v_booking_details;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RAISE_APPLICATION_ERROR(-20001, 'Бронь с указанным ID (' || p_booking_id || ') не найдена.');
    WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(-20002, 'Произошла ошибка: ' || SQLERRM);
END GetBookingDetails;
/





