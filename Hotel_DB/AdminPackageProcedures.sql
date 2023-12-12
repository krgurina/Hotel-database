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
        p_employee_name NVARCHAR2 DEFAULT NULL,
        p_employee_surname NVARCHAR2 DEFAULT NULL,
        p_employee_position NVARCHAR2 DEFAULT NULL,
        p_employee_email NVARCHAR2 DEFAULT NULL,
        p_employee_hire_date DATE DEFAULT NULL,
        p_employee_birth_date DATE DEFAULT NULL);
    PROCEDURE DeleteEmployee(p_employee_id NUMBER);

    --2. гость
    PROCEDURE InsertGuest(
        p_email NVARCHAR2,
        p_name NVARCHAR2,
        p_surname NVARCHAR2,
        p_username NVARCHAR2);
    PROCEDURE UpdateGuest(
        p_guest_id NUMBER,
        p_email NVARCHAR2 DEFAULT NULL,
        p_name NVARCHAR2 DEFAULT NULL,
        p_surname NVARCHAR2 DEFAULT NULL);
    PROCEDURE DeleteGuest(p_guest_id NUMBER);

    --3. тип комнаты
    PROCEDURE InsertRoomType(
        p_room_type_name NVARCHAR2,
        p_room_type_capacity NUMBER,
        p_room_type_daily_price FLOAT,
        p_room_type_description NVARCHAR2);
    PROCEDURE UpdateRoomType(
        p_room_type_id NUMBER,
        p_new_room_type_name NVARCHAR2 DEFAULT NULL,
        p_new_room_type_capacity NUMBER DEFAULT NULL,
        p_new_room_type_daily_price FLOAT DEFAULT NULL,
        p_new_room_type_description NVARCHAR2 DEFAULT NULL);
    PROCEDURE DeleteRoomType(p_room_type_id NUMBER);

    --4. тариф
    PROCEDURE InsertTariffType(
      p_tariff_type_name        NVARCHAR2,
      p_tariff_type_description NVARCHAR2,
      p_tariff_type_daily_price FLOAT);
    PROCEDURE UpdateTariffType(
        p_tariff_type_id          NUMBER DEFAULT NULL,
        p_tariff_type_name        NVARCHAR2 DEFAULT NULL,
        p_tariff_type_description NVARCHAR2 DEFAULT NULL,
        p_tariff_type_daily_price FLOAT DEFAULT NULL);
    PROCEDURE DeleteTariffType (p_tariff_type_id NUMBER);

    --5. тип сервиса
    PROCEDURE InsertServiceType(
        p_name NVARCHAR2,
        p_description NVARCHAR2,
        p_daily_price FLOAT,
        p_employee_id NUMBER);
    PROCEDURE UpdateServiceType(
        p_service_type_id NUMBER,
        p_name NVARCHAR2 DEFAULT NULL,
        p_description NVARCHAR2 DEFAULT NULL,
        p_daily_price FLOAT DEFAULT NULL,
        p_employee_id NUMBER DEFAULT NULL);
    PROCEDURE DeleteServiceType(p_service_type_id NUMBER);

    --6. фото
    PROCEDURE InsertPhoto(
        p_photo_room_type_id NUMBER,
        p_photo_source VARCHAR2);
    PROCEDURE UpdatePhoto(
        p_photo_id NUMBER,
        p_room_type_id NUMBER,
        p_photo_source VARCHAR2
    );
    PROCEDURE DeletePhoto(p_photo_id NUMBER);

    --7. комната
    PROCEDURE InsertRoom(
        p_room_room_type_id NUMBER,
        p_room_number NVARCHAR2);
    PROCEDURE UpdateRoom(
        p_room_id NUMBER,
        p_room_room_type_id NUMBER DEFAULT NULL,
        p_room_number NVARCHAR2 DEFAULT NULL);
    PROCEDURE DeleteRoom(p_room_id NUMBER);

    --8. сервис
    PROCEDURE InsertService(
        p_service_type_id NUMBER,
        p_service_guest_id NUMBER,
        p_service_start_date DATE,
        p_service_end_date DATE);
    PROCEDURE UpdateService(
        p_service_id NUMBER,
        p_service_type_id NUMBER DEFAULT NULL,
        p_service_guest_id NUMBER DEFAULT NULL,
        p_service_start_date DATE DEFAULT NULL,
        p_service_end_date DATE DEFAULT NULL);
    PROCEDURE DeleteService(p_service_id NUMBER);

    --9. бронь
    PROCEDURE InsertBooking(
        p_room_id NUMBER,
        p_guest_id NUMBER,
        p_start_date DATE,
        p_end_date DATE,
        p_tariff_id NUMBER,
        p_booking_state NUMBER DEFAULT 2);
    PROCEDURE UpdateBooking(
        p_booking_id NUMBER,
        p_room_id NUMBER DEFAULT NULL,
        p_guest_id NUMBER DEFAULT NULL,
        p_start_date DATE DEFAULT NULL,
        p_end_date DATE DEFAULT NULL,
        p_tariff_id NUMBER DEFAULT NULL,
        p_booking_state NUMBER DEFAULT NULL);

    PROCEDURE DeleteBooking(p_booking_id NUMBER);
    PROCEDURE DeleteGuestCompletely(p_guest_id NUMBER);

    FUNCTION GetGuestsCursor(p_id NUMBER DEFAULT NULL) RETURN SYS_REFCURSOR;
    FUNCTION GetEmployeesCursor(p_id NUMBER DEFAULT NULL) RETURN SYS_REFCURSOR;
    FUNCTION GetBookingCursor(p_id NUMBER DEFAULT NULL) RETURN SYS_REFCURSOR;
    FUNCTION GetBookingStateCursor(p_id NUMBER DEFAULT NULL) RETURN SYS_REFCURSOR;
    FUNCTION GetPhotoCursor(p_id NUMBER DEFAULT NULL) RETURN SYS_REFCURSOR;
    FUNCTION GetRoomTypeCursor(p_id NUMBER DEFAULT NULL) RETURN SYS_REFCURSOR;
    FUNCTION GetRoomCursor(p_id NUMBER DEFAULT NULL) RETURN SYS_REFCURSOR;
    FUNCTION GetServiceTypeCursor(p_id NUMBER DEFAULT NULL) RETURN SYS_REFCURSOR;
    FUNCTION GetServiceCursor(p_id NUMBER DEFAULT NULL) RETURN SYS_REFCURSOR;
    FUNCTION GetTariffCursor(p_id NUMBER DEFAULT NULL) RETURN SYS_REFCURSOR;


    PROCEDURE GetGuests (p_id NUMBER DEFAULT NULL);
    PROCEDURE GetEmployees(p_id NUMBER DEFAULT NULL);
    PROCEDURE GetBookings(p_id NUMBER DEFAULT NULL);
    PROCEDURE GetBookingStates(p_id NUMBER DEFAULT NULL);
    PROCEDURE GetPhotos(p_id NUMBER DEFAULT NULL);
    PROCEDURE GetServices(p_id NUMBER DEFAULT NULL);
    PROCEDURE GetRoomTypes(p_id NUMBER DEFAULT NULL);
    PROCEDURE GetRooms(p_id NUMBER DEFAULT NULL);
    PROCEDURE GetServiceTypes(p_id NUMBER DEFAULT NULL);
    PROCEDURE GetTariffTypes(p_id NUMBER DEFAULT NULL);


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
    v_employee_id NUMBER;
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
        username)
    VALUES (
        p_name,
        p_surname,
        p_position,
        p_email,
        p_hire_date,
        p_birth_date,
        p_username)returning employee_id into v_employee_id;
    COMMIT;

    EXECUTE IMMEDIATE 'CREATE USER ' || p_username ||
                      ' IDENTIFIED BY ' || p_username ||
                      ' DEFAULT TABLESPACE HOTEL_TS' ||
                      ' TEMPORARY TABLESPACE HOTEL_TEMP_TS' ||
                      ' PROFILE PF_USER' ||
                      ' ACCOUNT UNLOCK'||
                      ' PASSWORD EXPIRE';

    EXECUTE IMMEDIATE 'GRANT Employee_role TO ' || p_username;

    DBMS_OUTPUT.PUT_LINE('Работник успешно добавлен. Ваш ID: ' || v_employee_id||' Логин: '|| p_username || ' Пароль: '|| p_username);

EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Произошла ошибка: ' || SQLERRM);
        ROLLBACK;
END InsertEmployee;


-- изменить рабоника
PROCEDURE UpdateEmployee(
    p_employee_id NUMBER,
    p_employee_name NVARCHAR2 DEFAULT NULL,
    p_employee_surname NVARCHAR2 DEFAULT NULL,
    p_employee_position NVARCHAR2 DEFAULT NULL,
    p_employee_email NVARCHAR2 DEFAULT NULL,
    p_employee_hire_date DATE DEFAULT NULL,
    p_employee_birth_date DATE DEFAULT NULL)
AS
    v_current_date DATE := SYSDATE;
    v_min_age CONSTANT NUMBER := 18;
    --v_employee_count NUMBER;
    v_existing_employee EMPLOYEES%ROWTYPE;

BEGIN
    SELECT *
    INTO v_existing_employee
    FROM EMPLOYEES
    WHERE employee_id = p_employee_id;

    IF v_existing_employee.EMPLOYEE_ID IS NULL THEN
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
        employee_name = COALESCE(p_employee_name, v_existing_employee.EMPLOYEE_NAME),
        employee_surname = COALESCE(p_employee_surname, v_existing_employee.EMPLOYEE_SURNAME),
        employee_position = COALESCE(p_employee_position, v_existing_employee.EMPLOYEE_POSITION),
        employee_email = COALESCE(p_employee_email, v_existing_employee.EMPLOYEE_EMAIL),
        employee_hire_date = COALESCE(p_employee_hire_date, v_existing_employee.EMPLOYEE_HIRE_DATE),
        employee_birth_date =  COALESCE(p_employee_birth_date, v_existing_employee.EMPLOYEE_BIRTH_DATE)
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
    v_username NVARCHAR2(50);
BEGIN
    SELECT COUNT(*) INTO v_employee_count
    FROM EMPLOYEES
    WHERE employee_id = p_employee_id;

    IF v_employee_count = 0 THEN
        RAISE_APPLICATION_ERROR(-20001, 'Работник с указанным ID не найден.');
    END IF;

    SELECT username INTO v_username
    FROM EMPLOYEES
    WHERE employee_id = p_employee_id;

    DELETE FROM EMPLOYEES WHERE employee_id = p_employee_id;
    COMMIT;

    EXECUTE IMMEDIATE 'DROP USER ' || v_username || ' CASCADE';
    --DELETE FROM all_USERS WHERE lower(username) = lower(v_username);

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
    v_guest_id NUMBER;
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
    VALUES (p_email, p_name, p_surname,p_username) RETURNING guest_id INTO v_guest_id;
    COMMIT;

    EXECUTE IMMEDIATE 'CREATE USER ' || p_username ||
                      ' IDENTIFIED BY ' || p_username ||
                      ' DEFAULT TABLESPACE HOTEL_TS' ||
                      ' TEMPORARY TABLESPACE HOTEL_TEMP_TS'||
                      ' PROFILE PF_USER' ||
                      ' ACCOUNT UNLOCK'||
                      ' PASSWORD EXPIRE';
--
     EXECUTE IMMEDIATE 'GRANT Guest_role TO ' || p_username;

    DBMS_OUTPUT.PUT_LINE('Гость успешно создан. Ваш ID: '||v_guest_id||' Логин: '|| p_username || ' Пароль: '|| p_username);

EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Произошла ошибка: ' || SQLERRM);
        ROLLBACK;
END InsertGuest;


--изменить гостя
PROCEDURE UpdateGuest(
    p_guest_id NUMBER,
    p_email NVARCHAR2 DEFAULT NULL,
    p_name NVARCHAR2 DEFAULT NULL,
    p_surname NVARCHAR2 DEFAULT NULL)
AS
    v_existing_guest GUESTS%ROWTYPE;

BEGIN
    SELECT * INTO v_existing_guest
    FROM GUESTS
    WHERE GUEST_ID = p_guest_id;

    IF v_existing_guest.GUEST_ID IS NULL THEN
        RAISE_APPLICATION_ERROR(-20001, 'Гость с указанным ID не найден.');
    END IF;

    IF REGEXP_LIKE(p_email, '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Z|a-z]{2,4}$') = FALSE THEN
        RAISE_APPLICATION_ERROR(-20003, 'Неправильный формат email.');
    END IF;

    UPDATE GUESTS
    SET
        guest_email = COALESCE(p_email, v_existing_guest.GUEST_EMAIL),
        guest_name = COALESCE(p_name, v_existing_guest.GUEST_NAME),
        guest_surname = COALESCE(p_surname, v_existing_guest.GUEST_SURNAME)
    WHERE
        guest_id = p_guest_id;
    COMMIT;

    DBMS_OUTPUT.PUT_LINE('Информация о госте успешно обновлена.');

EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Произошла ошибка: ' || SQLERRM);
        ROLLBACK;
END UpdateGuest;


--удалить гостя
PROCEDURE DeleteGuest(p_guest_id NUMBER)
AS
    v_guest_count NUMBER;
    v_username VARCHAR2(50);
BEGIN
    SELECT COUNT(*) INTO v_guest_count
    FROM GUESTS
    WHERE guest_id = p_guest_id;

    IF v_guest_count = 0 THEN
        RAISE_APPLICATION_ERROR(-20001, 'Гость с указанным ID не найден.');
    END IF;

    SELECT username INTO v_username
    FROM GUESTS
    WHERE GUEST_ID = p_guest_id;

    DELETE FROM GUESTS WHERE guest_id = p_guest_id;
    COMMIT;

    EXECUTE IMMEDIATE 'DROP USER ' || v_username || ' CASCADE';
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
    v_room_type_id NUMBER;
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
    VALUES (p_room_type_name, p_room_type_capacity, p_room_type_daily_price, p_room_type_description) returning ROOM_TYPE_ID into v_room_type_id;
    COMMIT;
    DBMS_OUTPUT.PUT_LINE('Тип комнаты успешно создан. ID: '||v_room_type_id);
EXCEPTION
    WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('Произошла ошибка: ' || SQLERRM);
    ROLLBACK;
END InsertRoomType;


--изменить тип комнаты
PROCEDURE UpdateRoomType(
    p_room_type_id NUMBER,
    p_new_room_type_name NVARCHAR2 DEFAULT NULL,
    p_new_room_type_capacity NUMBER DEFAULT NULL,
    p_new_room_type_daily_price FLOAT DEFAULT NULL,
    p_new_room_type_description NVARCHAR2 DEFAULT NULL
) AS
    v_existing_count NUMBER;
    v_existing_room_type ROOM_TYPES%ROWTYPE;
BEGIN
    -- Проверка наличия типа комнаты с указанным ID
    SELECT *
    INTO v_existing_room_type
    FROM ROOM_TYPES
    WHERE room_type_id = p_room_type_id;

    IF v_existing_room_type.room_type_id IS NULL THEN
        RAISE_APPLICATION_ERROR(-20001, 'Тип комнаты с указанным ID не существует.');
    END IF;

    -- Обновление данных типа комнаты с использованием COALESCE
    UPDATE ROOM_TYPES
    SET
        room_type_name = COALESCE(p_new_room_type_name, v_existing_room_type.room_type_name),
        room_type_capacity = COALESCE(p_new_room_type_capacity, v_existing_room_type.room_type_capacity),
        room_type_daily_price = COALESCE(p_new_room_type_daily_price, v_existing_room_type.room_type_daily_price),
        room_type_description = COALESCE(p_new_room_type_description, v_existing_room_type.room_type_description)
    WHERE room_type_id = p_room_type_id;

    -- Дополнительные проверки, если необходимо

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
  v_tariff_type_id NUMBER;

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
    VALUES (p_tariff_type_name, p_tariff_type_description, p_tariff_type_daily_price) returning TARIFF_TYPE_ID into v_tariff_type_id;
    COMMIT;
  DBMS_OUTPUT.PUT_LINE('Тариф успешно добавлен. ID: ' || v_tariff_type_id);
EXCEPTION
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('Произошла ошибка: ' || SQLERRM);
    ROLLBACK;
END InsertTariffType;


--изменить тип тарифа
PROCEDURE UpdateTariffType(
  p_tariff_type_id          NUMBER DEFAULT NULL,
  p_tariff_type_name        NVARCHAR2 DEFAULT NULL,
  p_tariff_type_description NVARCHAR2 DEFAULT NULL,
  p_tariff_type_daily_price FLOAT DEFAULT NULL
) AS
  v_existing_count NUMBER;
  v_existing_tariff_type TARIFF_TYPES%rowtype;

BEGIN
    SELECT * INTO v_existing_tariff_type FROM TARIFF_TYPES
    WHERE tariff_type_id = p_tariff_type_id;

    IF v_existing_tariff_type.TARIFF_TYPE_ID IS NULL THEN
        RAISE_APPLICATION_ERROR(-20001, 'Тариф с указанным ID не существует.');
    END IF;

    IF p_tariff_type_daily_price <= 0 THEN
        RAISE_APPLICATION_ERROR(-20003, 'Новая ежедневная цена тарифа должна быть больше 0.');
    END IF;

  -- Проверка наличия такого же тарифа
    SELECT COUNT(*) INTO v_existing_count FROM TARIFF_TYPES
    WHERE tariff_type_name = p_tariff_type_name
    AND tariff_type_id != p_tariff_type_id;

    IF v_existing_count > 0 THEN
        RAISE_APPLICATION_ERROR(-20005, 'Тариф с таким именем уже существует.');
    END IF;

  -- Обновление данных тарифа
  UPDATE TARIFF_TYPES
  SET   --COALESCE(p_employee_name, v_existing_employee.EMPLOYEE_NAME);
    tariff_type_name = COALESCE(p_tariff_type_name, v_existing_tariff_type.TARIFF_TYPE_NAME),
    tariff_type_description = COALESCE(p_tariff_type_description, v_existing_tariff_type.TARIFF_TYPE_DESCRIPTION),
    tariff_type_daily_price = COALESCE(p_tariff_type_daily_price, v_existing_tariff_type.TARIFF_TYPE_DAILY_PRICE)
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
    v_service_type_id NUMBER;

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
        p_employee_id) returning SERVICE_TYPE_ID into v_service_type_id;
    COMMIT;
    DBMS_OUTPUT.PUT_LINE('Тип сервиса успешно создан. ID: '|| v_service_type_id);
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Произошла ошибка: ' || SQLERRM);
        ROLLBACK;
END InsertServiceType;


--изменить тип сервиса
PROCEDURE UpdateServiceType(
    p_service_type_id NUMBER,
    p_name NVARCHAR2 DEFAULT NULL,
    p_description NVARCHAR2 DEFAULT NULL,
    p_daily_price FLOAT DEFAULT NULL,
    p_employee_id NUMBER DEFAULT NULL)
AS
    v_employee_count NUMBER;
    v_service_type SERVICE_TYPES%ROWTYPE;

