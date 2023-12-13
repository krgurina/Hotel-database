CREATE OR REPLACE PACKAGE UserPackageProc AS
    -- 1.
PROCEDURE BookingNow(
    p_room_id IN NUMBER,
    p_guest_id IN NUMBER,
    p_start_date IN DATE,
    p_end_date IN DATE,
    p_tariff_id IN NUMBER);
--2
PROCEDURE PreBooking(
    p_room_id NUMBER,
    p_guest_id NUMBER,
    p_start_date DATE,
    p_end_date DATE,
    p_tariff_id IN NUMBER);
--3
PROCEDURE DenyBooking(
    p_booking_id IN NUMBER);
--4
    PROCEDURE OrderService(
    p_service_type_id NUMBER,
    p_service_guest_id NUMBER,
    p_service_start_date DATE,
    p_service_end_date DATE);
--5
     PROCEDURE ChangeOrderedService(
    p_service_id NUMBER,
    p_service_type_id NUMBER,
    p_service_guest_id NUMBER,
    p_service_start_date DATE,
    p_service_end_date DATE);
--6
    PROCEDURE DenyOrderedService(p_service_id NUMBER);
--7 процедуры GET
    PROCEDURE GetBookingDetailsBySurname(
    p_guest_surname IN NVARCHAR2(50),
    p_booking_details OUT booking_details_view%ROWTYPE);

END UserPackageProc;
/

CREATE OR REPLACE PACKAGE BODY UserPackageProc AS

PROCEDURE BookingNow(
    p_room_id IN NUMBER,
    p_guest_id IN NUMBER,
    p_end_date IN DATE,
    p_tariff_id IN NUMBER
)
AS
    v_room_exists NUMBER;
    v_room_available NUMBER;
    v_tariff_exists NUMBER;
    v_start_date DATE;

BEGIN
    -- существования номера
    SELECT COUNT(*) INTO v_room_exists
    FROM ROOMS
    WHERE room_id = p_room_id;
    IF v_room_exists = 0 THEN
        RAISE_APPLICATION_ERROR(-20001, 'Номер с указанным ID не найден.');
    END IF;

    SELECT COUNT(*) INTO v_tariff_exists
    FROM TARIFF_TYPES
    WHERE TARIFF_TYPE_ID = p_tariff_id;
    IF v_tariff_exists = 0 THEN
        RAISE_APPLICATION_ERROR(-20002, 'Тариф с указанным ID не найден.');
    END IF;

    -- доступность номера
    SELECT COUNT(*)
    INTO v_room_available
    FROM AVAILABLE_ROOMS_VIEW
    WHERE room_id = p_room_id;

    IF v_room_available = 0 THEN
        RAISE_APPLICATION_ERROR(-20003,'Выбранный номер недоступен на указанные даты.');
    ELSE

        v_start_date :=  SYSDATE;

        INSERT INTO BOOKING (
            booking_room_id,
            booking_guest_id,
            booking_start_date,
            booking_end_date,
            booking_tariff_id,
            BOOKING_STATE
        ) VALUES (
            p_room_id,
            p_guest_id,
            v_start_date,
            p_end_date,
            p_tariff_id,
            1
        );
        DBMS_OUTPUT.PUT_LINE('Бронирование успешно добавлено.');
    END IF;
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Произошла ошибка: ' || SQLERRM);
END BookingNow;

----------------------------------------------------------------
PROCEDURE PreBooking(   -- там потом триггер или админ будут что-то делать с этим
    p_room_id NUMBER,
    p_guest_id NUMBER,
    p_start_date DATE,
    p_end_date DATE,
    p_tariff_id IN NUMBER)
AS
    v_current_date DATE := SYSDATE;
    v_room_exists NUMBER;
    v_room_available NUMBER;
    v_tariff_exists NUMBER;
