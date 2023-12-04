CREATE OR REPLACE PACKAGE HotelAdminPack AS
    -- 1. работник
    PROCEDURE InsertEmployee(
        p_name NVARCHAR2,
        p_surname NVARCHAR2,
        p_position NVARCHAR2,
        p_email NVARCHAR2,
        p_hire_date DATE,
        p_birth_date DATE,
        p_username NVARCHAR2);

    PROCEDURE UpdateEmployee(
        p_employee_id NUMBER,
        p_employee_name NVARCHAR2,
        p_employee_surname NVARCHAR2,
        p_employee_position NVARCHAR2,
        p_employee_email NVARCHAR2,
        p_employee_hire_date DATE,
        p_employee_birth_date DATE);
    PROCEDURE DeleteEmployee(p_employee_id NUMBER);

    --2. гость
    PROCEDURE InsertGuest(
        p_email NVARCHAR2,
        p_name NVARCHAR2,
        p_surname NVARCHAR2,
        p_username NVARCHAR2);
    PROCEDURE UpdateGuest(
        p_guest_id NUMBER,
        p_email NVARCHAR2,
        p_name NVARCHAR2,
        p_surname NVARCHAR2);
    PROCEDURE DeleteGuest(p_guest_id NUMBER);

    --3. тип комнаты
    PROCEDURE InsertRoomType(
        p_room_type_name NVARCHAR2,
        p_room_type_capacity NUMBER,
        p_room_type_daily_price FLOAT,
        p_room_type_description NVARCHAR2);
    PROCEDURE UpdateRoomType(
        p_room_type_id NUMBER,
        p_new_room_type_name NVARCHAR2,
        p_new_room_type_capacity NUMBER,
        p_new_room_type_daily_price FLOAT,
        p_new_room_type_description NVARCHAR2);
    PROCEDURE DeleteRoomType(p_room_type_id NUMBER);

    --4. тариф
    PROCEDURE InsertTariffType(
      p_tariff_type_name        NVARCHAR2,
      p_tariff_type_description NVARCHAR2,
      p_tariff_type_daily_price FLOAT);
    PROCEDURE UpdateTariffType(
      p_tariff_type_id          NUMBER,
      p_new_tariff_type_name    NVARCHAR2,
      p_new_tariff_type_description NVARCHAR2,
      p_new_tariff_type_daily_price FLOAT);
    PROCEDURE DeleteTariffType (p_tariff_type_id NUMBER);

    --5. тип сервиса
    PROCEDURE InsertServiceType(
    p_name NVARCHAR2,
    p_description NVARCHAR2,
    p_daily_price FLOAT,
    p_employee_id NUMBER);
    PROCEDURE UpdateServiceType(
    p_service_type_id NUMBER,
    p_name NVARCHAR2,
    p_description NVARCHAR2,
    p_daily_price FLOAT,
    p_employee_id NUMBER);
    PROCEDURE DeleteServiceType(p_service_type_id NUMBER);

    --6. фото
    PROCEDURE InsertPhoto(
    p_photo_room_type_id NUMBER,
    p_photo_source BLOB);
    PROCEDURE UpdatePhoto(
    p_photo_id NUMBER,
    p_photo_room_type_id NUMBER,
    p_photo_source BLOB);
    PROCEDURE DeletePhoto(p_photo_id NUMBER);

    --7. комната
    PROCEDURE InsertRoom(
        p_room_room_type_id NUMBER,
        p_room_number NVARCHAR2);
    PROCEDURE UpdateRoom(
        p_room_id NUMBER,
        p_room_room_type_id NUMBER,
        p_room_number NVARCHAR2);
    PROCEDURE DeleteRoom(p_room_id NUMBER);

    --8. сервис
PROCEDURE InsertService(
    p_service_type_id NUMBER,
    p_service_guest_id NUMBER,
    p_service_start_date DATE,
    p_service_end_date DATE);
    PROCEDURE UpdateService(
    p_service_id NUMBER,
    p_service_type_id NUMBER,
    p_service_guest_id NUMBER,
    p_service_start_date DATE,
    p_service_end_date DATE);
PROCEDURE DeleteService(p_service_id NUMBER);

    --9. бронь
    PROCEDURE InsertBooking(
        p_booking_room_id NUMBER,
        p_booking_guest_id NUMBER,
        p_booking_start_date DATE,
        p_booking_end_date DATE,
        p_booking_tariff_id NUMBER,
        p_booking_state NUMBER DEFAULT 1);
    PROCEDURE UpdateBooking(
        p_booking_id NUMBER,
        p_booking_room_id NUMBER,
        p_booking_guest_id NUMBER,
        p_booking_start_date DATE,
        p_booking_end_date DATE,
        p_booking_tariff_id NUMBER,
        p_booking_state NUMBER);

    PROCEDURE DeleteBooking(p_booking_id NUMBER);

    PROCEDURE DeleteGuestCompletely(p_guest_id NUMBER);

END HotelAdminPack;
/

