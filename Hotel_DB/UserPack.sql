CREATE OR REPLACE PACKAGE UserPack AS
    PROCEDURE GET_AVAILABLE_ROOMS(
        p_capacity NUMBER,
        p_start_date DATE,
        p_end_date DATE);

    PROCEDURE BOOKING_NOW(
        p_room_id NUMBER,
        p_end_date DATE,
        p_tariff_id NUMBER);

    PROCEDURE PRE_BOOKING(
        p_room_id NUMBER,
        p_start_date DATE,
        p_end_date DATE,
        p_tariff_id NUMBER);

    PROCEDURE Get_BookingDetails_By_Id(
        p_booking_id NUMBER);

    PROCEDURE Edit_Booking(
        p_booking_id NUMBER,
        p_room_id NUMBER DEFAULT NULL,
        p_start_date DATE DEFAULT NULL,
        p_end_date DATE DEFAULT NULL,
        p_tariff_id NUMBER DEFAULT NULL);

    PROCEDURE Deny_Booking(p_booking_id NUMBER);

    PROCEDURE Restore_Booking(p_booking_id NUMBER);

    PROCEDURE Order_Service(
    p_service_type_id NUMBER,
    p_service_start_date DATE,
    p_service_end_date DATE);

PROCEDURE Edit_Service(
    p_service_id NUMBER,
    p_service_type_id NUMBER DEFAULT NULL,
    p_service_start_date DATE DEFAULT NULL,
    p_service_end_date DATE DEFAULT NULL);

PROCEDURE Get_Service_Info(p_id NUMBER DEFAULT NULL);
PROCEDURE Get_Tariff_Info(p_id NUMBER DEFAULT NULL);
PROCEDURE Get_Room_Info(p_id NUMBER DEFAULT NULL);

FUNCTION Calculate_Stay_Cost(p_booking_id IN NUMBER) RETURN FLOAT;
PROCEDURE Check_Out(p_booking_id NUMBER);

PROCEDURE GET_MY_SERVICES;
PROCEDURE GET_MY_BOOKINGS;

END UserPack;
/

CREATE OR REPLACE PACKAGE BODY UserPack AS

PROCEDURE GET_AVAILABLE_ROOMS(
    p_capacity NUMBER,
    p_start_date DATE,
    p_end_date DATE
)
AS
BEGIN
     -- Проверка вместимости
    IF p_capacity <= 0 OR p_capacity >= 15 THEN
        RAISE_APPLICATION_ERROR(-20001, 'Недопустимая вместимость. Укажите значение от 1 до 14.');
        --RETURN;
    END IF;

    -- Проверка дат
    IF p_start_date >= p_end_date THEN
        RAISE_APPLICATION_ERROR(-20002, 'Дата начала бронирования должна быть раньше даты окончания.');
        --RETURN;
    END IF;

    IF p_end_date >= TO_DATE('2025-01-01', 'YYYY-MM-DD') THEN
        RAISE_APPLICATION_ERROR(-20003, 'На данный момент бронирование на 2025 год и позже недоступно.');
        --RETURN;
    END IF;

    FOR room_rec IN (
        SELECT
            ri.room_id,
            ri.room_number,
            ri.room_type_name,
            ri.room_type_capacity,
            ri.room_type_daily_price,
            ri.room_type_description
        FROM
            room_info_view ri
        WHERE
            ri.room_id NOT IN (
                SELECT B.booking_room_id
                FROM BOOKED_ROOMS_VIEW B
                WHERE (B.BOOKING_START_DATE <= p_end_date AND B.BOOKING_END_DATE >= p_start_date)
            )
            AND ri.room_type_capacity = p_capacity
    )
    LOOP
        DBMS_OUTPUT.PUT_LINE('ID Комнаты: ' || room_rec.room_id);
        DBMS_OUTPUT.PUT_LINE('Номер комнаты: ' || room_rec.room_number);
        DBMS_OUTPUT.PUT_LINE('Тип комнаты: ' || room_rec.room_type_name);
        DBMS_OUTPUT.PUT_LINE('Вместимость: ' || room_rec.room_type_capacity);
        DBMS_OUTPUT.PUT_LINE('Стоимость за день: ' || TO_CHAR(room_rec.room_type_daily_price, '9999.99'));
        DBMS_OUTPUT.PUT_LINE('Описание: ' || room_rec.room_type_description);
        DBMS_OUTPUT.PUT_LINE('-------------------------');
    END LOOP;
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Произошла ошибка: ' || SQLERRM);
        ROLLBACK;
