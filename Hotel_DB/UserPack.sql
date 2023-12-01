CREATE OR REPLACE PACKAGE UserPack AS
    -- 1.
    PROCEDURE BOOKINGNOW(
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

END UserPack;
/

CREATE OR REPLACE PACKAGE BODY UserPack AS

PROCEDURE BOOKINGNOW(
    p_room_id IN NUMBER,
    p_guest_id IN NUMBER,
    p_end_date IN DATE,
    p_tariff_id IN NUMBER,
    p_booking_id OUT NUMBER)
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

    IF p_end_date <= SYSDATE THEN
      RAISE_APPLICATION_ERROR(-20001, 'Дата окончания проживания должна быть позже текущей даты.');
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

        -- Используем RETURNING INTO для получения ID созданной брони
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
        ) RETURNING booking_id INTO p_booking_id;
        commit;
        DBMS_OUTPUT.PUT_LINE('Бронирование успешно добавлено.');
    END IF;
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Произошла ошибка: ' || SQLERRM);
END BOOKINGNOW;

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

    -- Используем RETURNING INTO для получения ID созданной брони
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

END UserPack;
/