CREATE OR REPLACE PACKAGE BODY HotelAdminPack AS
-- ****************************************************************
-- работник
-- ****************************************************************
-- добавить работника
 PROCEDURE InsertEmployee(
    p_name NVARCHAR2,
    p_surname NVARCHAR2,
    p_position NVARCHAR2,
    p_email NVARCHAR2,
    p_hire_date DATE,
    p_birth_date DATE,
    p_username NVARCHAR2)
AS
    v_current_date DATE := SYSDATE;
    v_min_age CONSTANT NUMBER := 18;
    v_username_exists NUMBER;
BEGIN
    SELECT COUNT(*) INTO v_username_exists FROM ALL_USERS
    WHERE USERNAME = UPPER(p_username);

    IF v_username_exists > 0 THEN
        RAISE_APPLICATION_ERROR(-20002,'Ошибка: Пользователь с таким именем ' || p_username || ' уже существует.');
    END IF;

    IF p_hire_date > v_current_date THEN
        RAISE_APPLICATION_ERROR(-20001, 'Дата найма не может быть больше текущей даты.');
    END IF;

    IF MONTHS_BETWEEN(v_current_date, p_birth_date) < v_min_age * 12 THEN
        RAISE_APPLICATION_ERROR(-20002, 'Работнику должно быть не менее 18 лет.');
    END IF;

    IF REGEXP_LIKE(p_email, '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Z|a-z]{2,4}$') = FALSE THEN
        RAISE_APPLICATION_ERROR(-20003, 'Неправильный формат email.');
    END IF;

    INSERT INTO EMPLOYEES (
        employee_name,
        employee_surname,
        employee_position,
        employee_email,
        employee_hire_date,
        employee_birth_date,
        username
    ) VALUES (
        p_name,
        p_surname,
        p_position,
        p_email,
        p_hire_date,
        p_birth_date,
        p_username
    );
    COMMIT;
     EXECUTE IMMEDIATE 'CREATE USER ' || p_username ||
                      ' IDENTIFIED BY ' || p_username ||
                      ' DEFAULT TABLESPACE HOTEL_TS' ||
                      ' TEMPORARY TABLESPACE HOTEL_TEMP_TS';

    EXECUTE IMMEDIATE 'GRANT Employee_role TO ' || p_username;
    DBMS_OUTPUT.PUT_LINE('Работник успешно добавлен. Ваш логин: '|| p_username || ' Пароль: '|| p_username);

EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Произошла ошибка: ' || SQLERRM);
        ROLLBACK;
END InsertEmployee;


-- изменить рабоника
PROCEDURE UpdateEmployee(
    p_employee_id NUMBER,
    p_employee_name NVARCHAR2,
    p_employee_surname NVARCHAR2,
    p_employee_position NVARCHAR2,
    p_employee_email NVARCHAR2,
    p_employee_hire_date DATE,
    p_employee_birth_date DATE)
AS
    v_current_date DATE := SYSDATE;
    v_min_age CONSTANT NUMBER := 18;
    v_employee_count NUMBER;
BEGIN
    SELECT COUNT(*) INTO v_employee_count
    FROM EMPLOYEES
    WHERE employee_id = p_employee_id;

    IF v_employee_count = 0 THEN
        RAISE_APPLICATION_ERROR(-20001, 'Работник с указанным ID не найден.');
    END IF;

    IF p_employee_hire_date > SYSDATE THEN
        RAISE_APPLICATION_ERROR(-20002, 'Дата найма не может быть больше текущей даты.');
    END IF;

    IF MONTHS_BETWEEN(v_current_date,  p_employee_birth_date) < v_min_age * 12 THEN
        RAISE_APPLICATION_ERROR(-20002, 'Работнику должно быть не менее 18 лет.');
    END IF;

    UPDATE EMPLOYEES
    SET
        employee_name = p_employee_name,
        employee_surname = p_employee_surname,
        employee_position = p_employee_position,
        employee_email = p_employee_email,
        employee_hire_date = p_employee_hire_date,
        employee_birth_date = p_employee_birth_date
    WHERE employee_id = p_employee_id;
    COMMIT;
    DBMS_OUTPUT.PUT_LINE('Работник успешно обновлен.');

EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Произошла ошибка: ' || SQLERRM);
        ROLLBACK;
END UpdateEmployee;



-- удалить работника
PROCEDURE DeleteEmployee(p_employee_id NUMBER)
AS
    v_employee_count NUMBER;
BEGIN
    SELECT COUNT(*) INTO v_employee_count
    FROM EMPLOYEES
    WHERE employee_id = p_employee_id;

    IF v_employee_count = 0 THEN
        RAISE_APPLICATION_ERROR(-20001, 'Работник с указанным ID не найден.');
    END IF;

    DELETE FROM EMPLOYEES WHERE employee_id = p_employee_id;
    COMMIT;

    DBMS_OUTPUT.PUT_LINE('Работник успешно удален.');

EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Произошла ошибка: ' || SQLERRM);
        ROLLBACK;
END DeleteEmployee;


-- ****************************************************************
-- ГОСТЬ
-- ****************************************************************

--создать гостя
PROCEDURE InsertGuest(
    p_email NVARCHAR2,
    p_name NVARCHAR2,
    p_surname NVARCHAR2,
    p_username NVARCHAR2
)
AS
    v_username_exists NUMBER;
