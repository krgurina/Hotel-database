CREATE OR REPLACE PACKAGE EmployeePack AS

    PROCEDURE Get_Booking_Details_By_Id(p_booking_id NUMBER);
    PROCEDURE Get_Service_Info(p_id NUMBER DEFAULT NULL);
    PROCEDURE Birthday_Report;
    PROCEDURE GET_MY_SERVICES;
    PROCEDURE FIND_GUEST(p_guest_id NUMBER);
    PROCEDURE QUIT_JOB;

    -- отменить сервис

    --Просмотр информации о номерах

END EmployeePack;
/

CREATE OR REPLACE PACKAGE BODY EmployeePack AS

PROCEDURE Get_Booking_Details_By_Id(
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
        RAISE_APPLICATION_ERROR(-20005, 'Бронь с указанным ID не найдена.');
    END IF;
    -- Извлекаем информацию о брони с использованием представления
    SELECT * INTO p_booking_details FROM booking_details_view
    WHERE booking_id = p_booking_id;

    DBMS_OUTPUT.PUT_LINE('Информация о брони с ID ' || p_booking_id || ' успешно получена.');
    DBMS_OUTPUT.PUT_LINE('ID брони: ' || p_booking_details.booking_id);
    DBMS_OUTPUT.PUT_LINE('Начальная дата бронирования: ' || p_booking_details.booking_start_date);
    DBMS_OUTPUT.PUT_LINE('Конечная дата бронирования: ' || p_booking_details.booking_end_date);
    DBMS_OUTPUT.PUT_LINE('Статус брони: ' || p_booking_details.booking_state);
    DBMS_OUTPUT.PUT_LINE('Имя гостя: ' || p_booking_details.guest_name);
    DBMS_OUTPUT.PUT_LINE('Фамилия гостя: ' || p_booking_details.guest_surname);
    DBMS_OUTPUT.PUT_LINE('Номер комнаты: ' || p_booking_details.room_number);
    DBMS_OUTPUT.PUT_LINE('Тип комнаты: ' || p_booking_details.room_type_name);
    DBMS_OUTPUT.PUT_LINE('Тип тарифа: ' || p_booking_details.tariff_type_name);
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Произошла ошибка: ' || SQLERRM);
END Get_Booking_Details_By_Id;

----------------------------------------------------------------
-- PROCEDURE GetServiceInfo(p_service_id IN NUMBER)
-- AS
--     v_service_info service_view%ROWTYPE;
--     v_service_exists NUMBER;
-- BEGIN
--     -- существование сервиса
--     SELECT COUNT(*) INTO v_service_exists FROM SERVICES
--     WHERE SERVICE_ID = p_service_id;
--     IF v_service_exists = 0 THEN
--         RAISE_APPLICATION_ERROR(-20005, 'Сервис с указанным ID не найден.');
--     END IF;
--
--     SELECT * INTO v_service_info FROM service_view
--     WHERE SERVICE_ID = p_service_id;
--
--     DBMS_OUTPUT.PUT_LINE('Информация о сервисе:');
--     DBMS_OUTPUT.PUT_LINE('ID сервиса: ' || v_service_info.SERVICE_ID);
--     DBMS_OUTPUT.PUT_LINE('Дата начала: ' || TO_CHAR(v_service_info.SERVICE_START_DATE, 'DD.MM.YYYY'));
--     DBMS_OUTPUT.PUT_LINE('Дата окончания: ' || TO_CHAR(v_service_info.SERVICE_END_DATE, 'DD.MM.YYYY'));
--     DBMS_OUTPUT.PUT_LINE('Тип сервиса: ' || v_service_info.SERVICE_TYPE_NAME);
--     DBMS_OUTPUT.PUT_LINE('Стоимость сервиса в день: ' || v_service_info.SERVICE_TYPE_DAILY_PRICE);
--     DBMS_OUTPUT.PUT_LINE('Имя гостя: ' || v_service_info.GUEST_NAME);
--     DBMS_OUTPUT.PUT_LINE('Фамилия гостя: ' || v_service_info.GUEST_SURNAME);
--     DBMS_OUTPUT.PUT_LINE('Номер комнаты: ' || v_service_info.ROOM_NUMBER);
--
-- EXCEPTION
--     WHEN OTHERS THEN
--         DBMS_OUTPUT.PUT_LINE('Произошла ошибка: ' || SQLERRM);
-- END GetServiceInfo;

----------------------------------------------------------------
-- PROCEDURE GetServiceInfoForAll
-- AS
--     v_service_cursor SYS_REFCURSOR;
--     v_service_info service_view%ROWTYPE;
-- BEGIN
--     OPEN v_service_cursor FOR
--         SELECT * FROM service_view;
--
--     LOOP
--         FETCH v_service_cursor INTO
--             v_service_info.SERVICE_ID,
--             v_service_info.SERVICE_START_DATE,
--             v_service_info.SERVICE_END_DATE,
--             v_service_info.SERVICE_TYPE_NAME,
--             v_service_info.SERVICE_TYPE_DAILY_PRICE,
--             v_service_info.GUEST_NAME,
--             v_service_info.GUEST_SURNAME,
--             v_service_info.ROOM_NUMBER;
--
--         EXIT WHEN v_service_cursor%NOTFOUND;
--
--         DBMS_OUTPUT.PUT_LINE('Информация о сервисе:');
--         DBMS_OUTPUT.PUT_LINE('ID сервиса: ' || v_service_info.SERVICE_ID);
--         DBMS_OUTPUT.PUT_LINE('Тип сервиса: ' || v_service_info.SERVICE_TYPE_NAME);
--         DBMS_OUTPUT.PUT_LINE('Дата начала: ' || TO_CHAR(v_service_info.SERVICE_START_DATE, 'DD.MM.YYYY'));
--         DBMS_OUTPUT.PUT_LINE('Дата окончания: ' || TO_CHAR(v_service_info.SERVICE_END_DATE, 'DD.MM.YYYY'));
--         DBMS_OUTPUT.PUT_LINE('Стоимость сервиса в день: ' || v_service_info.SERVICE_TYPE_DAILY_PRICE);
--         DBMS_OUTPUT.PUT_LINE('Имя гостя: ' || v_service_info.GUEST_NAME);
--         DBMS_OUTPUT.PUT_LINE('Фамилия гостя: ' || v_service_info.GUEST_SURNAME);
--         DBMS_OUTPUT.PUT_LINE('Номер комнаты: ' || v_service_info.ROOM_NUMBER);
--         DBMS_OUTPUT.PUT_LINE('----------------------');
--     END LOOP;
--
--     CLOSE v_service_cursor;
--
-- EXCEPTION
--     WHEN OTHERS THEN
--         DBMS_OUTPUT.PUT_LINE('Произошла ошибка: ' || SQLERRM);
-- END GetServiceInfoForAll;

----------------------------------------------------------------
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

        DBMS_OUTPUT.PUT_LINE('ID типа сервиса: ' || v_info.SERVICE_TYPE_ID);
        DBMS_OUTPUT.PUT_LINE('Тип сервиса: ' || v_info.SERVICE_TYPE_NAME);
        DBMS_OUTPUT.PUT_LINE('Описание типа сервиса: ' || v_info.SERVICE_TYPE_DESCRIPTION);
        DBMS_OUTPUT.PUT_LINE('Стоимость сервиса в день: ' || v_info.SERVICE_TYPE_DAILY_PRICE);
        DBMS_OUTPUT.PUT_LINE('Имя сотрудника: ' || v_info.EMPLOYEE_NAME);
        DBMS_OUTPUT.PUT_LINE('Фамилия сотрудника: ' || v_info.EMPLOYEE_SURNAME);
        DBMS_OUTPUT.PUT_LINE('Должность: ' || v_info.EMPLOYEE_POSITION);
        DBMS_OUTPUT.PUT_LINE('-------------------------------');


    END LOOP;

    CLOSE v_cursor;
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Произошла ошибка: ' || SQLERRM);
END Get_Service_Info;

----------------------------------------------------------------
PROCEDURE Birthday_Report IS
BEGIN
    FOR emp IN (
        SELECT employee_name,
               employee_surname,
               employee_position,
               TO_CHAR(employee_birth_date, 'DD.MM.YYYY') AS birth_date,
               TRUNC(MONTHS_BETWEEN(SYSDATE, employee_birth_date) / 12) AS age
        FROM EMPLOYEES
        ORDER BY TRUNC(MONTHS_BETWEEN(TRUNC(SYSDATE), TRUNC(employee_birth_date) - 1) / 12)
    ) LOOP
        DBMS_OUTPUT.PUT_LINE(emp.employee_name || ' ' || emp.employee_surname);
        DBMS_OUTPUT.PUT_LINE('Должность: ' || emp.employee_position);
        DBMS_OUTPUT.PUT_LINE('День рождения: ' || emp.birth_date || ' (' ||emp.age||' лет)');
            DBMS_OUTPUT.PUT_LINE('----------------------------------------');

    END LOOP;
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Произошла ошибка: ' || SQLERRM);
END Birthday_Report;
----------------------------------------------------------------


PROCEDURE GET_MY_SERVICES
AS
    v_current_user VARCHAR2(50);
    v_current_user_id NUMBER;
    v_service_count NUMBER;
BEGIN
    v_current_user := USER;
    SELECT EMPLOYEE_ID INTO v_current_user_id FROM EMPLOYEES
    WHERE lower(USERNAME) = lower(v_current_user);

    SELECT COUNT(*) INTO v_service_count
    FROM SERVICE_EMPLOYEE_VIEW S
    WHERE S.EMPLOYEE_ID = v_current_user_id;

    IF v_service_count = 0 THEN
        DBMS_OUTPUT.PUT_LINE('У вас нет заказанных услуг, которые необходимо выполнить.');
    ELSE
        DBMS_OUTPUT.PUT_LINE('Список услуг сотрудника с ID ' || v_current_user_id || ':');
        DBMS_OUTPUT.PUT_LINE('----------------------------------------');

        FOR service_rec IN (SELECT *
                            FROM SERVICE_EMPLOYEE_VIEW S
                            WHERE s.EMPLOYEE_ID = v_current_user_id)
        LOOP
            DBMS_OUTPUT.PUT_LINE('ID услуги: ' || service_rec.SERVICE_ID);
            DBMS_OUTPUT.PUT_LINE('Даты: ' || TO_CHAR(service_rec.SERVICE_START_DATE, 'DD-Mon-YYYY') || ' - ' || TO_CHAR(service_rec.SERVICE_END_DATE, 'DD-Mon-YYYY'));
            DBMS_OUTPUT.PUT_LINE('Тип услуги: ' || service_rec.SERVICE_TYPE_NAME);
            DBMS_OUTPUT.PUT_LINE('ID гостя заказавшего услугу: ' || service_rec.GUEST_ID);
            DBMS_OUTPUT.PUT_LINE('Имя гостя: ' || service_rec.GUEST_SURNAME || ' '|| service_rec.GUEST_NAME);
            DBMS_OUTPUT.PUT_LINE('----------------------------------------');
        END LOOP;
    END IF;
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Произошла ошибка: ' || SQLERRM);
END GET_MY_SERVICES;


PROCEDURE FIND_GUEST(p_guest_id NUMBER) AS
 v_guest_name NVARCHAR2(100);
BEGIN
    SELECT guest_name || ' ' || guest_surname INTO v_guest_name
    FROM GUESTS
    WHERE guest_id = p_guest_id;

    DBMS_OUTPUT.PUT_LINE('Гость: ' || v_guest_name);
    DBMS_OUTPUT.PUT_LINE('----------------------------------------');

    FOR booking_rec IN (
        SELECT *
        FROM BOOKING_DETAILS_VIEW
        WHERE booking_guest_id = p_guest_id
    ) LOOP
        DBMS_OUTPUT.PUT_LINE('ID брони : ' || booking_rec.booking_id);
        DBMS_OUTPUT.PUT_LINE('Номер комнаты: ' || booking_rec.room_number);
        DBMS_OUTPUT.PUT_LINE('Даты проживания: ' || TO_CHAR(booking_rec.booking_start_date, 'DD.MM.YYYY') || ' - ' || TO_CHAR(booking_rec.booking_end_date, 'DD.MM.YYYY'));
            DBMS_OUTPUT.PUT_LINE('----------------------------------------');
    END LOOP;

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('Гость с указанным ID не найден.');
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Произошла ошибка: ' || SQLERRM);
END FIND_GUEST;


PROCEDURE QUIT_JOB AS
    v_employee_count NUMBER;
    v_username NVARCHAR2(50);
    v_current_user_id NUMBER;
    v_current_user VARCHAR2(50);
    v_service_count NUMBER;
BEGIN
    v_current_user := USER;

    SELECT EMPLOYEE_ID INTO v_current_user_id
    FROM EMPLOYEES
    WHERE lower(USERNAME) = lower(v_current_user);

    SELECT COUNT(*) INTO v_employee_count
    FROM EMPLOYEES
    WHERE employee_id = v_current_user_id;

    IF v_employee_count = 0 THEN
        RAISE_APPLICATION_ERROR(-20001, 'Работник с указанным ID не найден.');
    END IF;

    -- Проверяем, есть ли закрепленные сервисы за сотрудником
    SELECT COUNT(*) INTO v_service_count
    FROM SERVICES
    WHERE service_type_id IN (
        SELECT service_type_id
        FROM SERVICE_TYPES
        WHERE service_type_employee_id = v_current_user_id
    );

    IF v_service_count > 0 THEN

        FOR service_rec IN (
            SELECT service_id
            FROM SERVICES
            WHERE service_type_id IN (
                SELECT service_type_id
                FROM SERVICE_TYPES
                WHERE service_type_employee_id = v_current_user_id
            )
        ) LOOP
            DBMS_OUTPUT.PUT_LINE('ID сервиса: ' || service_rec.service_id );
        END LOOP;
        RAISE_APPLICATION_ERROR(-20026, 'На данный момент вы не можете уволиться, так как за вами закреплены активные сервисы. Обратитесь к администратору для внесения изменений.');

    ELSE
        SELECT username INTO v_username
        FROM EMPLOYEES
        WHERE employee_id = v_current_user_id;

        DELETE FROM EMPLOYEES WHERE employee_id = v_current_user_id;
        COMMIT;

        EXECUTE IMMEDIATE 'DROP USER ' || v_username || ' CASCADE';

        DBMS_OUTPUT.PUT_LINE('Работник успешно удален.');
    END IF;

EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Произошла ошибка: ' || SQLERRM);
        ROLLBACK;
END QUIT_JOB;






END EmployeePack;
/