select * from  ALL_USERS;
SELECT * FROM GUESTS;


----------------------------------------------------------------
--1. InsertGuest
----------------------------------------------------------------
BEGIN
    ADMIN.HotelAdminPack.InsertGuest(
        p_email => 'guest2@example.com',
        p_name => 'Елизавета',
        p_surname => 'Скроцкая',
        p_username => 'user3');
END;
/



----------------------------------------------------------------
--2. InsertEmployee
----------------------------------------------------------------
BEGIN
    ADMIN.HotelAdminPack.InsertEmployee(
        p_name => 'Кристина',
        p_surname => 'Гурина',
        p_position => 'Менеджер',
        p_email => 'example_manager@email.com',
        p_hire_date => TO_DATE('2023-01-01', 'YYYY-MM-DD'),
        p_birth_date => TO_DATE('2003-09-28', 'YYYY-MM-DD'),
        p_username => 'employee2'
    );
END;
/


----------------------------------------------------------------
--3. DeleteGuestCompletely
----------------------------------------------------------------
BEGIN
    ADMIN.HotelAdminPack.DeleteGuestCompletely(2);
END;

----------------------------------------------------------------
--4. InsertGuest
----------------------------------------------------------------
BEGIN
    ADMIN.HotelAdminPack.InsertGuest(
        p_email => 'guest1@example.com',
        p_name => 'Елизавета',
        p_surname => 'Скроцкая',
        p_username => 'user1');
END;
/

----------------------------------------------------------------
--5. InsertPhoto
---------------------------------------------------------------
DECLARE
    v_photo_room_type_id NUMBER;
    v_photo_source BLOB;
    v_blob_length NUMBER;
    v_photo_blob BLOB;
BEGIN
    -- Устанавливаем ID типа комнаты
    v_photo_room_type_id := 123; -- Замените на реальное значение

    -- Загружаем содержимое файла изображения в переменную BLOB
    DBMS_LOB.createtemporary(v_photo_blob, TRUE);
    v_blob_length := DBMS_LOB.getlength(v_photo_blob);

    -- Читаем содержимое файла изображения и записываем в переменную BLOB
    DECLARE
        v_file BFILE := BFILENAME('DIRECTORY_PATH', 'image.jpg'); -- Укажите путь к вашему файлу
    BEGIN
        DBMS_LOB.fileopen(v_file, DBMS_LOB.file_readonly);
        DBMS_LOB.loadfromfile(v_photo_blob, v_file, v_blob_length);
        DBMS_LOB.fileclose(v_file);
    EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Ошибка при загрузке изображения: ' || SQLERRM);
            DBMS_LOB.fileclose(v_file);
    END;

    -- Вызываем процедуру
    ADMIN.HotelAdminPack.InsertPhoto(
        p_photo_room_type_id => v_photo_room_type_id,
        p_photo_source => v_photo_blob
    );

    -- Освобождаем временный BLOB
    DBMS_LOB.freetemporary(v_photo_blob);
END;
/