BEGIN
    SELECT COUNT(*) INTO v_username_exists FROM ALL_USERS
    WHERE USERNAME = UPPER(p_username);

    IF v_username_exists > 0 THEN
        RAISE_APPLICATION_ERROR(-20002,'Ошибка: Пользователь с таким именем ' || p_username || ' уже существует.');
    END IF;

    IF REGEXP_LIKE(p_email, '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Z|a-z]{2,4}$') = FALSE THEN
        RAISE_APPLICATION_ERROR(-20002, 'Неправильный формат email.');
    END IF;

    INSERT INTO GUESTS (guest_email, guest_name, guest_surname, USERNAME)
    VALUES (p_email, p_name, p_surname,p_username);
    COMMIT;

    EXECUTE IMMEDIATE 'CREATE USER ' || p_username ||
                      ' IDENTIFIED BY ' || p_username ||
                      ' DEFAULT TABLESPACE HOTEL_TS' ||
                      ' TEMPORARY TABLESPACE HOTEL_TEMP_TS';

    EXECUTE IMMEDIATE 'GRANT Guest_role TO ' || p_username;

    DBMS_OUTPUT.PUT_LINE('Гость успешно создан. Ваш логин: '|| p_username || 'Пароль: '|| p_username);

EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Произошла ошибка: ' || SQLERRM);
        ROLLBACK;
END InsertGuest;


--изменить гостя
PROCEDURE UpdateGuest(
    p_guest_id NUMBER,
    p_email NVARCHAR2,
    p_name NVARCHAR2,
    p_surname NVARCHAR2)
AS
    v_guest_count NUMBER;
BEGIN
    SELECT COUNT(*) INTO v_guest_count
    FROM GUESTS
    WHERE guest_id = p_guest_id;

    IF v_guest_count = 0 THEN
        RAISE_APPLICATION_ERROR(-20001, 'Гость с указанным ID не найден.');
    END IF;

    IF REGEXP_LIKE(p_email, '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Z|a-z]{2,4}$') = FALSE THEN
        RAISE_APPLICATION_ERROR(-20003, 'Неправильный формат email.');
    END IF;

    UPDATE GUESTS
    SET
        guest_email = p_email,
        guest_name = p_name,
        guest_surname = p_surname
    WHERE
        guest_id = p_guest_id;
    COMMIT;

    DBMS_OUTPUT.PUT_LINE('Информация о госте успешно обновлена.');

EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Произошла ошибка: ' || SQLERRM);
        ROLLBACK;
        --RAISE; -- Повторное возбуждение исключения для передачи его вызывающему коду
END UpdateGuest;


--удалить гостя
PROCEDURE DeleteGuest(p_guest_id NUMBER)
AS
    v_guest_count NUMBER;
BEGIN
    SELECT COUNT(*) INTO v_guest_count
    FROM GUESTS
    WHERE guest_id = p_guest_id;

    IF v_guest_count = 0 THEN
        RAISE_APPLICATION_ERROR(-20001, 'Гость с указанным ID не найден.');
    END IF;

    DELETE FROM GUESTS WHERE guest_id = p_guest_id;
    COMMIT;
      DBMS_OUTPUT.PUT_LINE('Гость успешно удален.');

EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Произошла ошибка: ' || SQLERRM);
        ROLLBACK;
END DeleteGuest;




-- ************************************
-- ROOM TYPE
-- ************************************
--создать тип комнаты
PROCEDURE InsertRoomType(
  p_room_type_name        NVARCHAR2,
  p_room_type_capacity    NUMBER,
  p_room_type_daily_price FLOAT,
  p_room_type_description NVARCHAR2
) AS
    existing_count NUMBER;
BEGIN
    IF p_room_type_capacity < 0 THEN
        RAISE_APPLICATION_ERROR(-20002, 'Вместимость типа комнаты должна быть больше 0.');
    END IF;

    IF p_room_type_daily_price <= 0 THEN
        RAISE_APPLICATION_ERROR(-20003, 'Ежедневная стоимость типа комнаты должна быть больше 0.');
    END IF;

    SELECT COUNT(*) INTO existing_count FROM ROOM_TYPES
        WHERE ROOM_TYPE_NAME = p_room_type_name AND ROOM_TYPE_CAPACITY=p_room_type_capacity;
    IF existing_count > 0 THEN
        RAISE_APPLICATION_ERROR(-20005, 'Тип комнаты с таким именем уже существует.');
    END IF;

    INSERT INTO ROOM_TYPES (room_type_name, room_type_capacity, room_type_daily_price, room_type_description)
    VALUES (p_room_type_name, p_room_type_capacity, p_room_type_daily_price, p_room_type_description);
    COMMIT;
    DBMS_OUTPUT.PUT_LINE('Тип комнаты успешно создан.');
EXCEPTION
    WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('Произошла ошибка: ' || SQLERRM);
    ROLLBACK;
END InsertRoomType;


--изменить тип комнаты
PROCEDURE UpdateRoomType(
  p_room_type_id NUMBER,
  p_new_room_type_name NVARCHAR2,
  p_new_room_type_capacity NUMBER,
  p_new_room_type_daily_price FLOAT,
  p_new_room_type_description NVARCHAR2
) AS
  existing_count NUMBER;
