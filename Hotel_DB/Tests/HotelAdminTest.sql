select * from  ALL_USERS;
SELECT * FROM GUESTS;


----------------------------------------------------------------
--1.2 InsertGuest
----------------------------------------------------------------
BEGIN
    ADMIN.HotelAdminPack.InsertGuest(
        p_email => 'guest2@example.com',
        p_name => 'Елизавета',
        p_surname => 'Скроцкая',
        p_username => 'user3');
END;
/

BEGIN
    ADMIN.HotelAdminPack.InsertGuest(
        p_email => 'guest6@example.com',
        p_name => 'Валерия',
        p_surname => 'Новик',
        p_username => 'user9');
END;
/

----------------------------------------------------------------
--1.2 UpdateGuest
----------------------------------------------------------------
--1
BEGIN
    ADMIN.HotelAdminPack.UpdateGuest(
        p_guest_id => 81,
        p_email => 'newemail@example.com',
        p_name => 'NewName',
        p_surname => 'NewSurname'
    );
END;
/

--2
BEGIN
    ADMIN.HotelAdminPack.UpdateGuest(
        p_guest_id => 81,
        p_email => 'newemail11111@example.com'
    );
END;
/

----------------------------------------------------------------
--1.3 DeleteGuest
----------------------------------------------------------------
BEGIN
    ADMIN.HotelAdminPack.DeleteGuest(
        p_guest_id => 81
        );
END;
/


----------------------------------------------------------------
--1.4 DeleteGuestCompletely
----------------------------------------------------------------
BEGIN
    ADMIN.HotelAdminPack.DeleteGuestCompletely(81);
END;

----------------------------------------------------------------
--2.1 InsertEmployee
----------------------------------------------------------------
BEGIN
    ADMIN.HotelAdminPack.InsertEmployee(
        p_name => 'Карина',
        p_surname => 'Макова',
        p_position => 'повар',
        p_email => 'example_manager@email.com',
        p_hire_date => TO_DATE('2023-01-01', 'YYYY-MM-DD'),
        p_birth_date => TO_DATE('2003-09-28', 'YYYY-MM-DD'),
        p_username => 'employee15'
    );

END;
/

----------------------------------------------------------------
--2.2 UpdateEmployee    работает
----------------------------------------------------------------
BEGIN
    ADMIN.HotelAdminPack.UpdateEmployee(
        p_employee_id =>2,
        p_employee_name => 'Виктория',
        p_employee_surname => 'Юркевич',
        p_employee_position => 'бармен',
        p_employee_birth_date => TO_DATE('2000-08-17', 'YYYY-MM-DD')
    );
END;
/

--2
BEGIN
    ADMIN.HotelAdminPack.UpdateEmployee(
        p_employee_id =>43,
        p_employee_surname => 'Юркевич',
        p_employee_position => 'бармен',
        p_employee_birth_date => TO_DATE('1998-06-17', 'YYYY-MM-DD')
    );
END;
/


----------------------------------------------------------------
--2.3 DeleteEmployee
----------------------------------------------------------------
BEGIN
    ADMIN.HotelAdminPack.DeleteEmployee(
        p_employee_id =>61
    );
END;
/

----------------------------------------------------------------
--3.1 InsertTariffType
----------------------------------------------------------------
BEGIN
    ADMIN.HotelAdminPack.InsertTariffType(
        p_tariff_type_name => 'Название тарифа2',
        p_tariff_type_description => 'Описание тарифа',
        p_tariff_type_daily_price => 200.0
    );
END;
/


----------------------------------------------------------------
--3.2 UpdateTariffType
----------------------------------------------------------------
--1
BEGIN
    ADMIN.HotelAdminPack.UpdateTariffType(
        p_tariff_type_id => 22,
        p_tariff_type_name => 'Название тарифа2',
        p_tariff_type_description => 'Описание тарифа22',
        p_tariff_type_daily_price => 220.0
    );