END GET_AVAILABLE_ROOMS;





PROCEDURE BOOKING_NOW(
    p_room_id NUMBER,
    p_end_date DATE,
    p_tariff_id NUMBER)
AS
    v_booking_id NUMBER;
    v_room_exists NUMBER;
    v_room_available NUMBER;
    v_tariff_exists NUMBER;
    v_start_date DATE;
    v_current_user VARCHAR2(30);
    v_current_user_id NUMBER;

BEGIN
    v_current_user := USER;

    SELECT GUEST_ID INTO v_current_user_id from GUESTS
        where lower(USERNAME) = lower(v_current_user);

     -- существования гостя
    IF v_current_user_id IS NULL THEN
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
        v_start_date := TO_DATE(SYSDATE, 'YYYY-MM-DD');

        INSERT INTO BOOKING (
            booking_room_id,
            booking_guest_id,
            booking_start_date,
            booking_end_date,
            booking_tariff_id,
            BOOKING_STATE
        ) VALUES (
            p_room_id,
            v_current_user_id,
            v_start_date,
            p_end_date,
            p_tariff_id,
            2
        ) RETURNING booking_id INTO v_booking_id;
        commit;
        DBMS_OUTPUT.PUT_LINE('Бронирование успешно добавлено. ID: '|| v_booking_id);
    END IF;
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Произошла ошибка: ' || SQLERRM);
        ROLLBACK;
END BOOKING_NOW;

----------------------------------------------------------------
PROCEDURE PRE_BOOKING(
    p_room_id NUMBER,
    p_start_date DATE,
    p_end_date DATE,
    p_tariff_id NUMBER)
AS
    v_current_date DATE := SYSDATE;
    v_booking_id NUMBER;
    v_room_exists NUMBER;
    v_room_available NUMBER;
    v_tariff_exists NUMBER;
    v_current_user VARCHAR2(30);
    v_current_user_id NUMBER;
BEGIN
    v_current_user := USER;

    SELECT GUEST_ID INTO v_current_user_id from GUESTS
        where lower(USERNAME) = lower(v_current_user);

    -- существования гостя
    IF v_current_user_id IS NULL THEN
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
        RAISE_APPLICATION_ERROR(-20003, 'Выбранный номер недоступен на указанные даты.');
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
            v_current_user_id,
            p_start_date,
            p_end_date,
            1) RETURNING booking_id INTO v_booking_id;
    COMMIT;
    DBMS_OUTPUT.PUT_LINE('Бронирование успешно добавлено. ID: '|| v_booking_id);
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Произошла ошибка: ' || SQLERRM);
        ROLLBACK;
END PRE_BOOKING;

----------------------------------------------------------------
PROCEDURE Get_BookingDetails_By_Id(
    p_booking_id NUMBER
)
AS
    p_booking_details booking_details_view%ROWTYPE;
    v_booking_exists NUMBER;
    v_current_user VARCHAR2(30);
    v_current_user_id NUMBER;
BEGIN
        v_current_user := USER;
    SELECT GUEST_ID INTO v_current_user_id from GUESTS
        where lower(USERNAME) = lower(v_current_user);

    -- существование брони
    SELECT COUNT(*) INTO v_booking_exists FROM BOOKING
    WHERE BOOKING_ID = p_booking_id;
    IF v_booking_exists = 0 THEN
        RAISE_APPLICATION_ERROR(-20001, 'Бронь с указанным ID не найдена.');
    END IF;

    SELECT * INTO p_booking_details FROM booking_details_view
    WHERE booking_id = p_booking_id;

    IF p_booking_details.BOOKING_GUEST_ID <> v_current_user_id THEN
        RAISE_APPLICATION_ERROR(-20008, 'Вы можете изменять только свою бронь.');
    END IF;

    IF p_booking_details.BOOKING_STATE_ID = 3 THEN
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
END Get_BookingDetails_By_Id;