BEGIN
    SELECT COUNT(*) INTO existing_count FROM ROOM_TYPES
        WHERE room_type_id = p_room_type_id;
    IF existing_count = 0 THEN
        RAISE_APPLICATION_ERROR(-20001, 'Тип комнаты с указанным ID не существует.');
    END IF;

    IF p_new_room_type_capacity <= 0 THEN
        RAISE_APPLICATION_ERROR(-20003, 'Новая вместимость типа комнаты должна быть больше 0.');
    END IF;

    IF p_new_room_type_daily_price <= 0 THEN
        RAISE_APPLICATION_ERROR(-20004, 'Новая ежедневная стоимость типа комнаты должна быть больше 0.');
    END IF;

    UPDATE ROOM_TYPES
    SET
        room_type_name = p_new_room_type_name,
        room_type_capacity = p_new_room_type_capacity,
        room_type_daily_price = p_new_room_type_daily_price,
        room_type_description = p_new_room_type_description
    WHERE room_type_id = p_room_type_id;
    COMMIT;
    DBMS_OUTPUT.PUT_LINE('Тип комнаты успешно обновлен.');
EXCEPTION
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('Произошла ошибка: ' || SQLERRM);
    ROLLBACK;
END UpdateRoomType;


--удалить тип комнаты
PROCEDURE DeleteRoomType(p_room_type_id NUMBER)
AS
    v_room_type_count NUMBER;
BEGIN
    SELECT COUNT(*) INTO v_room_type_count
    FROM ROOM_TYPES
    WHERE room_type_id = p_room_type_id;

    IF v_room_type_count = 0 THEN
        RAISE_APPLICATION_ERROR(-20001, 'Тип комнаты с указанным ID не найден.');
    END IF;

    DELETE FROM ROOM_TYPES WHERE room_type_id = p_room_type_id;
    COMMIT;
      DBMS_OUTPUT.PUT_LINE('Тип комнаты успешно удален.');

EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Произошла ошибка: ' || SQLERRM);
        ROLLBACK;
END DeleteRoomType;


-- ****************************************************************
-- TARIFF TYPE
-- ****************************************************************
--создать тип тарифа
PROCEDURE InsertTariffType(
  p_tariff_type_name        NVARCHAR2,
  p_tariff_type_description NVARCHAR2,
  p_tariff_type_daily_price FLOAT
) AS
  v_existing_count NUMBER;

BEGIN
    IF p_tariff_type_daily_price <= 0 THEN
        RAISE_APPLICATION_ERROR(-20002, 'Ежедневная цена тарифа должна быть больше 0.');
    END IF;

  -- Проверка наличия такого же тарифа
    SELECT COUNT(*) INTO v_existing_count FROM TARIFF_TYPES
    WHERE tariff_type_name = p_tariff_type_name;

    IF v_existing_count > 0 THEN
        RAISE_APPLICATION_ERROR(-20004, 'Тариф с таким именем уже существует.');
    END IF;

    INSERT INTO TARIFF_TYPES (tariff_type_name, tariff_type_description, tariff_type_daily_price)
    VALUES (p_tariff_type_name, p_tariff_type_description, p_tariff_type_daily_price);
    COMMIT;
  DBMS_OUTPUT.PUT_LINE('Тариф успешно добавлен.');
EXCEPTION
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('Произошла ошибка: ' || SQLERRM);
    ROLLBACK;
END InsertTariffType;


--изменить тип тарифа
PROCEDURE UpdateTariffType(
  p_tariff_type_id          NUMBER,
  p_new_tariff_type_name    NVARCHAR2,
  p_new_tariff_type_description NVARCHAR2,
  p_new_tariff_type_daily_price FLOAT
) AS
  v_existing_count NUMBER;

BEGIN
    SELECT COUNT(*) INTO v_existing_count FROM TARIFF_TYPES
    WHERE tariff_type_id = p_tariff_type_id;

    IF v_existing_count = 0 THEN
        RAISE_APPLICATION_ERROR(-20001, 'Тариф с указанным ID не существует.');
    END IF;

    IF p_new_tariff_type_daily_price <= 0 THEN
        RAISE_APPLICATION_ERROR(-20003, 'Новая ежедневная цена тарифа должна быть больше 0.');
    END IF;

  -- Проверка наличия такого же тарифа
    SELECT COUNT(*) INTO v_existing_count FROM TARIFF_TYPES
    WHERE tariff_type_name = p_new_tariff_type_name
    AND tariff_type_id != p_tariff_type_id;

    IF v_existing_count > 0 THEN
        RAISE_APPLICATION_ERROR(-20005, 'Тариф с таким именем уже существует.');
    END IF;

  -- Обновление данных тарифа
  UPDATE TARIFF_TYPES
  SET
    tariff_type_name = p_new_tariff_type_name,
    tariff_type_description = p_new_tariff_type_description,
    tariff_type_daily_price = p_new_tariff_type_daily_price
  WHERE tariff_type_id = p_tariff_type_id;
  COMMIT;
  DBMS_OUTPUT.PUT_LINE('Тариф успешно обновлен.');
