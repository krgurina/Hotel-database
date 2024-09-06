----------------------------------------------------------------
-- добавить тип комнаты
----------------------------------------------------------------
BEGIN
    HOTEL_ADMIN.InsertRoomType(
        p_room_type_name        => 'Double Room lux',
        p_room_type_capacity    => 2,
        p_room_type_daily_price => 150.0,
        p_room_type_description => 'Комфортный 2-к комнатаный номер на 2 с красивым видом'
    );
EXCEPTION
    WHEN VALUE_ERROR THEN
        DBMS_OUTPUT.PUT_LINE('Ошибка преобразования числа в строку.');
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Произошла ошибка: ' || SQLERRM);
END;

----------------------------------------------------------------
-- обновить тип комнаты
----------------------------------------------------------------
DECLARE
    v_room_type_id NUMBER(10 ):= 15;
BEGIN
    HOTEL_ADMIN.UpdateRoomType(
        p_room_type_id => v_room_type_id,
        p_new_room_type_daily_price => 150.0,
        p_new_room_type_description => 'Новое описание комнаты'
    );
        HOTEL_ADMIN.GetRoomTypes(v_room_type_id);
EXCEPTION
    WHEN VALUE_ERROR THEN
        DBMS_OUTPUT.PUT_LINE('Ошибка преобразования числа в строку.');
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Произошла ошибка: ' || SQLERRM);
END;


--2
DECLARE
    v_room_type_id NUMBER(10 ):= 15;
BEGIN
    HOTEL_ADMIN.UpdateRoomType(
        p_room_type_id => v_room_type_id,
        p_new_room_type_name => 'Новое название комнаты',
        p_new_room_type_capacity => 2,
        p_new_room_type_daily_price => 150.0,
        p_new_room_type_description => 'Новое описание комнаты'
    );
    HOTEL_ADMIN.GetRoomTypes(v_room_type_id);
EXCEPTION
    WHEN VALUE_ERROR THEN
        DBMS_OUTPUT.PUT_LINE('Ошибка преобразования числа в строку.');
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Произошла ошибка: ' || SQLERRM);
END;

----------------------------------------------------------------
-- добавить фото
----------------------------------------------------------------
begin
    HOTEL_ADMIN.InsertPhoto(
        p_photo_room_type_id => 15,
        p_photo_source => 'ph4.jpg'
    );
EXCEPTION
    WHEN VALUE_ERROR THEN
        DBMS_OUTPUT.PUT_LINE('Ошибка преобразования числа в строку.');
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Произошла ошибка: ' || SQLERRM);
END;

SELECT * FROM GET_ROOM_PHOTO WHERE PHOTO_ROOM_TYPE_ID = 15;
----------------------------------------------------------------
-- обновление фото
----------------------------------------------------------------
begin
    HOTEL_ADMIN.UpdatePhoto(
    p_photo_id=> 2,
    p_room_type_id =>1,
    p_photo_source =>'ph3.jpg'
    );
EXCEPTION
    WHEN VALUE_ERROR THEN
        DBMS_OUTPUT.PUT_LINE('Ошибка преобразования числа в строку.');
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Произошла ошибка: ' || SQLERRM);
END;

SELECT * FROM GET_ROOM_PHOTO;

----------------------------------------------------------------
-- удаление типа комнаты
----------------------------------------------------------------
BEGIN
    HOTEL_ADMIN.DeleteRoomType(
        p_room_type_id => 15
    );
EXCEPTION
    WHEN VALUE_ERROR THEN
        DBMS_OUTPUT.PUT_LINE('Ошибка преобразования числа в строку.');
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Произошла ошибка: ' || SQLERRM);
END;

SELECT * FROM GET_ROOM_PHOTO WHERE PHOTO_ROOM_TYPE_ID = 15;

----------------------------------------------------------------
-- Создание гостя
----------------------------------------------------------------
BEGIN
    HOTEL_ADMIN.InsertGuest(
        p_email => 'guest_acc12838@example.com',
        p_name => 'Кристина',
        p_surname => 'Гурина',
        p_username => 'guest9');
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Произошла ошибка: ' || SQLERRM);
END;

----------------------------------------------------------------
-- Обновление гостя
----------------------------------------------------------------
BEGIN
    HOTEL_ADMIN.UpdateGuest(
        p_guest_id => 7,
        p_email => 'guest_acc12738@example.com',
        p_name => 'Кристина',
        p_surname => 'Гурина');
EXCEPTION
    WHEN VALUE_ERROR THEN
        DBMS_OUTPUT.PUT_LINE('Ошибка преобразования числа в строку.');
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Произошла ошибка: ' || SQLERRM);
END;

----------------------------------------------------------------
-- Создание сотрудника
----------------------------------------------------------------
BEGIN
    HOTEL_ADMIN.InsertEmployee(
        p_name => 'Александра',
        p_surname => 'Смирнова',
        p_position => 'менеждер',
        p_email => 'example_empl56@email.com',
        p_hire_date => TO_DATE('2023-04-15', 'YYYY-MM-DD'),
        p_birth_date => TO_DATE('1972-02-03', 'YYYY-MM-DD'),
        p_username => 'employee12'
    );
    EXCEPTION
    WHEN VALUE_ERROR THEN
            DBMS_OUTPUT.PUT_LINE('Ошибка: Некорректное значение.');
    WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Произошла ошибка: ' || SQLERRM);
END;

----------------------------------------------------------------
-- Удаление сотрудника
----------------------------------------------------------------
BEGIN
    HOTEL_ADMIN.DeleteEmployee(
        p_employee_id =>11
    );
EXCEPTION
    WHEN VALUE_ERROR THEN
        DBMS_OUTPUT.PUT_LINE('Ошибка преобразования числа в строку.');
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Произошла ошибка: ' || SQLERRM);
END;


----------------------------------------------------------------
-- Удаление гостя
----------------------------------------------------------------
BEGIN
    HOTEL_ADMIN.DeleteGuest(
        p_employee_id =>11
    );
EXCEPTION
    WHEN VALUE_ERROR THEN
        DBMS_OUTPUT.PUT_LINE('Ошибка преобразования числа в строку.');
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Произошла ошибка: ' || SQLERRM);
END;