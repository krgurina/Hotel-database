--пользователь

----------------------------------------------------------------
--PreBooking
----------------------------------------------------------------
BEGIN
    GUEST.GET_AVAILABLE_ROOMS(
        P_CAPACITY => 2,
        p_start_date => TO_DATE('2023-12-11', 'YYYY-MM-DD'),
        p_end_date => TO_DATE('2023-12-12', 'YYYY-MM-DD')
    );
exception
when others then
    DBMS_OUTPUT.PUT_LINE('капец какой-то происходит: ' || SQLERRM);
END;


----------------------------------------------------------------
--PreBooking
----------------------------------------------------------------
BEGIN
    ADMIN.UserPack.PreBooking(
        p_room_id => 4,
        p_start_date => TO_DATE('2023-12-11', 'YYYY-MM-DD'),
        p_end_date => TO_DATE('2023-12-12', 'YYYY-MM-DD'),
        p_tariff_id => 1
    );
END;
/

BEGIN
    ADMIN.UserPack.PreBooking(
        p_room_id => 2,
        p_start_date => TO_DATE('2024-01-01', 'YYYY-MM-DD'),
        p_end_date => TO_DATE('2024-01-09', 'YYYY-MM-DD'),
        p_tariff_id => 1
    );
END;
/

----------------------------------------------------------------
--BookingNow
----------------------------------------------------------------
BEGIN
    ADMIN.UserPack.BOOKINGNOW(
        p_room_id =>10 ,
        p_end_date => TO_DATE('2023-12-20', 'YYYY-MM-DD'),
        p_tariff_id => 5
    );

END;
/

----------------------------------------------------------------
--GetBookingDetailsById
----------------------------------------------------------------
BEGIN
    ADMIN.UserPack.GetBookingDetailsById(p_booking_id => 81);
END;
/

----------------------------------------------------------------
--EditBooking
----------------------------------------------------------------

BEGIN
    ADMIN.UserPack.EditBooking(
        p_booking_id => 25,
        p_room_id => 3,
        p_start_date => TO_DATE('2024-01-15', 'YYYY-MM-DD'),
        p_end_date => TO_DATE('2024-01-25', 'YYYY-MM-DD'),
        p_tariff_id => 4
    );
    ADMIN.UserPack.GetBookingDetailsById(p_booking_id => 25);

END;
/

BEGIN
    ADMIN.UserPack.EditBooking(
        p_booking_id => 41,
        p_room_id => 10,
        p_end_date => TO_DATE('2023-12-13', 'YYYY-MM-DD'),
        p_tariff_id => 5
    );
    ADMIN.UserPack.GetBookingDetailsById(p_booking_id => 41);

END;
/

SELECT USER FROM DUAL;


----------------------------------------------------------------
--DenyBooking

----------------------------------------------------------------
begin
    ADMIN.UserPack.DenyBooking(
        p_booking_id => 61);
end;

CAll GUEST.RestoreBooking(61);

BEGIN
    ADMIN.UserPack.GetBookingDetailsById(p_booking_id => 41);
END;
/

----------------------------------------------------------------
-- OrderService
----------------------------------------------------------------
BEGIN
    ADMIN.UserPack.OrderService(
        p_service_type_id => 2,
        p_service_start_date => TO_DATE('2024-01-08', 'YYYY-MM-DD'),
        p_service_end_date => TO_DATE('2024-01-09', 'YYYY-MM-DD')
    );
END;
/
----------------------------------------------------------------
-- EditService
----------------------------------------------------------------
BEGIN
    ADMIN.UserPack.EditService(
        p_service_id =>22,
        p_service_type_id => 5,
        p_service_start_date => TO_DATE('2024-01-08', 'YYYY-MM-DD'),
        p_service_end_date => TO_DATE('2024-01-11', 'YYYY-MM-DD')
    );
END;
/

--2
BEGIN
    ADMIN.UserPack.EditService(
        p_service_id =>1,  --22
        p_service_type_id => 5,
        p_service_start_date => TO_DATE('2024-01-07', 'YYYY-MM-DD')
    );
END;
/

----------------------------------------------------------------
-- DenyService
----------------------------------------------------------------




----------------------------------------------------------------
-- INFO
----------------------------------------------------------------
BEGIN
    GUEST.GetTariffInfo;
end;
BEGIN
    GUEST.GetTariffInfo(1);
end;


----------------------------------------------------------------
-- CALCULATE_STAY_COST
----------------------------------------------------------------
begin
    DBMS_OUTPUT.PUT_LINE('Стоимость проживая: '|| TO_CHAR(GUEST.CALCULATE_STAY_COST(61),'9999.99') ||'р.');
end;

BEGIN
    GUEST.CHECKOUT(61);
END;

----------------------------------------------------------------
-- инфа о себе
----------------------------------------------------------------
call GUEST.GET_MY_SERVICES();

call GUEST.GET_MY_BOOKINGS();

begin
GUEST.GetServiceInfo (2);
END;