EXCEPTION
  WHEN OTHERS THEN
    -- Обработка других ошибок
    DBMS_OUTPUT.PUT_LINE('Произошла ошибка: ' || SQLERRM);
    ROLLBACK;
END UpdateTariffType;



--удалить тип тарифа
PROCEDURE DeleteTariffType(
  p_tariff_type_id NUMBER
) AS
  v_existing_count NUMBER;

BEGIN
  SELECT COUNT(*) INTO v_existing_count
  FROM TARIFF_TYPES
  WHERE tariff_type_id = p_tariff_type_id;

  IF v_existing_count = 0 THEN
    RAISE_APPLICATION_ERROR(-20001, 'Тариф с указанным ID не существует.');
  END IF;

    DELETE FROM TARIFF_TYPES WHERE tariff_type_id = p_tariff_type_id;
    COMMIT;
    DBMS_OUTPUT.PUT_LINE('Тариф успешно удален.');
EXCEPTION
    WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('Ошибка: ' || SQLERRM);
    ROLLBACK;
END DeleteTariffType;



-- ****************************************************************
-- ТИП СЕРВИСА
-- ****************************************************************
--создать тип сервиса
PROCEDURE InsertServiceType(
    p_name NVARCHAR2,
    p_description NVARCHAR2,
    p_daily_price FLOAT,
    p_employee_id NUMBER)
AS
    v_employee_count NUMBER;

BEGIN
    SELECT COUNT(*) INTO v_employee_count
    FROM EMPLOYEES
    WHERE employee_id = p_employee_id;

    IF v_employee_count = 0 THEN
        RAISE_APPLICATION_ERROR(-20001, 'Работник с указанным ID не найден.');
    END IF;

    INSERT INTO SERVICE_TYPES (
        service_type_name,
        service_type_description,
        service_type_daily_price,
        service_type_employee_id)
    VALUES (
        p_name,
        p_description,
        p_daily_price,
        p_employee_id);
    COMMIT;
    DBMS_OUTPUT.PUT_LINE('Тип сервиса успешно создан.');
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Произошла ошибка: ' || SQLERRM);
        ROLLBACK;
END InsertServiceType;


--изменить тип сервиса
PROCEDURE UpdateServiceType(
    p_service_type_id NUMBER,
    p_name NVARCHAR2,
    p_description NVARCHAR2,
    p_daily_price FLOAT,
    p_employee_id NUMBER)
AS
    v_employee_count NUMBER;
    v_service_type_count NUMBER;

BEGIN

    SELECT COUNT(*) INTO v_service_type_count
        FROM service_types
        WHERE service_type_id = p_service_type_id;
    IF v_service_type_count = 0 THEN
        RAISE_APPLICATION_ERROR(-20001, 'Тип сервиса с указанным ID не найден.');
    END IF;

    SELECT COUNT(*) INTO v_employee_count
    FROM EMPLOYEES
    WHERE employee_id = p_employee_id;
    IF v_employee_count = 0 THEN
        RAISE_APPLICATION_ERROR(-20001, 'Работник с указанным ID не найден.');
    END IF;

    UPDATE SERVICE_TYPES
    SET
        service_type_name = p_name,
        service_type_description = p_description,
        service_type_daily_price = p_daily_price,
        service_type_employee_id = p_employee_id
    WHERE service_type_id = p_service_type_id;
    COMMIT;
      DBMS_OUTPUT.PUT_LINE('Тип сервиса успешно обновлен.');

EXCEPTION
    WHEN OTHERS THEN
        -- Логирование или обработка других ошибок, если необходимо
        DBMS_OUTPUT.PUT_LINE('Произошла ошибка: ' || SQLERRM);
        ROLLBACK;
END UpdateServiceType;


--удалить тип сервиса
PROCEDURE DeleteServiceType(p_service_type_id NUMBER)
AS
    v_service_type_count NUMBER;
BEGIN
    SELECT COUNT(*) INTO v_service_type_count
        FROM service_types
        WHERE service_type_id = p_service_type_id;
    IF v_service_type_count = 0 THEN
        RAISE_APPLICATION_ERROR(-20001, 'Тип сервиса с указанным ID не найден.');
    END IF;

    DELETE FROM SERVICE_TYPES WHERE service_type_id = p_service_type_id;
    COMMIT;
    DBMS_OUTPUT.PUT_LINE('Тип сервиса успешно удален.');

EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Произошла ошибка: ' || SQLERRM);
        ROLLBACK;
END DeleteServiceType;




-- ****************************************************************
-- ФОТО
-- ****************************************************************
-- --создать галерею фото
PROCEDURE InsertPhoto(
    p_photo_room_type_id NUMBER,
    p_photo_source BLOB)
AS
        v_room_type_count NUMBER;

BEGIN
    SELECT COUNT(*) INTO v_room_type_count
        FROM ROOM_TYPES
        WHERE room_type_id = p_photo_room_type_id;
    IF v_room_type_count = 0 THEN
        RAISE_APPLICATION_ERROR(-20001, 'Тип комнаты с указанным ID не найден.');
    END IF;

    INSERT INTO PHOTO (photo_room_type_id, photo_source)
    VALUES (p_photo_room_type_id, p_photo_source);
    COMMIT;
    DBMS_OUTPUT.PUT_LINE('Фото успешно добавлено.');

EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Произошла ошибка: ' || SQLERRM);
        ROLLBACK;
END InsertPhoto;



--изменить галерею фото
PROCEDURE UpdatePhoto(
    p_photo_id NUMBER,
    p_photo_room_type_id NUMBER,
    p_photo_source BLOB)
AS
    v_room_type_count NUMBER;
    v_photo_count NUMBER;

BEGIN

    SELECT COUNT(*) INTO v_photo_count
        FROM PHOTO
        WHERE photo_id = p_photo_id;
    IF v_photo_count = 0 THEN
        RAISE_APPLICATION_ERROR(-20001, 'Фото с указанным ID не найдено.');
    END IF;


        SELECT COUNT(*) INTO v_room_type_count
        FROM ROOM_TYPES
        WHERE room_type_id = p_photo_room_type_id;
    IF v_room_type_count = 0 THEN
        RAISE_APPLICATION_ERROR(-20001, 'Тип комнаты с указанным ID не найден.');
    END IF;

    UPDATE PHOTO
    SET photo_room_type_id = p_photo_room_type_id,
        photo_source = p_photo_source
    WHERE photo_id = p_photo_id;
    COMMIT;
    DBMS_OUTPUT.PUT_LINE('Фото успешно обновлено.');

EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Произошла ошибка: ' || SQLERRM);
        ROLLBACK;
END UpdatePhoto;


--удалить галерею фото
PROCEDURE DeletePhoto(p_photo_id NUMBER)
AS
    v_photo_count NUMBER;
BEGIN
    SELECT COUNT(*) INTO v_photo_count
        FROM PHOTO
        WHERE photo_id = p_photo_id;
    IF v_photo_count = 0 THEN
        RAISE_APPLICATION_ERROR(-20001, 'Фото с указанным ID не найдено.');
    END IF;

    DELETE FROM PHOTO WHERE photo_id = p_photo_id;
    COMMIT;
    DBMS_OUTPUT.PUT_LINE('Фото успешно удалено.');

EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Произошла ошибка: ' || SQLERRM);
        ROLLBACK;
END DeletePhoto;


-- ****************************************************************
-- ROOM
-- ****************************************************************

--создать комнату
PROCEDURE InsertRoom(
    p_room_room_type_id NUMBER,
    p_room_number NVARCHAR2)
AS
    v_room_type_count NUMBER;

BEGIN
    SELECT COUNT(*) INTO v_room_type_count
        FROM ROOM_TYPES
        WHERE room_type_id = p_room_room_type_id;
    IF v_room_type_count = 0 THEN
        RAISE_APPLICATION_ERROR(-20001, 'Тип комнаты с указанным ID не найден.');
    END IF;

    INSERT INTO ROOMS (room_room_type_id, room_number)
    VALUES (p_room_room_type_id, p_room_number);
    COMMIT;
    DBMS_OUTPUT.PUT_LINE('Комната успешно добавлена.');

EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Произошла ошибка: ' || SQLERRM);
        ROLLBACK;
END InsertRoom;


--изменить комнату
PROCEDURE UpdateRoom(
    p_room_id NUMBER,
    p_room_room_type_id NUMBER,
    p_room_number NVARCHAR2)
AS
    v_room_type_count NUMBER;
    v_room_count NUMBER;

BEGIN

    SELECT COUNT(*) INTO v_room_count
        FROM ROOMS
        WHERE room_id = p_room_id;
    IF v_room_count = 0 THEN
        RAISE_APPLICATION_ERROR(-20001, 'Комната с указанным ID не найдено.');
    END IF;

    SELECT COUNT(*) INTO v_room_type_count
        FROM ROOM_TYPES
        WHERE room_type_id = p_room_room_type_id;
    IF v_room_type_count = 0 THEN
        RAISE_APPLICATION_ERROR(-20001, 'Тип комнаты с указанным ID не найден.');
    END IF;

    UPDATE ROOMS
    SET room_room_type_id = p_room_room_type_id,
        room_number = p_room_number
    WHERE room_id = p_room_id;
    COMMIT;
    DBMS_OUTPUT.PUT_LINE('Комната успешно обновлена.');

EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Произошла ошибка: ' || SQLERRM);
        ROLLBACK;
END UpdateRoom;


--удалить комнату
PROCEDURE DeleteRoom(p_room_id NUMBER)
AS
    v_room_count NUMBER;

BEGIN
    SELECT COUNT(*) INTO v_room_count
        FROM ROOMS
        WHERE room_id = p_room_id;
    IF v_room_count = 0 THEN
        RAISE_APPLICATION_ERROR(-20001, 'Комната с указанным ID не найдено.');
    END IF;

    DELETE FROM ROOMS WHERE room_id = p_room_id;
    COMMIT;
    DBMS_OUTPUT.PUT_LINE('Комната успешно удалена.');

EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Произошла ошибка: ' || SQLERRM);
        ROLLBACK;
END DeleteRoom;