BEGIN
    SELECT * INTO v_service_type
    FROM SERVICE_TYPES
    WHERE SERVICE_TYPE_ID = p_service_type_id;

    IF v_service_type.SERVICE_TYPE_ID IS NULL THEN
        RAISE_APPLICATION_ERROR(-20001, 'Тип сервиса с указанным ID не найден.');
    END IF;

        IF p_employee_id IS NOT NULL THEN
        SELECT COUNT(*) INTO v_employee_count
        FROM EMPLOYEES
        WHERE EMPLOYEE_ID = p_employee_id;
        IF v_employee_count = 0 THEN
            RAISE_APPLICATION_ERROR(-20002, 'Работник с указанным ID не найден.');
        END IF;
    END IF;


    UPDATE SERVICE_TYPES
    SET
        service_type_name = COALESCE(p_name, v_service_type.SERVICE_TYPE_NAME),
        service_type_description = COALESCE(p_description, v_service_type.SERVICE_TYPE_DESCRIPTION),
        service_type_daily_price = COALESCE(p_daily_price, v_service_type.SERVICE_TYPE_DAILY_PRICE),
        service_type_employee_id = COALESCE(p_employee_id, v_service_type.SERVICE_TYPE_EMPLOYEE_ID)
    WHERE service_type_id = p_service_type_id;
    COMMIT;
      DBMS_OUTPUT.PUT_LINE('Тип сервиса успешно обновлен.');

EXCEPTION
    WHEN OTHERS THEN
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
-- PROCEDURE InsertPhoto(
--     p_photo_room_type_id NUMBER,
--     p_photo_source BLOB)
-- AS
--         v_room_type_count NUMBER;
--
-- BEGIN
--     SELECT COUNT(*) INTO v_room_type_count
--         FROM ROOM_TYPES
--         WHERE room_type_id = p_photo_room_type_id;
--     IF v_room_type_count = 0 THEN
--         RAISE_APPLICATION_ERROR(-20001, 'Тип комнаты с указанным ID не найден.');
--     END IF;
--
--     INSERT INTO PHOTO (photo_room_type_id, photo_source)
--     VALUES (p_photo_room_type_id, p_photo_source);
--     COMMIT;
--     DBMS_OUTPUT.PUT_LINE('Фото успешно добавлено.');
--
-- EXCEPTION
--     WHEN OTHERS THEN
--         DBMS_OUTPUT.PUT_LINE('Произошла ошибка: ' || SQLERRM);
--         ROLLBACK;
-- END InsertPhoto;


-------- оно работает но написано слишком сложно
--   PROCEDURE InsertPhoto(
--     p_photo_room_type_id NUMBER,
--     p_photo_source VARCHAR2
--   ) AS
--     v_blob BLOB;
--     v_room_type_count NUMBER;
--     v_photo_id NUMBER;
--   BEGIN
--     -- Проверка существования типа комнаты
--     SELECT COUNT(*) INTO v_room_type_count
--     FROM ROOM_TYPES
--     WHERE room_type_id = p_photo_room_type_id;
--
--     IF v_room_type_count = 0 THEN
--       RAISE_APPLICATION_ERROR(-20001, 'Тип комнаты с указанным ID не найден.');
--     END IF;
--
--     -- Извлечение содержимого файла изображения и запись в BLOB
--     DBMS_LOB.createtemporary(v_blob, TRUE);
--
--     DECLARE
--       v_file BFILE := BFILENAME('MEDIA_DIR', p_photo_source);
--     BEGIN
--       DBMS_LOB.fileopen(v_file, DBMS_LOB.file_readonly);
--       DBMS_LOB.loadfromfile(v_blob, v_file, DBMS_LOB.getlength(v_file));
--       DBMS_LOB.fileclose(v_file);
--     EXCEPTION
--       WHEN OTHERS THEN
--         DBMS_OUTPUT.PUT_LINE('Ошибка при загрузке изображения: ' || SQLERRM);
--         DBMS_LOB.fileclose(v_file);
--         DBMS_LOB.freetemporary(v_blob);
--         RETURN;
--     END;
--
--     -- Вставка записи в таблицу PHOTO
--     INSERT INTO PHOTO (photo_room_type_id, photo_source)
--     VALUES (p_photo_room_type_id, v_blob) returning photo_id into v_photo_id;
--
--     COMMIT;
--
--     DBMS_OUTPUT.PUT_LINE('Фото успешно добавлено. ID: ' || v_photo_id);
--
--   EXCEPTION
--     WHEN OTHERS THEN
--       DBMS_OUTPUT.PUT_LINE('Произошла ошибка: ' || SQLERRM);
--       ROLLBACK;
--   END InsertPhoto;





PROCEDURE InsertPhoto(
    p_photo_room_type_id NUMBER,
     p_photo_source VARCHAR2
) AS
    v_room_type_count NUMBER;
    v_photo_id NUMBER;
BEGIN
    --Проверка существования типа комнаты
    SELECT COUNT(*) INTO v_room_type_count
    FROM ROOM_TYPES
    WHERE room_type_id = p_photo_room_type_id;

    IF v_room_type_count = 0 THEN
      RAISE_APPLICATION_ERROR(-20001, 'Тип комнаты с указанным ID не найден.');
    END IF;

    INSERT INTO PHOTO (photo_room_type_id, photo_source)
    VALUES (p_photo_room_type_id, BFILENAME('MEDIA_DIR', p_photo_source)) returning photo_id into v_photo_id;
    COMMIT;

    DBMS_OUTPUT.PUT_LINE('Фото успешно добавлено. ID: ' || v_photo_id);

EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Произошла ошибка: ' || SQLERRM);
        ROLLBACK;
END InsertPhoto;






--изменить галерею фото
PROCEDURE UpdatePhoto(
    p_photo_id NUMBER,
    p_room_type_id NUMBER,
    p_photo_source VARCHAR2
) AS
    v_room_type_count NUMBER;
    v_photo_count NUMBER;

BEGIN
    --Проверка существования фото
        SELECT COUNT(*) INTO v_photo_count
        FROM PHOTO
        WHERE photo_id = p_photo_id;

        IF v_photo_count = 0 THEN
          RAISE_APPLICATION_ERROR(-20001, 'Фото с указанным ID не найдено.');
        END IF;

    --Проверка существования типа комнаты
        SELECT COUNT(*) INTO v_room_type_count
        FROM ROOM_TYPES
        WHERE room_type_id = p_room_type_id;

        IF v_room_type_count = 0 THEN
          RAISE_APPLICATION_ERROR(-20001, 'Тип комнаты с указанным ID не найден.');
    END IF;


    UPDATE PHOTO
    SET
        photo_room_type_id = p_room_type_id,
        photo_source = BFILENAME('MEDIA_DIR', p_photo_source)
    WHERE photo_id = p_photo_id;
    COMMIT;

    DBMS_OUTPUT.PUT_LINE('Фото успешно обновлено. ID: ' || p_photo_id);

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
    p_room_room_type_id NUMBER DEFAULT NULL,
    p_room_number NVARCHAR2 DEFAULT NULL)
