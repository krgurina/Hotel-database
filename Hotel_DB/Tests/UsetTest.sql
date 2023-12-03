--пользователь
----------------------------------------------------------------
--PreBooking
----------------------------------------------------------------
DECLARE
    v_booking_id NUMBER;
BEGIN
    ADMIN.UserPack.PreBooking(
        p_room_id => 3,
        p_guest_id => 2,
        p_start_date => TO_DATE('2024-01-01', 'YYYY-MM-DD'),
        p_end_date => TO_DATE('2024-01-09', 'YYYY-MM-DD'),
        p_tariff_id => 1,
        p_booking_id => v_booking_id
    );
        DBMS_OUTPUT.PUT_LINE(v_booking_id);
END;
/

----------------------------------------------------------------
--BookingNow
----------------------------------------------------------------
DECLARE
    v_booking_id NUMBER;
BEGIN
    ADMIN.UserPack.BOOKINGNOW(
        p_room_id => 4,
        p_guest_id => 21,
        p_end_date => TO_DATE('2023-12-24', 'YYYY-MM-DD'),
        p_tariff_id => 5,
        p_booking_id => v_booking_id
    );
END;
/

----------------------------------------------------------------
--GetBookingDetailsById
----------------------------------------------------------------
BEGIN
    ADMIN.UserPack.GetBookingDetailsById(p_booking_id => 61);
END;
/

----------------------------------------------------------------
--UpdateBooking
----------------------------------------------------------------
DECLARE
BEGIN
    ADMIN.UserPack.UpdateBooking(
        p_booking_id => 61,
        p_room_id => 3,
        p_guest_id => 21,
        p_start_date => TO_DATE('2024-01-15', 'YYYY-MM-DD'),
        p_end_date => TO_DATE('2024-01-15', 'YYYY-MM-DD'),
        p_tariff_id => 1
    );
END;
/

SELECT USER FROM DUAL;