-- ****************************************************************
-- СЕРВИС
-- ****************************************************************
----------------------------------------------------------------
--создать сервис
PROCEDURE InsertService(
    p_service_type_id NUMBER,
    p_service_guest_id NUMBER,
    p_service_start_date DATE,
    p_service_end_date DATE)
AS
    v_service_type_count NUMBER;
    v_guest_count NUMBER;
BEGIN
    SELECT COUNT(*) INTO v_service_type_count
        FROM service_types
        WHERE service_type_id = p_service_type_id;
    IF v_service_type_count = 0 THEN
        RAISE_APPLICATION_ERROR(-20001, 'Тип сервиса с указанным ID не найден.');
    END IF;

    SELECT COUNT(*) INTO v_guest_count
        FROM GUESTS
        WHERE guest_id = p_service_guest_id;
    IF v_guest_count = 0 THEN
        RAISE_APPLICATION_ERROR(-20001, 'Гость с указанным ID не найден.');
    END IF;

    IF p_service_start_date >= p_service_end_date THEN
        RAISE_APPLICATION_ERROR(-20003, 'Дата начала услуги должна быть меньше даты окончания.');
    END IF;

    INSERT INTO SERVICES (service_type_id, service_guest_id, service_start_date, service_end_date)
    VALUES (p_service_type_id, p_service_guest_id, p_service_start_date, p_service_end_date);
    COMMIT;
    DBMS_OUTPUT.PUT_LINE('Сервис успешно добавлен.');

EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Произошла ошибка: ' || SQLERRM);
        ROLLBACK;
END InsertService;


--изменить сервис
PROCEDURE UpdateService(
    p_service_id NUMBER,
    p_service_type_id NUMBER,
    p_service_guest_id NUMBER,
    p_service_start_date DATE,
    p_service_end_date DATE)
AS
    v_service_count NUMBER;
    v_service_type_count NUMBER;
    v_guest_count NUMBER;

BEGIN
    SELECT COUNT(*) INTO v_service_count
        FROM SERVICES
        WHERE service_id = p_service_id;
    IF v_service_count = 0 THEN
        RAISE_APPLICATION_ERROR(-20001, 'Услуга с указанным ID не найдено.');
    END IF;

    SELECT COUNT(*) INTO v_service_type_count
        FROM service_types
        WHERE service_type_id = p_service_type_id;
    IF v_service_type_count = 0 THEN
        RAISE_APPLICATION_ERROR(-20001, 'Тип сервиса с указанным ID не найден.');
    END IF;

    SELECT COUNT(*) INTO v_guest_count
        FROM GUESTS
        WHERE guest_id = p_service_guest_id;
    IF v_guest_count = 0 THEN
        RAISE_APPLICATION_ERROR(-20001, 'Гость с указанным ID не найден.');
    END IF;

    IF p_service_start_date >= p_service_end_date THEN
        RAISE_APPLICATION_ERROR(-20004, 'Дата начала услуги должна быть меньше даты окончания.');
    END IF;

    UPDATE SERVICES
    SET
        service_type_id = p_service_type_id,
        service_guest_id = p_service_guest_id,
        service_start_date = p_service_start_date,
        service_end_date = p_service_end_date
    WHERE service_id = p_service_id;
    COMMIT;
    DBMS_OUTPUT.PUT_LINE('Сервис успешно обновлен.');

EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Произошла ошибка: ' || SQLERRM);
        ROLLBACK;
END UpdateService;


--удалить сервис
PROCEDURE DeleteService(p_service_id NUMBER)
AS
    v_service_count NUMBER;

BEGIN

    SELECT COUNT(*) INTO v_service_count
        FROM SERVICES
        WHERE service_id = p_service_id;
    IF v_service_count = 0 THEN
        RAISE_APPLICATION_ERROR(-20001, 'Услуга с указанным ID не найдено.');
    END IF;

    DELETE FROM SERVICES WHERE service_id = p_service_id;
    COMMIT;
    DBMS_OUTPUT.PUT_LINE('Сервис успешно удален.');

EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Произошла ошибка: ' || SQLERRM);
        ROLLBACK;
END DeleteService;



-- ****************************************************************
-- бронь
-- ****************************************************************
--создать бронь
PROCEDURE InsertBooking(
    p_booking_room_id NUMBER,
    p_booking_guest_id NUMBER,
    p_booking_start_date DATE,
    p_booking_end_date DATE,
    p_booking_tariff_id NUMBER,
    p_booking_state NUMBER DEFAULT 1)
AS
    v_room_count NUMBER;
    v_guest_count NUMBER;
    v_tariff_count NUMBER;