AS
    v_room_type_count NUMBER;
    v_room_count NUMBER;
    v_old_room ROOMS%ROWTYPE;

BEGIN
    -- Проверка наличия комнаты с указанным ID
    SELECT COUNT(*) INTO v_room_count
    FROM ROOMS
    WHERE room_id = p_room_id;

    IF v_room_count = 0 THEN
        RAISE_APPLICATION_ERROR(-20001, 'Комната с указанным ID не найдено.');
    END IF;

    -- Получение старых данных комнаты
    SELECT * INTO v_old_room
    FROM ROOMS
    WHERE room_id = p_room_id;

    -- Проверка наличия типа комнаты с указанным ID
    IF p_room_room_type_id IS NOT NULL THEN
        SELECT COUNT(*) INTO v_room_type_count
        FROM ROOM_TYPES
        WHERE room_type_id = p_room_room_type_id;

        IF v_room_type_count = 0 THEN
            RAISE_APPLICATION_ERROR(-20001, 'Тип комнаты с указанным ID не найден.');
        END IF;
    END IF;

    -- Обновление данных комнаты с использованием COALESCE
    UPDATE ROOMS
    SET
        room_room_type_id = COALESCE(p_room_room_type_id, v_old_room.room_room_type_id),
        room_number = COALESCE(p_room_number, v_old_room.room_number)
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
    v_booking_count NUMBER;
    v_service_id NUMBER;
BEGIN
    -- Проверка существования типа сервиса
    SELECT COUNT(*) INTO v_service_type_count
    FROM service_types
    WHERE service_type_id = p_service_type_id;

    IF v_service_type_count = 0 THEN
        RAISE_APPLICATION_ERROR(-20001, 'Тип сервиса с указанным ID не найден.');
    END IF;

    -- Проверка существования гостя
    SELECT COUNT(*) INTO v_guest_count
    FROM GUESTS
    WHERE guest_id = p_service_guest_id;
    IF v_guest_count = 0 THEN
        RAISE_APPLICATION_ERROR(-20002, 'Гость с указанным ID не найден.');
    END IF;

    -- Проверка, что гость имеет бронь на указанный период
    SELECT COUNT(*) INTO v_booking_count
    FROM BOOKING
    WHERE BOOKING_GUEST_ID = p_service_guest_id
        AND (p_service_start_date BETWEEN booking_start_date AND booking_end_date
             OR p_service_end_date BETWEEN booking_start_date AND booking_end_date);

    IF v_booking_count = 0 THEN
        RAISE_APPLICATION_ERROR(-20003, 'Гость не имеет брони на указанный период.');
    END IF;

    IF p_service_start_date >= p_service_end_date THEN
        RAISE_APPLICATION_ERROR(-20004, 'Дата начала услуги должна быть меньше даты окончания.');
    END IF;

    INSERT INTO SERVICES (
                          service_type_id,
                          service_guest_id,
                          service_start_date,
                          service_end_date)
    VALUES (
            p_service_type_id,
            p_service_guest_id,
            p_service_start_date,
            p_service_end_date) returning SERVICE_ID into v_service_id;

    COMMIT;
    DBMS_OUTPUT.PUT_LINE('Сервис успешно добавлен. ID: '|| v_service_id);

EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Произошла ошибка: ' || SQLERRM);
        ROLLBACK;
END InsertService;



--изменить сервис
PROCEDURE UpdateService(
    p_service_id NUMBER,
    p_service_type_id NUMBER DEFAULT NULL,
    p_service_guest_id NUMBER DEFAULT NULL,
    p_service_start_date DATE DEFAULT NULL,
    p_service_end_date DATE DEFAULT NULL)
AS
    v_service_count NUMBER;
    v_service_type_count NUMBER;
    v_guest_count NUMBER;
    v_existing_servise SERVICES%ROWTYPE;

BEGIN
    SELECT COUNT(*) INTO v_service_count
        FROM SERVICES
        WHERE service_id = p_service_id;
    IF v_service_count = 0 THEN
        RAISE_APPLICATION_ERROR(-20001, 'Услуга с указанным ID не найдено.');
    END IF;


    SELECT * INTO v_existing_servise
    FROM SERVICES
    WHERE SERVICE_ID = p_service_id;

    --1
    IF p_service_type_id IS NOT NULL THEN
        SELECT COUNT(*) INTO v_service_type_count
        FROM service_types
        WHERE service_type_id = p_service_type_id;

        IF v_service_type_count = 0 THEN
            RAISE_APPLICATION_ERROR(-20001, 'Тип сервиса с указанным ID не найден.');
        END IF;
    END IF;


    --2
    IF p_service_guest_id IS NOT NULL THEN
        SELECT COUNT(*) INTO v_guest_count
                FROM GUESTS
                WHERE guest_id = p_service_guest_id;
            IF v_guest_count = 0 THEN
                RAISE_APPLICATION_ERROR(-20001, 'Гость с указанным ID не найден.');
            END IF;
    END IF;


    UPDATE SERVICES
    SET
        service_type_id = COALESCE(p_service_type_id, v_existing_servise.SERVICE_TYPE_ID),
        service_guest_id = COALESCE(p_service_guest_id, v_existing_servise.SERVICE_GUEST_ID),
        service_start_date = COALESCE(p_service_start_date, v_existing_servise.SERVICE_START_DATE),
        service_end_date = COALESCE(p_service_end_date,  v_existing_servise.SERVICE_END_DATE)
    WHERE service_id = p_service_id;

    IF p_service_start_date >= p_service_end_date THEN
        RAISE_APPLICATION_ERROR(-20004, 'Дата начала услуги должна быть меньше даты окончания.');
    END IF;

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
    p_room_id NUMBER,
    p_guest_id NUMBER,
    p_start_date DATE,
    p_end_date DATE,
    p_tariff_id NUMBER,
    p_booking_state NUMBER DEFAULT 2
    )
AS
    v_current_date DATE := SYSDATE;
    v_guest_exists NUMBER;
    v_room_exists NUMBER;
    v_room_available NUMBER;
    v_tariff_exists NUMBER;