BEGIN
    SELECT COUNT(*) INTO v_room_exists
    FROM ROOMS
    WHERE room_id = p_room_id;
    IF v_room_exists = 0 THEN
        RAISE_APPLICATION_ERROR(-20001, 'Номер с указанным ID не найден.');
    END IF;

    SELECT COUNT(*) INTO v_tariff_exists
    FROM TARIFF_TYPES
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

    INSERT INTO BOOKING (booking_room_id, booking_guest_id, booking_start_date, booking_end_date, booking_state, booking_tariff_id)
    VALUES (p_room_id, p_guest_id, p_start_date, p_end_date, 0, 1);
    COMMIT;
    DBMS_OUTPUT.PUT_LINE('Бронирование успешно выполнено.');

EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Произошла ошибка: ' || SQLERRM);
        ROLLBACK;
END PreBooking;
----------------------------------------------------------------

PROCEDURE DenyBooking(
    p_booking_id IN NUMBER
)
AS
    v_booking_exists NUMBER;
BEGIN
     SELECT COUNT(*) INTO v_booking_exists
    FROM BOOKING
    WHERE booking_id = p_booking_id;

    IF v_booking_exists = 0 THEN
        RAISE_APPLICATION_ERROR(-20004, 'Бронь с указанным ID не найдена.');
    END IF;
    -- Изменяем статус бронирования на 2 (Отменено)
    UPDATE BOOKING
    SET booking_state = 2
    WHERE booking_id = p_booking_id;

    DBMS_OUTPUT.PUT_LINE('Бронь с ID ' || p_booking_id || ' успешно отменена.');
    COMMIT;
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Произошла ошибка: ' || SQLERRM);
        ROLLBACK;
END DenyBooking;
----------------------------------------------------------------
PROCEDURE OrderService(
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
END OrderService;

----------------------------------------------------------------
    PROCEDURE ChangeOrderedService(
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


    IF v_service_count = 0 THEN
        RAISE_APPLICATION_ERROR(-20002, 'Вы не можете удалить услугу, которую заказал другой пользователь.');
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
END ChangeOrderedService;
----------------------------------------------------------------
PROCEDURE DenyOrderedService(
    p_service_id NUMBER)
--     p_user_id NUMBER)   --проверить чтобы пользователь удалял только свой сервис
AS
    v_service_count NUMBER;

BEGIN

    SELECT COUNT(*) INTO v_service_count
        FROM SERVICES
        WHERE service_id = p_service_id;
    IF v_service_count = 0 THEN
        RAISE_APPLICATION_ERROR(-20001, 'Услуга с указанным ID не найдена.');
    END IF;

--     SELECT COUNT(*)
--     INTO v_service_count
--     FROM SERVICES
--     WHERE service_id = p_service_id
--         AND user_id = p_user_id;

    IF v_service_count = 0 THEN
        RAISE_APPLICATION_ERROR(-20002, 'Вы не можете удалить услугу, которую заказал другой пользователь.');
    END IF;

    DELETE FROM SERVICES WHERE service_id = p_service_id;
    COMMIT;
    DBMS_OUTPUT.PUT_LINE('Сервис успешно удален.');

EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Произошла ошибка: ' || SQLERRM);
        ROLLBACK;
END DenyOrderedService;

-- GET процедуры
    PROCEDURE GetBookingDetailsBySurname(
    p_guest_surname IN NVARCHAR2(50),
    p_booking_details OUT booking_details_view%ROWTYPE
)
AS
BEGIN
    -- Извлекаем информацию о брони с использованием представления
    SELECT *
    INTO p_booking_details
    FROM ADMIN.booking_details_view
    WHERE guest_surname = p_guest_surname;

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RAISE_APPLICATION_ERROR(-20001, 'Бронь с указанным ID (' || p_guest_surname || ') не найдена.');
    WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(-20002, 'Произошла ошибка: ' || SQLERRM);
END GetBookingDetailsBySurname;

END UserPackageProc;
/