END;
/
--2
BEGIN
    ADMIN.HotelAdminPack.UpdateTariffType(
        p_tariff_type_id => 22,
        p_tariff_type_description => 'Описание тарифа11122'
    );
END;
/
----------------------------------------------------------------
--3.3 DeleteTariffType
----------------------------------------------------------------
BEGIN
    ADMIN.HotelAdminPack.DeleteTariffType(
        p_tariff_type_id => 22
    );
END;
/

----------------------------------------------------------------
--4.1 InsertServiceType
----------------------------------------------------------------
BEGIN
    ADMIN.HotelAdminPack.InsertServiceType(
        p_name => 'ServiceTypeName',
        p_description => 'ServiceTypeDescription',
        p_daily_price => 100.00,
        p_employee_id => 23);
END;
/

----------------------------------------------------------------
--4.2 UpdateServiceType
----------------------------------------------------------------
--1
BEGIN
    ADMIN.HotelAdminPack.UpdateServiceType(
        p_service_type_id => 4,
        p_name => 'Service1111',
        p_description => 'ServiceTypeD111tion',
        p_daily_price => 100.00,
        p_employee_id => 23);
END;
/

--2
BEGIN
    ADMIN.HotelAdminPack.UpdateServiceType(
        p_service_type_id => 4,
        p_daily_price => 111.00);
END;
/

----------------------------------------------------------------
--4.3 DeleteServiceType
----------------------------------------------------------------
BEGIN
    ADMIN.HotelAdminPack.DeleteServiceType(
        p_service_type_id => 4
        );
END;
/


----------------------------------------------------------------
--5.1 InsertService     // добавить: нельяза заказать сервис если нет брони и если дата сервиса не попадает в интрервал сервиса
----------------------------------------------------------------
BEGIN
    ADMIN.HotelAdminPack.InsertService(
        p_service_type_id => 5,
        p_service_guest_id => 87,
        p_service_start_date => TO_DATE('2024-01-08', 'YYYY-MM-DD'),
        p_service_end_date => TO_DATE('2024-01-09', 'YYYY-MM-DD')
    );
END;
/

----------------------------------------------------------------
--5.2 UpdateService     // баг с датами
----------------------------------------------------------------
BEGIN
    ADMIN.HotelAdminPack.UpdateService(
        p_service_id =>9,
        p_service_type_id => 5,
        p_service_guest_id => 87,
        p_service_start_date => TO_DATE('2024-01-08', 'YYYY-MM-DD'),
        p_service_end_date => TO_DATE('2024-01-09', 'YYYY-MM-DD')
    );
END;
/

--2
BEGIN
    ADMIN.HotelAdminPack.UpdateService(
        p_service_id =>9,
        p_service_start_date => TO_DATE('2024-01-10', 'YYYY-MM-DD')
    );
END;
/


----------------------------------------------------------------
--5.3 DeleteServiceType
----------------------------------------------------------------
BEGIN
    ADMIN.HotelAdminPack.DeleteService(
        p_service_id =>9
    );
END;
/

----------------------------------------------------------------
--6.1 InsertPhoto
----------------------------------------------------------------
create directory MEDIA_DIR as 'E:\CourseProj\photo';

begin
    ADMIN.HotelAdminPack.InsertPhoto(
        p_photo_room_type_id => 1,
        p_photo_source => 'ph1.jpg'
    );
end;

select PHOTO_SOURCE from Photo where photo_id=1;

----------------------------------------------------------------
--6.2 UpdatePhoto   // не работает
----------------------------------------------------------------
select * from Photo;

begin
    ADMIN.HotelAdminPack.UpdatePhoto(
    p_photo_id=> 2,
    p_room_type_id =>1,
    p_photo_source =>'ph22.jpg'
    );
end;


----------------------------------------------------------------
--6.3 DeletePhoto
----------------------------------------------------------------
begin
    ADMIN.HotelAdminPack.DeletePhoto(
    p_photo_id=> 1
    );
end;


