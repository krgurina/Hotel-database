CREATE OR REPLACE PACKAGE UserPack AS
    -- 1.
    PROCEDURE BookingNow(
        p_room_id IN NUMBER,
        p_guest_id IN NUMBER,
        p_end_date IN DATE,
        p_tariff_id IN NUMBER,
        p_booking_id OUT NUMBER);

    PROCEDURE PreBooking(
        p_room_id NUMBER,
        p_guest_id NUMBER,
        p_start_date DATE,
        p_end_date DATE,
        p_tariff_id IN NUMBER,
        p_booking_id OUT NUMBER);

    PROCEDURE GetBookingDetailsById(
        p_booking_id NUMBER);

    PROCEDURE UpdateBooking(
        p_booking_id NUMBER,
        p_room_id NUMBER DEFAULT NULL,
        p_start_date DATE DEFAULT NULL,
        p_end_date DATE DEFAULT NULL,
        p_tariff_id NUMBER DEFAULT NULL);

    PROCEDURE DenyBooking(
        p_booking_id NUMBER);


    PROCEDURE OrderService(
    p_service_type_id NUMBER,
    --p_service_guest_id NUMBER,
    p_service_start_date DATE,
    p_service_end_date DATE);

PROCEDURE EditService(
    p_service_id NUMBER,
    p_service_type_id NUMBER DEFAULT NULL,
    p_service_start_date DATE DEFAULT NULL,
    p_service_end_date DATE DEFAULT NULL);


END UserPack;
/

CREATE OR REPLACE PACKAGE BODY UserPack AS

PROCEDURE BookingNow(
    p_room_id IN NUMBER,
    p_guest_id IN NUMBER,
    p_end_date IN DATE,
    p_tariff_id IN NUMBER,
    p_booking_id OUT NUMBER)
AS
    v_guest_exists NUMBER;
    v_room_exists NUMBER;
    v_room_available NUMBER;
    v_tariff_exists NUMBER;
    v_start_date DATE;

BEGIN
     -- существования гостя
    SELECT COUNT(*) INTO v_guest_exists FROM GUESTS
    WHERE GUEST_ID = p_guest_id;
    IF v_guest_exists = 0 THEN
        RAISE_APPLICATION_ERROR(-20001, 'Гость с указанным ID не найден.');
    END IF;

    -- существования номера
    SELECT COUNT(*) INTO v_room_exists FROM ROOMS
    WHERE room_id = p_room_id;
    IF v_room_exists = 0 THEN
        RAISE_APPLICATION_ERROR(-20001, 'Номер с указанным ID не найден.');
    END IF;

     --тариф
    SELECT COUNT(*) INTO v_tariff_exists FROM TARIFF_TYPES
    WHERE TARIFF_TYPE_ID = p_tariff_id;
    IF v_tariff_exists = 0 THEN
        RAISE_APPLICATION_ERROR(-20002, 'Тариф с указанным ID не найден.');
    END IF;

    IF p_end_date <= SYSDATE THEN
      RAISE_APPLICATION_ERROR(-20001, 'Дата окончания проживания должна быть позже текущей даты.');
    END IF;

    -- доступность номера
    SELECT COUNT(*) INTO v_room_available FROM AVAILABLE_ROOMS_VIEW
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
            2
        ) RETURNING booking_id INTO p_booking_id;
        commit;
        DBMS_OUTPUT.PUT_LINE('Бронирование успешно добавлено.');
    END IF;
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Произошла ошибка: ' || SQLERRM);
        ROLLBACK;
END BookingNow;

----------------------------------------------------------------
PROCEDURE PreBooking(
    p_room_id NUMBER,
    p_guest_id NUMBER,
    p_start_date DATE,
    p_end_date DATE,
    p_tariff_id IN NUMBER,
    p_booking_id OUT NUMBER)
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
        RAISE_APPLICATION_ERROR(-20004, 'Даты брони не могут быть позже текущей.');
    END IF;

    INSERT INTO BOOKING (booking_room_id, booking_guest_id, booking_start_date, booking_end_date, booking_tariff_id)
    VALUES (
            p_room_id,
            p_guest_id,
            p_start_date,
            p_end_date,
            1) RETURNING booking_id INTO p_booking_id;
    COMMIT;
    DBMS_OUTPUT.PUT_LINE('Бронирование успешно добавлено.');
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Произошла ошибка: ' || SQLERRM);
        ROLLBACK;
END PreBooking;

----------------------------------------------------------------
PROCEDURE GetBookingDetailsById(
    p_booking_id NUMBER
)
AS
    p_booking_details booking_details_view%ROWTYPE;
    v_booking_exists NUMBER;
