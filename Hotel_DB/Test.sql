--1.
BEGIN
    ADMIN.HotelAdminPackageCRUD.InsertEmployee(
    p_name => 'Виктор',
    p_surname => 'Якушик',
    p_position => 'Водитель',
    p_email => 'sdfghjk.fjdnvk@example.com',
    p_hire_date => TO_DATE('2023-02-07', 'YYYY-MM-DD'),
    p_birth_date => TO_DATE('1998-07-09', 'YYYY-MM-DD')
  );
END;
/
--c синонимом
BEGIN
    A_ADD_EMPLOYEE(
    p_name => 'Рита',
    p_surname => 'Волкова',
    p_position => 'повар',
    p_email => 'sdfghjk.fjdnvk@example.com',
    p_hire_date => TO_DATE('2022-02-07', 'YYYY-MM-DD'),
    p_birth_date => TO_DATE('1999-04-09', 'YYYY-MM-DD')
  );
END;
/

-- фото
-- declare
--     v_photo_source BLOB := EMPTY_BLOB(); -- Замените на фактический BLOB
-- BEGIN
--     HotelAdminPackageCRUD.InsertPhoto(
--         p_photo_room_type_id => 1,
--         p_photo_source => v_photo_source);
-- END;
-- /

select * from PHOTO;
select PHOTO_SOURCE from PHOTO;

--1.
BEGIN
    ADMIN.HotelAdminPackageCRUD.INSERTTARIFFTYPE(
      p_tariff_type_name =>'имя тарифа',
      p_tariff_type_description =>'описание',
      p_tariff_type_daily_price =>12.3
  );
END;


----------------------------------------------------------------
--пользователь

BEGIN
    ADMIN.UserPackageProc.PreBooking(
        p_room_id => 1,
        p_guest_id => 1,
        p_start_date => TO_DATE('2023-12-01', 'YYYY-MM-DD'),
        p_end_date => TO_DATE('2023-12-05', 'YYYY-MM-DD'),
        p_tariff_id => 1
    );
END;
/



