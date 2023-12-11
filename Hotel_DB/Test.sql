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
    ADMIN.UserPack.PreBooking(
        p_room_id => 1,
        p_guest_id => 1,
        p_start_date => TO_DATE('2023-12-01', 'YYYY-MM-DD'),
        p_end_date => TO_DATE('2023-12-05', 'YYYY-MM-DD'),
        p_tariff_id => 1
    );
END;
/


BEGIN
    ADMIN.UserPack.BOOKINGNOW(
        p_room_id => 1,
        p_guest_id => 2,
        p_end_date => TO_DATE('2023-12-10', 'YYYY-MM-DD'),
        p_tariff_id => 2
    );
END;
/

DECLARE
    v_room_id NUMBER := 3; -- замените на реальный ID номера
    v_guest_id NUMBER := 3; -- замените на реальный ID гостя
    v_end_date DATE := TO_DATE('2023-12-24', 'YYYY-MM-DD'); -- укажите желаемую дату окончания
    v_tariff_id NUMBER := 4; -- замените на реальный ID тарифа
    v_booking_id NUMBER;
BEGIN
    ADMIN.UserPack.BOOKINGNOW(
        p_room_id => v_room_id,
        p_guest_id => v_guest_id,
        p_end_date => v_end_date,
        p_tariff_id => v_tariff_id,
        p_booking_id => v_booking_id
    );
    -- здесь вы можете использовать v_booking_id по вашему усмотрению
END;
/
commit;
select * from rooms;




create or replace PROCEDURE Test1
AS
BEGIN
    select USERNAME from GUESTS;
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Произошла ошибка: ' || SQLERRM);
        ROLLBACK;

END Test1;

begin
    Test1;
end;



CREATE OR REPLACE FUNCTION GetAllGuestsCursor RETURN SYS_REFCURSOR IS
    v_result_cursor SYS_REFCURSOR;
BEGIN
    OPEN v_result_cursor FOR
        SELECT * FROM GUESTS;

    RETURN v_result_cursor;
END GetAllGuestsCursor;
/

drop FUNCTION GetAllGuests;

CREATE OR REPLACE PROCEDURE GetAllGuests AS
    guest_cursor SYS_REFCURSOR;
    v_guest_info GUESTS%ROWTYPE;
BEGIN
    guest_cursor := GetAllGuestsCursor;

    LOOP
        FETCH guest_cursor INTO v_guest_info;
        EXIT WHEN guest_cursor%NOTFOUND;

        DBMS_OUTPUT.PUT_LINE('Guest ID: ' || v_guest_info.GUEST_ID ||
                             ', Email: ' || v_guest_info.GUEST_EMAIL ||
                             ', Name: ' || v_guest_info.GUEST_NAME ||
                             ', Surname: ' || v_guest_info.GUEST_SURNAME ||
                             ', Username: ' || v_guest_info.USERNAME);
    END LOOP;

    CLOSE guest_cursor;
END GetAllGuests;
/




begin
    ShowAllGuests;
end;




CREATE OR REPLACE FUNCTION GetPhoto(
    p_room_type_id IN NUMBER
) RETURN BLOB
IS
    v_photo BLOB;
BEGIN
    SELECT PHOTO_SOURCE INTO v_photo
    FROM PHOTO
    WHERE PHOTO_ROOM_TYPE_ID = p_room_type_id;
    RETURN v_photo;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('Данные не найдены');
        RETURN NULL;
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('OpenPoster: ' || SQLERRM);
        RETURN NULL;
END GetPhoto;

    select GetPhoto(1) from dual;
----------------------------------------------------------------

CREATE OR REPLACE FUNCTION GetPhotos(
    p_room_type_id IN NUMBER
) RETURN PHOTO%ROWTYPE
IS
    v_photo PHOTO%ROWTYPE;
BEGIN
    SELECT *
    INTO v_photo
    FROM PHOTO
    WHERE PHOTO_ID = p_room_type_id;

    RETURN v_photo;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('Фотографии не найдены');
        RETURN NULL;
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('GetPhotos: ' || SQLERRM);
        RETURN NULL;
END GetPhotos;
/

select * from GetPhotos(1);