BEGIN

    -- существования гостя
    SELECT COUNT(*) INTO v_guest_exists FROM GUESTS
    WHERE GUEST_ID = p_guest_id;
    IF v_guest_exists = 0 THEN
        RAISE_APPLICATION_ERROR(-20001, 'Гость с указанным ID не найден.');
    END IF;

    SELECT COUNT(*) INTO v_room_exists FROM ROOMS
    WHERE room_id = p_room_id;
    IF v_room_exists = 0 THEN
        RAISE_APPLICATION_ERROR(-20001, 'Номер с указанным ID не найден.');
    END IF;

    SELECT COUNT(*) INTO v_tariff_exists FROM TARIFF_TYPES
    WHERE TARIFF_TYPE_ID = p_tariff_id;
    IF v_tariff_exists = 0 THEN
        RAISE_APPLICATION_ERROR(-20002, 'Тариф с указанным ID не найден.');
    END IF;

    -- номер доступен в выбранные даты
    SELECT COUNT(*) INTO v_room_available
    FROM BOOKING
    WHERE booking_room_id = p_room_id
        AND (
            (p_start_date BETWEEN booking_start_date AND booking_end_date)
            OR (p_end_date BETWEEN booking_start_date AND booking_end_date)
            OR (booking_start_date BETWEEN p_start_date AND p_end_date)
            OR (booking_end_date BETWEEN p_start_date AND p_end_date)
        );

    IF v_room_available > 0 THEN
        RAISE_APPLICATION_ERROR(-20002, 'Номер занят в выбранные даты.');
    END IF;

    IF p_start_date >= p_end_date THEN
        RAISE_APPLICATION_ERROR(-20003, 'Дата начала бронирования должна быть раньше даты окончания.');
    END IF;

    IF p_start_date < v_current_date OR p_end_date < v_current_date THEN
        RAISE_APPLICATION_ERROR(-20004, 'Выберите даты бронирования, начиная с текущей даты.');
    END IF;

    INSERT INTO BOOKING (
                         booking_room_id,
                         booking_guest_id,
                         booking_start_date,
                         booking_end_date,
                         booking_tariff_id,
                         booking_state)
    VALUES (
            p_room_id,
            p_guest_id,
            p_start_date,
            p_end_date,
            p_tariff_id,
            p_booking_state);
    COMMIT;
    DBMS_OUTPUT.PUT_LINE('Бронирование успешно добавлено.');
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Произошла ошибка: ' || SQLERRM);
        ROLLBACK;
END InsertBooking;

--изменить бронь
PROCEDURE UpdateBooking(
    p_booking_id NUMBER,
    p_room_id NUMBER DEFAULT NULL,
    p_guest_id NUMBER DEFAULT NULL,
    p_start_date DATE DEFAULT NULL,
    p_end_date DATE DEFAULT NULL,
    p_tariff_id NUMBER DEFAULT NULL,
    p_booking_state NUMBER DEFAULT NULL)
AS
    v_old_booking BOOKING%ROWTYPE;
    v_booking_count NUMBER;
    v_room_count NUMBER;
    v_guest_count NUMBER;
    v_tariff_count NUMBER;
BEGIN
    SELECT COUNT(*) INTO v_booking_count
        FROM BOOKING
        WHERE BOOKING_ID = p_booking_id;
    IF v_booking_count = 0 THEN
        RAISE_APPLICATION_ERROR(-20001, 'Бронь с указанным ID не найдена.');
    END IF;

    IF p_room_id IS NOT NULL THEN
        SELECT COUNT(*) INTO v_room_count
                FROM ROOMS
                WHERE room_id = p_room_id;
            IF v_room_count = 0 THEN
                RAISE_APPLICATION_ERROR(-20001, 'Комната с указанным ID не найдена.');
            END IF;
    END IF;

    IF p_guest_id IS NOT NULL THEN
        SELECT COUNT(*) INTO v_guest_count
                FROM GUESTS
                WHERE guest_id = p_guest_id;
            IF v_guest_count = 0 THEN
                RAISE_APPLICATION_ERROR(-20001, 'Гость с указанным ID не найден.');
            END IF;
    END IF;


    IF p_tariff_id IS NOT NULL THEN
        SELECT COUNT(*) INTO v_tariff_count
                FROM TARIFF_TYPES
                WHERE tariff_type_id = p_tariff_id;
            IF v_tariff_count = 0 THEN
                RAISE_APPLICATION_ERROR(-20001, 'Тариф с указанным ID не найден.');
            END IF;
    END IF;



    -- Получаем старые данные брони
    SELECT * INTO v_old_booking
    FROM BOOKING WHERE booking_id = p_booking_id;

    UPDATE BOOKING
    SET
        booking_room_id = COALESCE(p_room_id, v_old_booking.BOOKING_ROOM_ID),
        booking_guest_id = COALESCE(p_guest_id, v_old_booking.BOOKING_GUEST_ID),
        booking_start_date = COALESCE(p_start_date, v_old_booking.BOOKING_START_DATE),
        booking_end_date = COALESCE(p_end_date, v_old_booking.BOOKING_END_DATE),
        booking_tariff_id = COALESCE(p_tariff_id, v_old_booking.BOOKING_TARIFF_ID),
        booking_state = COALESCE(p_booking_state, v_old_booking.BOOKING_STATE)
    WHERE booking_id = p_booking_id;
    COMMIT;

    DBMS_OUTPUT.PUT_LINE('Бронирование с ID '|| p_booking_id ||' успешно обновлено.');
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

-- ****************************************************************
-- Вывод всей информации
-- ****************************************************************
FUNCTION GetGuestsCursor(p_id NUMBER DEFAULT NULL) RETURN SYS_REFCURSOR
    AS
    result_cursor SYS_REFCURSOR;
BEGIN
    IF p_id IS NOT NULL THEN
        OPEN result_cursor FOR
            SELECT * FROM GUESTS WHERE GUEST_ID = p_id;
    ELSE
        OPEN result_cursor FOR
            SELECT * FROM GUESTS;
    END IF;
    RETURN result_cursor;
END GetGuestsCursor;

FUNCTION GetEmployeesCursor(p_id NUMBER DEFAULT NULL) RETURN SYS_REFCURSOR
    AS
    result_cursor SYS_REFCURSOR;
BEGIN
    IF p_id IS NOT NULL THEN
        OPEN result_cursor FOR
            SELECT * FROM EMPLOYEES WHERE EMPLOYEE_ID = p_id;
    ELSE
        OPEN result_cursor FOR
            SELECT * FROM EMPLOYEES;
    END IF;
    RETURN result_cursor;
END GetEmployeesCursor;

FUNCTION GetBookingCursor(p_id NUMBER DEFAULT NULL) RETURN SYS_REFCURSOR
    AS
    result_cursor SYS_REFCURSOR;