BEGIN
    -- существование брони
    SELECT COUNT(*) INTO v_booking_exists FROM BOOKING
    WHERE BOOKING_ID = p_booking_id;
    IF v_booking_exists = 0 THEN
        RAISE_APPLICATION_ERROR(-20001, 'Бронь с указанным ID не найдена.');
    END IF;

    SELECT * INTO p_booking_details FROM booking_details_view
    WHERE booking_id = p_booking_id;

    IF p_booking_details.BOOKING_STATE = 3 THEN
        RAISE_APPLICATION_ERROR(-20006, 'Бронь с указанным ID отменена.');
    END IF;
    DBMS_OUTPUT.PUT_LINE('Информация о брони с ID ' || p_booking_id || ' успешно получена.');
    DBMS_OUTPUT.PUT_LINE('ID брони: ' || p_booking_details.booking_id);
    DBMS_OUTPUT.PUT_LINE('Начальная дата: ' || p_booking_details.booking_start_date);
    DBMS_OUTPUT.PUT_LINE('Конечная дата: ' || p_booking_details.booking_end_date);
    DBMS_OUTPUT.PUT_LINE('Статус брони: ' || p_booking_details.booking_state);
    DBMS_OUTPUT.PUT_LINE('Имя гостя: ' || p_booking_details.guest_name);
    DBMS_OUTPUT.PUT_LINE('Фамилия гостя: ' || p_booking_details.guest_surname);
    DBMS_OUTPUT.PUT_LINE('Номер комнаты: ' || p_booking_details.room_number);
    DBMS_OUTPUT.PUT_LINE('Тип комнаты: ' || p_booking_details.room_type_name);
    DBMS_OUTPUT.PUT_LINE('Тип тарифа: ' || p_booking_details.tariff_type_name);
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Произошла ошибка: ' || SQLERRM);
END GetBookingDetailsById;

----------------------------------------------------------------
PROCEDURE UpdateBooking(
    p_booking_id NUMBER,
    p_room_id NUMBER DEFAULT NULL,
    --p_guest_id NUMBER DEFAULT NULL,
    p_start_date DATE DEFAULT NULL,
    p_end_date DATE DEFAULT NULL,
    p_tariff_id NUMBER DEFAULT NULL)
AS
    v_old_booking BOOKING%ROWTYPE;
    v_booking_count NUMBER;
    v_room_count NUMBER;
    v_guest_count NUMBER;
    v_tariff_count NUMBER;
    v_current_user VARCHAR2(30);
    v_current_user_id NUMBER;
BEGIN
    v_current_user := USER;

    SELECT GUEST_ID INTO v_current_user_id from GUESTS
        where lower(USERNAME) = lower(v_current_user);

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

    IF v_current_user_id IS NOT NULL THEN
        SELECT COUNT(*) INTO v_guest_count
                FROM GUESTS
                WHERE guest_id = v_current_user_id;
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

    IF v_old_booking.BOOKING_GUEST_ID <> v_current_user_id THEN
        RAISE_APPLICATION_ERROR(-20008, 'Вы можете изменять только свою бронь.');
    END IF;

    IF v_old_booking.BOOKING_STATE=3 THEN
        RAISE_APPLICATION_ERROR(-20007, 'Изменения невозможны. Ваша бронь была отменена.');
    END IF;


    UPDATE BOOKING
    SET
        booking_room_id = COALESCE(p_room_id, v_old_booking.booking_room_id),
        booking_guest_id = v_old_booking.booking_guest_id,
        booking_start_date = COALESCE(p_start_date, v_old_booking.booking_start_date),
        booking_end_date = COALESCE(p_end_date, v_old_booking.booking_end_date),
        booking_tariff_id = COALESCE(p_tariff_id, v_old_booking.booking_tariff_id)
    WHERE booking_id = p_booking_id;
    COMMIT;

    DBMS_OUTPUT.PUT_LINE('Бронирование с ID '|| p_booking_id ||' успешно обновлено.');
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Произошла ошибка: ' || SQLERRM);
        ROLLBACK;
END UpdateBooking;

----------------------------------------------------------------
PROCEDURE DenyBooking(
    p_booking_id NUMBER
)
AS
    v_booking_exists NUMBER;