BEGIN
    SELECT COUNT(*) INTO v_room_count
        FROM ROOMS
        WHERE room_id = p_booking_room_id;
    IF v_room_count = 0 THEN
        RAISE_APPLICATION_ERROR(-20001, 'Комната с указанным ID не найдено.');
    END IF;

    SELECT COUNT(*) INTO v_guest_count
        FROM GUESTS
        WHERE guest_id = p_booking_guest_id;
    IF v_guest_count = 0 THEN
        RAISE_APPLICATION_ERROR(-20001, 'Гость с указанным ID не найден.');
    END IF;

    SELECT COUNT(*) INTO v_tariff_count
        FROM TARIFF_TYPES
        WHERE TARIFF_TYPE_ID = p_booking_tariff_id;
    IF v_tariff_count = 0 THEN
        RAISE_APPLICATION_ERROR(-20001, 'Тариф с указанным ID не найдено.');
    END IF;


    IF p_booking_start_date >= p_booking_end_date THEN
        RAISE_APPLICATION_ERROR(-20004, 'Дата начала бронирования должна быть меньше даты окончания.');
    END IF;

    INSERT INTO BOOKING (
                         booking_room_id,
                         booking_guest_id,
                         booking_start_date,
                         booking_end_date,
                         booking_tariff_id,
                         booking_state)
    VALUES (
            p_booking_room_id,
            p_booking_guest_id,
            p_booking_start_date,
            p_booking_end_date,
            p_booking_tariff_id,
            p_booking_state);
    COMMIT;
    DBMS_OUTPUT.PUT_LINE('Бронь успешно добавлена.');

EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Произошла ошибка: ' || SQLERRM);
        ROLLBACK;
END InsertBooking;


--изменить бронь
PROCEDURE UpdateBooking(
    p_booking_id NUMBER,
    p_booking_room_id NUMBER,
    p_booking_guest_id NUMBER,
    p_booking_start_date DATE,
    p_booking_end_date DATE,
    p_booking_tariff_id NUMBER,
    p_booking_state NUMBER)
AS
    v_guest_count NUMBER;
    v_room_count NUMBER;
    v_tariff_count NUMBER;
    v_booking_count NUMBER;

BEGIN
    SELECT COUNT(*) INTO v_booking_count
        FROM BOOKING
        WHERE BOOKING_ID = p_booking_id;
    IF v_booking_count = 0 THEN
        RAISE_APPLICATION_ERROR(-20001, 'Бронь с указанным ID не найдена.');
    END IF;

    SELECT COUNT(*) INTO v_room_count
        FROM ROOMS
        WHERE room_id = p_booking_room_id;
    IF v_room_count = 0 THEN
        RAISE_APPLICATION_ERROR(-20001, 'Комната с указанным ID не найдено.');
    END IF;

    SELECT COUNT(*) INTO v_guest_count
        FROM GUESTS
        WHERE guest_id = p_booking_guest_id;
    IF v_guest_count = 0 THEN
        RAISE_APPLICATION_ERROR(-20001, 'Гость с указанным ID не найден.');
    END IF;

     SELECT COUNT(*) INTO v_tariff_count
        FROM TARIFF_TYPES
        WHERE TARIFF_TYPE_ID = p_booking_tariff_id;
    IF v_tariff_count = 0 THEN
        RAISE_APPLICATION_ERROR(-20001, 'Тариф с указанным ID не найдено.');
    END IF;

    IF p_booking_start_date >= p_booking_end_date THEN
        RAISE_APPLICATION_ERROR(-20005, 'Дата начала бронирования должна быть меньше даты окончания.');
    END IF;

    UPDATE BOOKING
    SET
        booking_room_id = p_booking_room_id,
        booking_guest_id = p_booking_guest_id,
        booking_start_date = p_booking_start_date,
        booking_end_date = p_booking_end_date,
        booking_tariff_id = p_booking_tariff_id,
        booking_state = p_booking_state
    WHERE booking_id = p_booking_id;
    COMMIT;
    DBMS_OUTPUT.PUT_LINE('Бронь успешно обновлена.');

EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Произошла ошибка: ' || SQLERRM);
        ROLLBACK;
END UpdateBooking;


--удалить бронь
PROCEDURE DeleteBooking(p_booking_id NUMBER)
AS
    v_booking_count NUMBER;
BEGIN
    SELECT COUNT(*) INTO v_booking_count
        FROM BOOKING
        WHERE BOOKING_ID = p_booking_id;
    IF v_booking_count = 0 THEN
        RAISE_APPLICATION_ERROR(-20001, 'Бронь с указанным ID не найдена.');
    END IF;

    DELETE FROM BOOKING WHERE booking_id = p_booking_id;
    COMMIT;
    DBMS_OUTPUT.PUT_LINE('Бронь успешно удалена.');

EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Произошла ошибка: ' || SQLERRM);
        ROLLBACK;
END DeleteBooking;

PROCEDURE DeleteGuestCompletely(p_guest_id NUMBER)
AS
    v_guest_count NUMBER;
BEGIN
    SELECT COUNT(*) INTO v_guest_count FROM GUESTS
    WHERE guest_id = p_guest_id;
    IF v_guest_count = 0 THEN
        RAISE_APPLICATION_ERROR(-20001, 'Гость с указанным ID не найден.');
    END IF;

    DELETE FROM SERVICES
    WHERE service_guest_id = p_guest_id;

    DELETE FROM BOOKING
    WHERE booking_guest_id = p_guest_id;

    DELETE FROM GUESTS
    WHERE guest_id = p_guest_id;

    COMMIT;
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Произошла ошибка: ' || SQLERRM);
        ROLLBACK;

END DeleteGuestCompletely;





END HotelAdminPack;
/