BEGIN
    IF p_id IS NOT NULL THEN
        OPEN result_cursor FOR
            SELECT * FROM BOOKING WHERE BOOKING_ID = p_id;
    ELSE
        OPEN result_cursor FOR
            SELECT * FROM BOOKING;
    END IF;
    RETURN result_cursor;
END GetBookingCursor;

FUNCTION GetBookingStateCursor(p_id NUMBER DEFAULT NULL) RETURN SYS_REFCURSOR
    AS
    result_cursor SYS_REFCURSOR;
BEGIN
    IF p_id IS NOT NULL THEN
        OPEN result_cursor FOR
            SELECT * FROM BOOKING_STATE WHERE BOOKING_STATE_ID = p_id;
    ELSE
        OPEN result_cursor FOR
            SELECT * FROM BOOKING_STATE;
    END IF;
    RETURN result_cursor;
END GetBookingStateCursor;

FUNCTION GetPhotoCursor(p_id NUMBER DEFAULT NULL) RETURN SYS_REFCURSOR
    AS
    result_cursor SYS_REFCURSOR;
BEGIN
    IF p_id IS NOT NULL THEN
        OPEN result_cursor FOR
            SELECT * FROM PHOTO WHERE PHOTO_ID = p_id;
    ELSE
        OPEN result_cursor FOR
            SELECT * FROM PHOTO;
    END IF;
    RETURN result_cursor;
END GetPhotoCursor;

FUNCTION GetRoomTypeCursor(p_id NUMBER DEFAULT NULL) RETURN SYS_REFCURSOR
    AS
    result_cursor SYS_REFCURSOR;
BEGIN
    IF p_id IS NOT NULL THEN
        OPEN result_cursor FOR
            SELECT * FROM ROOM_TYPES WHERE ROOM_TYPE_ID = p_id;
    ELSE
        OPEN result_cursor FOR
            SELECT * FROM ROOM_TYPES;
    END IF;
    RETURN result_cursor;
END GetRoomTypeCursor;

FUNCTION GetRoomCursor(p_id NUMBER DEFAULT NULL) RETURN SYS_REFCURSOR
    AS
    result_cursor SYS_REFCURSOR;
BEGIN
    IF p_id IS NOT NULL THEN
        OPEN result_cursor FOR
            SELECT * FROM ROOMS WHERE ROOM_ID = p_id;
    ELSE
        OPEN result_cursor FOR
            SELECT * FROM ROOMS;
    END IF;
    RETURN result_cursor;
END GetRoomCursor;

FUNCTION GetServiceTypeCursor(p_id NUMBER DEFAULT NULL) RETURN SYS_REFCURSOR
    AS
    result_cursor SYS_REFCURSOR;
BEGIN
    IF p_id IS NOT NULL THEN
        OPEN result_cursor FOR
            SELECT * FROM SERVICE_TYPES WHERE SERVICE_TYPE_ID = p_id;
    ELSE
        OPEN result_cursor FOR
            SELECT * FROM SERVICE_TYPES;
    END IF;
    RETURN result_cursor;
END GetServiceTypeCursor;

FUNCTION GetServiceCursor(p_id NUMBER DEFAULT NULL) RETURN SYS_REFCURSOR
    AS
    result_cursor SYS_REFCURSOR;
BEGIN
    IF p_id IS NOT NULL THEN
        OPEN result_cursor FOR
            SELECT * FROM SERVICES WHERE SERVICE_ID = p_id;
    ELSE
        OPEN result_cursor FOR
            SELECT * FROM SERVICES;
    END IF;
    RETURN result_cursor;
END GetServiceCursor;

FUNCTION GetTariffCursor(p_id NUMBER DEFAULT NULL) RETURN SYS_REFCURSOR
    AS
    result_cursor SYS_REFCURSOR;
BEGIN
    OPEN result_cursor FOR
        SELECT * FROM TARIFF_TYPES;
    RETURN result_cursor;
END GetTariffCursor;




-- ****************************************************************
-- Процедуры для вывода
-- ****************************************************************
PROCEDURE GetGuests(p_id NUMBER DEFAULT NULL) AS
    v_cursor SYS_REFCURSOR;
    v_info GUESTS%ROWTYPE;
BEGIN
    v_cursor := GetGuestsCursor(p_id);

    LOOP
        FETCH v_cursor INTO v_info;
        EXIT WHEN v_cursor%NOTFOUND;

        DBMS_OUTPUT.PUT_LINE('ID гостя: ' || v_info.GUEST_ID ||
                             ', Email: ' || v_info.GUEST_EMAIL ||
                             ', Имя: ' || v_info.GUEST_NAME ||
                             ', Фамилия: ' || v_info.GUEST_SURNAME ||
                             ', Имя пользователя: ' || v_info.USERNAME);
    END LOOP;

    CLOSE v_cursor;
END GetGuests;



PROCEDURE GetEmployees(p_id NUMBER DEFAULT NULL) AS
    v_cursor SYS_REFCURSOR;
    v_info EMPLOYEES%ROWTYPE;
BEGIN
    v_cursor := GetEmployeesCursor(p_id);

    LOOP
        FETCH v_cursor INTO v_info;
        EXIT WHEN v_cursor%NOTFOUND;

        DBMS_OUTPUT.PUT_LINE('ID сотрудника: ' || v_info.EMPLOYEE_ID ||
                             ', Имя: ' || v_info.EMPLOYEE_NAME ||
                             ', Фамилия: ' || v_info.EMPLOYEE_SURNAME ||
                             ', Должность: ' || v_info.EMPLOYEE_POSITION ||
                             ', Email: ' || v_info.EMPLOYEE_EMAIL ||
                             ', Дата найма: ' || v_info.EMPLOYEE_HIRE_DATE ||
                             ', Дата рождения: ' || v_info.EMPLOYEE_BIRTH_DATE);
    END LOOP;

    CLOSE v_cursor;
END GetEmployees;


PROCEDURE GetBookings(p_id NUMBER DEFAULT NULL) AS
    v_cursor SYS_REFCURSOR;
    v_booking_info BOOKING%ROWTYPE;
