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
    FROM booking_details_view
    WHERE booking_id = p_booking_id;

    RETURN v_booking_details;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RAISE_APPLICATION_ERROR(-20001, 'Бронь с указанным ID не найдена.');
    WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(-20002, 'Произошла ошибка: ' || SQLERRM);
END GetBookingDetails;

--инфа о занятых номера
-- CREATE OR REPLACE FUNCTION GetOccupiedRoomsInfo
-- RETURN SYS_REFCURSOR
-- AS
--     v_occupied_rooms_cursor SYS_REFCURSOR;
-- BEGIN
--     OPEN v_occupied_rooms_cursor FOR
--     SELECT *
--     FROM OCCUPIED_ROOMS_VIEW;
--
--     RETURN v_occupied_rooms_cursor;
-- EXCEPTION
--     WHEN OTHERS THEN
--         RAISE_APPLICATION_ERROR(-20001, 'Произошла ошибка: ' || SQLERRM);
-- END GetOccupiedRoomsInfo;