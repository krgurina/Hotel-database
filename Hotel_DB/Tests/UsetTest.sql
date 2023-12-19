--пользователь

----------------------------------------------------------------
--PRE_BOOKING
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
--PRE_BOOKING
----------------------------------------------------------------
BEGIN
    ADMIN.UserPack.PRE_BOOKING(
        p_room_id => 4,
        p_start_date => TO_DATE('2023-12-11', 'YYYY-MM-DD'),
        p_end_date => TO_DATE('2023-12-12', 'YYYY-MM-DD'),
        p_tariff_id => 1
    );
END;
/

BEGIN
    ADMIN.UserPack.PRE_BOOKING(
        p_room_id => 2,
        p_start_date => TO_DATE('2024-01-05', 'YYYY-MM-DD'),
        p_end_date => TO_DATE('2024-01-22', 'YYYY-MM-DD'),
        p_tariff_id => 4
    );
END;
/

----------------------------------------------------------------
--BOOKING_NOW
----------------------------------------------------------------
BEGIN
    ADMIN.UserPack.BOOKING_NOW(
        p_room_id =>1,
        p_end_date => TO_DATE('2024-01-01', 'YYYY-MM-DD'),
        p_tariff_id => 5
    );

END;
/

----------------------------------------------------------------
--Get_BookingDetails_By_Id
----------------------------------------------------------------
BEGIN
    ADMIN.UserPack.Get_BookingDetails_By_Id(p_booking_id => 106);
END;


----------------------------------------------------------------
--CHECK_IN
----------------------------------------------------------------
BEGIN
    ADMIN.UserPack.CHECK_IN(p_booking_id => 106);
END;


----------------------------------------------------------------
--Edit_Booking
----------------------------------------------------------------

BEGIN
    ADMIN.UserPack.Edit_Booking(
        p_booking_id => 102,
        p_room_id => 11,
        p_start_date => TO_DATE('2024-01-15', 'YYYY-MM-DD'),
        p_end_date => TO_DATE('2024-01-25', 'YYYY-MM-DD'),
        p_tariff_id => 4
    );
    ADMIN.UserPack.Get_BookingDetails_By_Id(p_booking_id => 102);

END;
/

BEGIN
    ADMIN.UserPack.Edit_Booking(
        p_booking_id => 102,
        p_start_date => TO_DATE('2024-01-15', 'YYYY-MM-DD'),
        p_end_date => TO_DATE('2024-12-13', 'YYYY-MM-DD'),
        p_tariff_id => 5
    );
    ADMIN.UserPack.Get_BookingDetails_By_Id(p_booking_id => 41);

END;
/

SELECT USER FROM DUAL;


----------------------------------------------------------------
--Deny_Booking

----------------------------------------------------------------
begin
    ADMIN.UserPack.Deny_Booking(
        p_booking_id => 61);
end;

CAll GUEST.Restore_Booking(61);

BEGIN
    ADMIN.UserPack.Get_BookingDetails_By_Id(p_booking_id => 41);
END;
/

----------------------------------------------------------------
-- Order_Service
----------------------------------------------------------------
BEGIN
    ADMIN.UserPack.Order_Service(
        p_service_type_id => 10,
        p_service_start_date => TO_DATE('2023-12-20', 'YYYY-MM-DD'),
        p_service_end_date => TO_DATE('2023-12-24', 'YYYY-MM-DD')
    );
END;
/
----------------------------------------------------------------
-- Edit_Service
----------------------------------------------------------------
BEGIN
    ADMIN.UserPack.Edit_Service(
        p_service_id =>22,
        p_service_type_id => 5,
        p_service_start_date => TO_DATE('2024-01-08', 'YYYY-MM-DD'),
        p_service_end_date => TO_DATE('2024-01-11', 'YYYY-MM-DD')
    );
END;
/

--2
BEGIN
    ADMIN.UserPack.Edit_Service(
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
    DBMS_OUTPUT.PUT_LINE('Стоимость проживая: '|| TO_CHAR(GUEST.CALCULATE_STAY_COST(81),'9999.99') ||'р.');
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
GUEST.Get_Service_Info (2);
END;

call GUEST.GET_STAY_COST(1);