----------------------------------------------------------------
PROCEDURE Edit_Booking(
    p_booking_id NUMBER,
    p_room_id NUMBER DEFAULT NULL,
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
END Edit_Booking;

----------------------------------------------------------------
PROCEDURE Deny_Booking(
    p_booking_id NUMBER
)
AS
    v_booking_exists NUMBER;
    v_booking BOOKING%rowtype;
    v_current_user VARCHAR2(30);
    v_current_user_id NUMBER;
BEGIN
    v_current_user := USER;

    SELECT GUEST_ID INTO v_current_user_id from GUESTS
        where lower(USERNAME) = lower(v_current_user);

    SELECT COUNT(*) INTO v_booking_exists
    FROM BOOKING WHERE booking_id = p_booking_id;
    IF v_booking_exists = 0 THEN
        RAISE_APPLICATION_ERROR(-20001, 'Бронь с указанным ID не найдена.');
    END IF;

    SELECT * INTO v_booking from BOOKING
        WHERE booking_id =p_booking_id;

    IF v_booking.BOOKING_GUEST_ID <> v_current_user_id THEN
        RAISE_APPLICATION_ERROR(-20008, 'Вы можете отменить только свою бронь.');
    END IF;

    IF v_booking.BOOKING_STATE=3 then
         RAISE_APPLICATION_ERROR(-20009, 'Бронь с ID ' || p_booking_id || ' Уже отменена.');
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
END Deny_Booking;

PROCEDURE Restore_Booking(
    p_booking_id NUMBER
)
AS
    v_booking_exists NUMBER;
    v_booking BOOKING%rowtype;
    v_current_user VARCHAR2(30);
    v_current_user_id NUMBER;
BEGIN
    v_current_user := USER;

    SELECT GUEST_ID INTO v_current_user_id from GUESTS
        where lower(USERNAME) = lower(v_current_user);

    SELECT COUNT(*) INTO v_booking_exists
    FROM BOOKING WHERE booking_id = p_booking_id;
    IF v_booking_exists = 0 THEN
        RAISE_APPLICATION_ERROR(-20001, 'Бронь с указанным ID не найдена. Возможно она уже была удалена.');
    END IF;

    SELECT * INTO v_booking from BOOKING
        WHERE booking_id =p_booking_id;

    IF v_booking.BOOKING_GUEST_ID <> v_current_user_id THEN
        RAISE_APPLICATION_ERROR(-20008, 'Вы можете отменить только свою бронь.');
    END IF;

    IF v_booking.BOOKING_STATE=1 or v_booking.BOOKING_STATE=2 then
         RAISE_APPLICATION_ERROR(-20009, 'Бронь с ID ' || p_booking_id || ' уже активна, вы не можете её восстановить.');
    END IF;

    UPDATE BOOKING
    SET booking_state = 2
    WHERE booking_id = p_booking_id;
    COMMIT;

    DBMS_OUTPUT.PUT_LINE('Бронь с ID ' || p_booking_id || ' успешно восстановлена.');
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Произошла ошибка: ' || SQLERRM);
        ROLLBACK;
END Restore_Booking;


----------------------------------------------------------------
PROCEDURE Order_Service(
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
END Order_Service;


PROCEDURE Edit_Service(
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
END Edit_Service;

----------------------------------------------------------------
PROCEDURE DenyService(p_service_id NUMBER)
AS
    v_service_count NUMBER;
    v_existing_service SERVICES%ROWTYPE;
    v_current_user VARCHAR2(30);
    v_current_user_id NUMBER;
BEGIN
    v_current_user := USER;

    SELECT COUNT(*) INTO v_service_count
        FROM SERVICES
        WHERE service_id = p_service_id;
    IF v_service_count = 0 THEN
        RAISE_APPLICATION_ERROR(-20001, 'Услуга с указанным ID не найдено.');
    END IF;

    SELECT * INTO v_existing_service FROM SERVICES
        WHERE service_id = p_service_id;


    IF v_existing_service.SERVICE_GUEST_ID <> v_current_user_id THEN
        RAISE_APPLICATION_ERROR(-20008, 'Вы можете отменить только заказанные вами услуги.');
    END IF;

        IF v_existing_service.SERVICE_START_DATE<SYSDATE and v_existing_service.SERVICE_END_DATE>=SYSDATE then

            UPDATE SERVICES
            SET SERVICE_END_DATE = TO_DATE(SYSDATE, 'YYYY-MM-DD')
            WHERE SERVICE_ID = p_service_id;
            COMMIT;
        end if;

    IF v_existing_service.SERVICE_START_DATE<SYSDATE and v_existing_service.SERVICE_END_DATE<SYSDATE then
        RAISE_APPLICATION_ERROR(-20009, 'Срок дейстивя услуги уже закончился, вы не можете её отменить.');
    end if;

    IF v_existing_service.SERVICE_START_DATE>SYSDATE and v_existing_service.SERVICE_END_DATE>SYSDATE then
        DELETE FROM SERVICES WHERE service_id=p_service_id;
        COMMIT;
    end if;


EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Произошла ошибка: ' || SQLERRM);
        ROLLBACK;
END DenyService;


PROCEDURE Get_Service_Info(p_id NUMBER DEFAULT NULL) AS
    v_cursor SYS_REFCURSOR;
    v_info SERVICE_TYPE_VIEW%ROWTYPE;
BEGIN
    OPEN v_cursor FOR
        SELECT *
        FROM SERVICE_TYPE_VIEW
        WHERE (p_id IS NULL OR SERVICE_TYPE_ID = p_id)
            AND SERVICE_TYPE_ID<50;

    LOOP
        FETCH v_cursor INTO v_info;
        EXIT WHEN v_cursor%NOTFOUND;

        DBMS_OUTPUT.PUT_LINE('ID типа сервиса: ' || v_info.SERVICE_TYPE_ID ||
                             ', Название типа сервиса: ' || v_info.SERVICE_TYPE_NAME ||
                             ', Описание типа сервиса: ' || v_info.SERVICE_TYPE_DESCRIPTION ||
                             ', Суточная цена: ' || v_info.SERVICE_TYPE_DAILY_PRICE ||
                             ', Имя сотрудника: ' || v_info.EMPLOYEE_NAME ||
                             ', Фамилия сотрудника: ' || v_info.EMPLOYEE_SURNAME);
    END LOOP;

    CLOSE v_cursor;
END Get_Service_Info;

PROCEDURE Get_Tariff_Info(p_id NUMBER DEFAULT NULL) AS
    v_cursor SYS_REFCURSOR;
    v_info TARIFF_TYPES%ROWTYPE;
BEGIN
    OPEN v_cursor FOR
        SELECT *
        FROM TARIFF_TYPES
        WHERE (p_id IS NULL OR TARIFF_TYPE_ID = p_id);

    LOOP
        FETCH v_cursor INTO v_info;
        EXIT WHEN v_cursor%NOTFOUND;

        DBMS_OUTPUT.PUT_LINE('ID тарифа: ' || v_info.TARIFF_TYPE_ID ||
                             ', Название тарифа: ' || v_info.TARIFF_TYPE_NAME ||
                             ', Описание тарифа: ' || v_info.TARIFF_TYPE_DESCRIPTION ||
                             ', Суточная цена: ' || v_info.TARIFF_TYPE_DAILY_PRICE);
    END LOOP;

    CLOSE v_cursor;
END Get_Tariff_Info;

PROCEDURE Get_Room_Info(p_id NUMBER DEFAULT NULL) AS
    v_cursor SYS_REFCURSOR;
    v_info room_info_view%ROWTYPE;
BEGIN
    OPEN v_cursor FOR
        SELECT *
        FROM room_info_view
        WHERE (p_id IS NULL OR room_id = p_id);

    LOOP
        FETCH v_cursor INTO v_info;
        EXIT WHEN v_cursor%NOTFOUND;

        DBMS_OUTPUT.PUT_LINE('ID номера: ' || v_info.room_id ||
                             ', Номер: ' || v_info.room_number ||
                             ', Тип номера: ' || v_info.room_type_name ||
                             ', Вместимость: ' || v_info.room_type_capacity ||
                             ', Суточная цена: ' || v_info.room_type_daily_price ||
                             ', Описание типа: ' || v_info.room_type_description);
    END LOOP;

    CLOSE v_cursor;
END Get_Room_Info;

FUNCTION Calculate_Stay_Cost(p_booking_id IN NUMBER) RETURN FLOAT AS
    v_total_cost FLOAT := 0;
    v_current_user VARCHAR2(30);
    v_current_user_id NUMBER;
    v_booking_state NUMBER;

BEGIN

    v_current_user := USER;
    SELECT GUEST_ID INTO v_current_user_id from GUESTS
        where lower(USERNAME) = lower(v_current_user);

  SELECT
    ((bk.BOOKING_END_DATE - bk.booking_start_date) * bk.room_type_daily_price +
    (bk.BOOKING_END_DATE - bk.BOOKING_START_DATE) * bk.tariff_type_daily_price), bk.BOOKING_STATE_ID
    INTO v_total_cost, v_booking_state
    FROM booking_details_view bk
    WHERE bk.BOOKING_ID = p_booking_id;

    -- Добавляем стоимость сервисов
    FOR service_info IN (
      SELECT s.service_type_id, s.service_start_date, s.service_end_date, st.service_type_daily_price
      FROM SERVICES s
      JOIN SERVICE_TYPES st ON s.service_type_id = st.service_type_id
      WHERE s.service_guest_id = v_current_user_id
    ) LOOP
      v_total_cost := v_total_cost + (service_info.service_end_date - service_info.service_start_date) * service_info.service_type_daily_price;
    END LOOP;

  RETURN v_total_cost;
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    RETURN NULL;
     WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Произошла ошибка: ' || SQLERRM);
        RETURN NULL;

END Calculate_Stay_Cost;

PROCEDURE Check_Out(
    p_booking_id NUMBER
)
AS
    p_booking_details booking_details_view%ROWTYPE;
    v_booking_exists NUMBER;
    v_cost FLOAT;
    v_current_user VARCHAR2(30);
    v_current_user_id NUMBER;
BEGIN
    v_current_user := USER;
    SELECT GUEST_ID INTO v_current_user_id from GUESTS
        where lower(USERNAME) = lower(v_current_user);

    -- существование брони
    SELECT COUNT(*) INTO v_booking_exists FROM BOOKING
    WHERE BOOKING_ID = p_booking_id;
    IF v_booking_exists = 0 THEN
        RAISE_APPLICATION_ERROR(-20001, 'Бронь с указанным ID не найдена.');
    END IF;

    SELECT * INTO p_booking_details FROM booking_details_view
    WHERE booking_details_view.BOOKING_ID = p_booking_id;

    IF p_booking_details.BOOKING_GUEST_ID <> v_current_user_id THEN
        RAISE_APPLICATION_ERROR(-20008, 'Вы можете завершить только свою бронь.');
    END IF;
--
    IF p_booking_details.BOOKING_START_DATE > SYSDATE THEN
        RAISE_APPLICATION_ERROR(-20007, 'Вы не можете выселиться так как ваша бронь ещё не началась.');
    END IF;

    IF p_booking_details.BOOKING_STATE_ID = 3 THEN
        RAISE_APPLICATION_ERROR(-20006, 'Бронь с указанным ID уже отменена.');
    END IF;

    --если бронь ещё не закончина то закончим
    IF p_booking_details.BOOKING_END_DATE > SYSDATE THEN
        UPDATE BOOKING SET BOOKING_END_DATE= TO_DATE(SYSDATE, 'YYYY-MM-DD')
        WHERE BOOKING_ID=p_booking_id;
        COMMIT;
    end if;

    v_cost:= CALCULATE_STAY_COST(p_booking_id);
    IF v_cost IS NOT NULL THEN
        DBMS_OUTPUT.PUT_LINE('За проживание в отеле с вас ' || TO_CHAR(v_cost, '9999.99') || 'р.');
    ELSE
        RAISE_APPLICATION_ERROR(-20010,'Не удалось рассчитать стоимость проживания.');
    END IF;
        DBMS_OUTPUT.PUT_LINE('Спасибо, что выбираете нас.');

    DELETE BOOKING WHERE BOOKING_ID=p_booking_id;
    COMMIT;
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Произошла ошибка: ' || SQLERRM);
END Check_Out;

PROCEDURE GET_MY_SERVICES
AS
    v_current_user VARCHAR2(30);
    v_current_user_id NUMBER;
BEGIN
    v_current_user := USER;
    SELECT GUEST_ID INTO v_current_user_id FROM GUESTS
    WHERE lower(USERNAME) = lower(v_current_user);

    DBMS_OUTPUT.PUT_LINE('Список услуг для пользователя с ID ' || v_current_user_id || ':');

    FOR service_rec IN (SELECT *
                        FROM service_view
                        WHERE GUEST_ID = v_current_user_id)
    LOOP
        DBMS_OUTPUT.PUT_LINE('ID услуги: ' || service_rec.SERVICE_ID);
        DBMS_OUTPUT.PUT_LINE('Даты: ' || TO_CHAR(service_rec.SERVICE_START_DATE, 'DD-Mon-YYYY') || ' - ' || TO_CHAR(service_rec.SERVICE_END_DATE, 'DD-Mon-YYYY'));
        DBMS_OUTPUT.PUT_LINE('Тип услуги: ' || service_rec.SERVICE_TYPE_NAME);
        DBMS_OUTPUT.PUT_LINE('Стоимость услуги в день: ' || TO_CHAR(service_rec.SERVICE_TYPE_DAILY_PRICE, '9999.99'));
        DBMS_OUTPUT.PUT_LINE('Номер комнаты: ' || service_rec.ROOM_NUMBER);
        DBMS_OUTPUT.PUT_LINE('----------------------------------------');
    END LOOP;
END GET_MY_SERVICES;

PROCEDURE GET_MY_BOOKINGS
AS
    v_current_user VARCHAR2(30);
    v_current_user_id NUMBER;
BEGIN
    v_current_user := USER;
    SELECT GUEST_ID INTO v_current_user_id
    FROM GUESTS
    WHERE lower(USERNAME) = lower(v_current_user);

    DBMS_OUTPUT.PUT_LINE('Брони гостя с ID ' || v_current_user_id || ':');

    FOR v_booking_details IN (SELECT *
                             FROM booking_details_view
                             WHERE booking_details_view.BOOKING_GUEST_ID = v_current_user_id)
    LOOP
        DBMS_OUTPUT.PUT_LINE('Бронь с ID: ' || v_booking_details.BOOKING_ID);
        DBMS_OUTPUT.PUT_LINE('Даты: с ' || TO_CHAR(v_booking_details.BOOKING_START_DATE, 'DD-Mon-YYYY') || ' по ' || TO_CHAR(v_booking_details.BOOKING_END_DATE, 'DD-Mon-YYYY'));
        DBMS_OUTPUT.PUT_LINE('Статус брони: ' || v_booking_details.BOOKING_STATE);
        DBMS_OUTPUT.PUT_LINE('Номер комнаты: ' || v_booking_details.ROOM_NUMBER);
        DBMS_OUTPUT.PUT_LINE('Тип комнаты: ' || v_booking_details.ROOM_TYPE_NAME);
        DBMS_OUTPUT.PUT_LINE('Стоимость комнаты в день: ' || TO_CHAR(v_booking_details.ROOM_TYPE_DAILY_PRICE, '9999.99'));
        DBMS_OUTPUT.PUT_LINE('Тип тарифа: ' || v_booking_details.TARIFF_TYPE_NAME);
        DBMS_OUTPUT.PUT_LINE('Стоимость тарифа в день: ' || TO_CHAR(v_booking_details.TARIFF_TYPE_DAILY_PRICE, '9999.99'));
        DBMS_OUTPUT.PUT_LINE('-----------------------------');
    END LOOP;

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('Нет броней для гостя с ID ' || v_current_user_id);
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Произошла ошибка: ' || SQLERRM);
END GET_MY_BOOKINGS;














END UserPack;
/