BEGIN
    v_cursor := GetBookingCursor(p_id);

    LOOP
        FETCH v_cursor INTO v_booking_info;
        EXIT WHEN v_cursor%NOTFOUND;

        DBMS_OUTPUT.PUT_LINE('ID брони: ' || v_booking_info.BOOKING_ID ||
                             ', ID комнаты: ' || v_booking_info.BOOKING_ROOM_ID ||
                             ', ID гостя: ' || v_booking_info.BOOKING_GUEST_ID ||
                             ', Дата начала: ' || TO_CHAR(v_booking_info.BOOKING_START_DATE, 'DD.MM.YYYY') ||
                             ', Дата окончания: ' || TO_CHAR(v_booking_info.BOOKING_END_DATE, 'DD.MM.YYYY') ||
                             ', ID тарифа: ' || v_booking_info.BOOKING_TARIFF_ID ||
                             ', Статус: ' || v_booking_info.BOOKING_STATE);
    END LOOP;

    CLOSE v_cursor;
END GetBookings;

PROCEDURE GetBookingStates(p_id NUMBER DEFAULT NULL) AS
    v_cursor SYS_REFCURSOR;
    v_booking_state_info BOOKING_STATE%ROWTYPE;
BEGIN
    v_cursor := GetBookingStateCursor(p_id);

    LOOP
        FETCH v_cursor INTO v_booking_state_info;
        EXIT WHEN v_cursor%NOTFOUND;

        DBMS_OUTPUT.PUT_LINE('ID статуса бронирования: ' || v_booking_state_info.BOOKING_STATE_ID ||
                             ', Статус бронирования: ' || v_booking_state_info.BOOKING_STATE);
    END LOOP;

    CLOSE v_cursor;
END GetBookingStates;


PROCEDURE GetPhotos(p_id NUMBER DEFAULT NULL) AS
    v_cursor SYS_REFCURSOR;
    v_info PHOTO%ROWTYPE;
BEGIN
    v_cursor := GetPhotoCursor(p_id);

    LOOP
        FETCH v_cursor INTO v_info;
        EXIT WHEN v_cursor%NOTFOUND;

        DBMS_OUTPUT.PUT_LINE('ID фотографии: ' || v_info.PHOTO_ID ||
                             ', ID типа комнаты: ' || v_info.PHOTO_ROOM_TYPE_ID ||
                             ', Источник фото: ' );--|| v_info.PHOTO_SOURCE
    END LOOP;

    CLOSE v_cursor;
END GetPhotos;


PROCEDURE GetRoomTypes(p_id NUMBER DEFAULT NULL) AS
    v_cursor SYS_REFCURSOR;
    v_info ROOM_TYPES%ROWTYPE;
BEGIN
    v_cursor := GetRoomTypeCursor(p_id);

    LOOP
        FETCH v_cursor INTO v_info;
        EXIT WHEN v_cursor%NOTFOUND;

        DBMS_OUTPUT.PUT_LINE('ID типа комнаты: ' || v_info.ROOM_TYPE_ID ||
                             ', Название: ' || v_info.ROOM_TYPE_NAME ||
                             ', Вместимость: ' || v_info.ROOM_TYPE_CAPACITY ||
                             ', Суточная стоимость: ' || v_info.ROOM_TYPE_DAILY_PRICE ||
                             ', Описание: ' || v_info.ROOM_TYPE_DESCRIPTION);
    END LOOP;

    CLOSE v_cursor;
END GetRoomTypes;


PROCEDURE GetRooms(p_id NUMBER DEFAULT NULL) AS
    v_cursor SYS_REFCURSOR;
    v_info ROOMS%ROWTYPE;
BEGIN
    v_cursor := GetRoomCursor(p_id);

    LOOP
        FETCH v_cursor INTO v_info;
        EXIT WHEN v_cursor%NOTFOUND;

        DBMS_OUTPUT.PUT_LINE('ID комнаты: ' || v_info.ROOM_ID ||
                             ', ID типа комнаты: ' || v_info.ROOM_ROOM_TYPE_ID ||
                             ', Номер комнаты: ' || v_info.ROOM_NUMBER);
    END LOOP;

    CLOSE v_cursor;
END GetRooms;


PROCEDURE GetServiceTypes(p_id NUMBER DEFAULT NULL) AS
    v_cursor SYS_REFCURSOR;
    v_info SERVICE_TYPES%ROWTYPE;
BEGIN
    v_cursor := GetServiceTypeCursor(p_id);

    LOOP
        FETCH v_cursor INTO v_info;
        EXIT WHEN v_cursor%NOTFOUND;

        DBMS_OUTPUT.PUT_LINE('ID типа услуги: ' || v_info.SERVICE_TYPE_ID ||
                             ', Название: ' || v_info.SERVICE_TYPE_NAME ||
                             ', Описание: ' || v_info.SERVICE_TYPE_DESCRIPTION ||
                             ', Суточная стоимость: ' || v_info.SERVICE_TYPE_DAILY_PRICE ||
                             ', ID сотрудника: ' || v_info.SERVICE_TYPE_EMPLOYEE_ID);
    END LOOP;

    CLOSE v_cursor;
END GetServiceTypes;



PROCEDURE GetServices(p_id NUMBER DEFAULT NULL) AS
    v_cursor SYS_REFCURSOR;
    v_info SERVICES%ROWTYPE;
BEGIN
    v_cursor := GetServiceCursor(p_id);

    LOOP
        FETCH v_cursor INTO v_info;
        EXIT WHEN v_cursor%NOTFOUND;

        DBMS_OUTPUT.PUT_LINE('ID услуги: ' || v_info.SERVICE_ID ||
                             ', ID типа услуги: ' || v_info.SERVICE_TYPE_ID ||
                             ', ID гостя: ' || v_info.SERVICE_GUEST_ID ||
                             ', Дата начала: ' || v_info.SERVICE_START_DATE ||
                             ', Дата окончания: ' || v_info.SERVICE_END_DATE);
    END LOOP;

    CLOSE v_cursor;
END GetServices;


PROCEDURE GetTariffTypes(p_id NUMBER DEFAULT NULL) AS
    v_cursor SYS_REFCURSOR;
    v_info TARIFF_TYPES%ROWTYPE;
BEGIN
    v_cursor := GetTariffCursor(p_id);

    LOOP
        FETCH v_cursor INTO v_info;
        EXIT WHEN v_cursor%NOTFOUND;

        DBMS_OUTPUT.PUT_LINE('ID типа тарифа: ' || v_info.TARIFF_TYPE_ID ||
                             ', Название: ' || v_info.TARIFF_TYPE_NAME ||
                             ', Описание: ' || v_info.TARIFF_TYPE_DESCRIPTION ||
                             ', Суточная стоимость: ' || v_info.TARIFF_TYPE_DAILY_PRICE);
    END LOOP;

    CLOSE v_cursor;
END GetTariffTypes;






END HotelAdminPack;
/