BEGIN
    SELECT COUNT(*) INTO v_booking_exists
    FROM BOOKING WHERE booking_id = p_booking_id;
    IF v_booking_exists = 0 THEN
        RAISE_APPLICATION_ERROR(-20001, 'Бронь с указанным ID не найдена.');
    END IF;

    UPDATE BOOKING
    SET booking_state = 3
    WHERE booking_id = p_booking_id;
    COMMIT;

    DBMS_OUTPUT.PUT_LINE('Бронь с ID ' || p_booking_id || ' успешно отменена.');
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Произошла ошибка: ' || SQLERRM);
        ROLLBACK;
END DenyBooking;

----------------------------------------------------------------
PROCEDURE OrderService(
    p_service_type_id NUMBER,
    p_service_start_date DATE,
    p_service_end_date DATE)
AS
    v_service_type_count NUMBER;
    v_guest_count NUMBER;
    v_booking_count NUMBER;
    v_service_id NUMBER;
    v_current_user VARCHAR2(30);
    v_current_user_id NUMBER;
    --

BEGIN
    v_current_user := USER;
    DBMS_OUTPUT.PUT_LINE('Текущий пользователь: ' || v_current_user);

    SELECT GUEST_ID INTO v_current_user_id from GUESTS
        where lower(USERNAME) = lower(v_current_user);


-----

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
    WHERE guest_id = v_current_user_id;
    IF v_guest_count = 0 THEN
        RAISE_APPLICATION_ERROR(-20002, 'Гость с указанным ID не найден.');
    END IF;

    -- Проверка, что гость имеет бронь на указанный период
    SELECT COUNT(*) INTO v_booking_count
    FROM BOOKING
    WHERE BOOKING_GUEST_ID = v_current_user_id
        AND (p_service_start_date BETWEEN booking_start_date AND booking_end_date
             OR p_service_end_date BETWEEN booking_start_date AND booking_end_date);

    IF v_booking_count = 0 THEN
        RAISE_APPLICATION_ERROR(-20003, 'Вы не имеет брони на указанный период.');
    END IF;

    IF p_service_start_date >= p_service_end_date THEN
        RAISE_APPLICATION_ERROR(-20004, 'Дата начала услуги должна быть раньшеь даты окончания.');
    END IF;

    INSERT INTO SERVICES (
                          service_type_id,
                          service_guest_id,
                          service_start_date,
                          service_end_date)
    VALUES (
            p_service_type_id,
            v_current_user_id,
            p_service_start_date,
            p_service_end_date) returning SERVICE_ID into v_service_id;

    COMMIT;
    DBMS_OUTPUT.PUT_LINE('Сервис успешно заказан. ID: '|| v_service_id);

EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Произошла ошибка: ' || SQLERRM);
        ROLLBACK;
END OrderService;


PROCEDURE EditService(
    p_service_id NUMBER,
    p_service_type_id NUMBER DEFAULT NULL,
    --p_service_guest_id NUMBER DEFAULT NULL,
    p_service_start_date DATE DEFAULT NULL,
    p_service_end_date DATE DEFAULT NULL)
AS
    v_service_count NUMBER;
    v_service_type_count NUMBER;
    --v_guest_count NUMBER;
    v_existing_service SERVICES%ROWTYPE;
    v_current_user VARCHAR2(30);
    v_current_user_id NUMBER;--VARCHAR2(30);
    --v_current_service service_view%ROWTYPE;

BEGIN
    v_current_user := USER;
    DBMS_OUTPUT.PUT_LINE('Текущий пользователь: ' || v_current_user);

    SELECT GUEST_ID INTO v_current_user_id from GUESTS
        where lower(USERNAME) = lower(v_current_user);
--
    SELECT COUNT(*) INTO v_service_count
        FROM SERVICES
        WHERE service_id = p_service_id;
    IF v_service_count = 0 THEN
        RAISE_APPLICATION_ERROR(-20001, 'Услуга с указанным ID не найдено.');
    END IF;

    SELECT * INTO v_existing_service
    FROM SERVICES
    WHERE SERVICE_ID = p_service_id;

    IF v_existing_service.SERVICE_GUEST_ID <> v_current_user_id THEN
        RAISE_APPLICATION_ERROR(-20008, 'Вы можете изменять только заказанный вами сервис.');
    END IF;
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


    UPDATE SERVICES
    SET
        service_type_id = COALESCE(p_service_type_id, v_existing_service.SERVICE_TYPE_ID),
        service_guest_id = v_existing_service.SERVICE_GUEST_ID,
        service_start_date = COALESCE(p_service_start_date, v_existing_service.SERVICE_START_DATE),
        service_end_date = COALESCE(p_service_end_date,  v_existing_service.SERVICE_END_DATE)
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
END EditService;





END UserPack;
/