----------------------------------------------------------------
--7.1. InsertRoomType
----------------------------------------------------------------
BEGIN
    Admin.HotelAdminPack.InsertRoomType(
        p_room_type_name        => 'Double Room',
        p_room_type_capacity    => 2,
        p_room_type_daily_price => 150.0,
        p_room_type_description => 'Комфортная комната на 2 с красивым видом'
    );
END;
/


----------------------------------------------------------------
--7.2. UpdateRoomType +
----------------------------------------------------------------
--1
BEGIN
    Admin.HotelAdminPack.UpdateRoomType(
        p_room_type_id => 21,
        p_new_room_type_name => 'Новое название комнаты',
        p_new_room_type_capacity => 2,
        p_new_room_type_daily_price => 150.0,
        p_new_room_type_description => 'Новое описание комнаты'
    );
END;
/

--2
BEGIN
    Admin.HotelAdminPack.UpdateRoomType(
        p_room_type_id => 21,
        p_new_room_type_capacity => 2,
        p_new_room_type_description => 'хорошая комната'
    );
END;
/
----------------------------------------------------------------
--7.3. DeleteRoomType +
----------------------------------------------------------------
BEGIN
    Admin.HotelAdminPack.DeleteRoomType(
        p_room_type_id => 21
    );
END;
/

----------------------------------------------------------------
--8.1 InsertRoom
----------------------------------------------------------------
begin
    ADMIN.HotelAdminPack.InsertRoom(
    p_room_room_type_id=>4,
    p_room_number=>404);
end;

----------------------------------------------------------------
--8.2 UpdateRoom
----------------------------------------------------------------
begin
    Admin.HotelAdminPack.UpdateRoom(
        p_room_id=>1,
        p_room_room_type_id=>1,
        p_room_number=>111
        );
end;

begin
    Admin.HotelAdminPack.UpdateRoom(
        p_room_id       => 1,
        p_room_number   =>112
        );
end;
/

----------------------------------------------------------------
--8.3 DeleteRoom
----------------------------------------------------------------
begin
    Admin.HotelAdminPack.DeleteRoom(
        p_room_id       => 1
        );
end;
/

----------------------------------------------------------------
--9.1 InsertBooking
----------------------------------------------------------------
BEGIN
    Admin.HotelAdminPack.InsertBooking(
        p_room_id => 3,
        p_guest_id => 86,
        p_start_date => TO_DATE('2024-12-01', 'YYYY-MM-DD'),
        p_end_date => TO_DATE('2024-12-10', 'YYYY-MM-DD'),
        p_tariff_id => 1,
        p_booking_state => 3
    );
END;


----------------------------------------------------------------
--9.2 UpdateBooking
----------------------------------------------------------------
--1
BEGIN
    Admin.HotelAdminPack.UpdateBooking(
        p_booking_id =>21,
        p_room_id => 3,
        p_guest_id => 86,
        p_start_date => TO_DATE('2024-12-01', 'YYYY-MM-DD'),
        p_end_date => TO_DATE('2024-12-10', 'YYYY-MM-DD'),
        p_tariff_id => 1,
        p_booking_state => 3
    );
END;

--2
BEGIN
    Admin.HotelAdminPack.UpdateBooking(
        p_booking_id =>21,
        p_start_date => TO_DATE('2024-12-01', 'YYYY-MM-DD'),
        p_end_date => TO_DATE('2024-12-12', 'YYYY-MM-DD'),
        p_tariff_id => 2
    );
END;
----------------------------------------------------------------
--9.3 Delete
----------------------------------------------------------------
BEGIN
    Admin.HotelAdminPack.DeleteBooking(
        p_booking_id =>21
    );
END;

----------------------------------------------------------------
-- 1
begin
    HOTEL_ADMIN.GetGuests;
end;


---------------------------------------------------------------------------------------------------------------------------------
begin
    HOTEL_ADMIN.GetEmployees;
end;

begin
    ADMIN.HotelAdminPack.GetEmployees(1);
end;