CREATE OR REPLACE PACKAGE EmployeePack AS

    PROCEDURE GetBookingDetailsById(p_booking_id NUMBER);

    PROCEDURE GetServiceInfo(p_service_id IN NUMBER);
    PROCEDURE GetServiceInfoForAll;
    PROCEDURE GetAllServiceTypesInfo;

    PROCEDURE BirthdayReportForMonth;
    PROCEDURE WorkAnniversaryReport;



END EmployeePack;
/

CREATE OR REPLACE PACKAGE BODY EmployeePack AS

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
END GetBookingDetailsById;

----------------------------------------------------------------
PROCEDURE GetServiceInfo(p_service_id IN NUMBER)
AS
    v_service_info service_view%ROWTYPE;
    v_service_exists NUMBER;
BEGIN
    -- существование сервиса
    SELECT COUNT(*) INTO v_service_exists FROM SERVICES
    WHERE SERVICE_ID = p_service_id;
    IF v_service_exists = 0 THEN
        RAISE_APPLICATION_ERROR(-20005, 'Сервис с указанным ID не найден.');
    END IF;

    SELECT * INTO v_service_info FROM service_view
    WHERE SERVICE_ID = p_service_id;

    DBMS_OUTPUT.PUT_LINE('Информация о сервисе:');
    DBMS_OUTPUT.PUT_LINE('ID сервиса: ' || v_service_info.SERVICE_ID);
    DBMS_OUTPUT.PUT_LINE('Дата начала: ' || TO_CHAR(v_service_info.SERVICE_START_DATE, 'DD.MM.YYYY'));
    DBMS_OUTPUT.PUT_LINE('Дата окончания: ' || TO_CHAR(v_service_info.SERVICE_END_DATE, 'DD.MM.YYYY'));
    DBMS_OUTPUT.PUT_LINE('Тип сервиса: ' || v_service_info.SERVICE_TYPE_NAME);
    DBMS_OUTPUT.PUT_LINE('Стоимость сервиса в день: ' || v_service_info.SERVICE_TYPE_DAILY_PRICE);
    DBMS_OUTPUT.PUT_LINE('Имя гостя: ' || v_service_info.GUEST_NAME);
    DBMS_OUTPUT.PUT_LINE('Фамилия гостя: ' || v_service_info.GUEST_SURNAME);
    DBMS_OUTPUT.PUT_LINE('Номер комнаты: ' || v_service_info.ROOM_NUMBER);

EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Произошла ошибка: ' || SQLERRM);
END GetServiceInfo;

----------------------------------------------------------------
PROCEDURE GetServiceInfoForAll
AS
    v_service_cursor SYS_REFCURSOR;
    v_service_info service_view%ROWTYPE;
BEGIN
    OPEN v_service_cursor FOR
        SELECT * FROM service_view;

    LOOP
        FETCH v_service_cursor INTO
            v_service_info.SERVICE_ID,
            v_service_info.SERVICE_START_DATE,
            v_service_info.SERVICE_END_DATE,
            v_service_info.SERVICE_TYPE_NAME,
            v_service_info.SERVICE_TYPE_DAILY_PRICE,
            v_service_info.GUEST_NAME,
            v_service_info.GUEST_SURNAME,
            v_service_info.ROOM_NUMBER;

        EXIT WHEN v_service_cursor%NOTFOUND;

        DBMS_OUTPUT.PUT_LINE('Информация о сервисе:');
        DBMS_OUTPUT.PUT_LINE('ID сервиса: ' || v_service_info.SERVICE_ID);
        DBMS_OUTPUT.PUT_LINE('Тип сервиса: ' || v_service_info.SERVICE_TYPE_NAME);
        DBMS_OUTPUT.PUT_LINE('Дата начала: ' || TO_CHAR(v_service_info.SERVICE_START_DATE, 'DD.MM.YYYY'));
        DBMS_OUTPUT.PUT_LINE('Дата окончания: ' || TO_CHAR(v_service_info.SERVICE_END_DATE, 'DD.MM.YYYY'));
        DBMS_OUTPUT.PUT_LINE('Стоимость сервиса в день: ' || v_service_info.SERVICE_TYPE_DAILY_PRICE);
        DBMS_OUTPUT.PUT_LINE('Имя гостя: ' || v_service_info.GUEST_NAME);
        DBMS_OUTPUT.PUT_LINE('Фамилия гостя: ' || v_service_info.GUEST_SURNAME);
        DBMS_OUTPUT.PUT_LINE('Номер комнаты: ' || v_service_info.ROOM_NUMBER);
        DBMS_OUTPUT.PUT_LINE('----------------------');
    END LOOP;

    CLOSE v_service_cursor;

EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Произошла ошибка: ' || SQLERRM);
END GetServiceInfoForAll;

----------------------------------------------------------------
PROCEDURE GetAllServiceTypesInfo
AS
    CURSOR service_cursor IS
        SELECT * FROM SERVICE_TYPE_VIEW;
    v_service_info SERVICE_TYPE_VIEW%ROWTYPE;
BEGIN
    OPEN service_cursor;
    LOOP
        FETCH service_cursor INTO v_service_info;
        EXIT WHEN service_cursor%NOTFOUND;

        DBMS_OUTPUT.PUT_LINE('ID типа сервиса: ' || v_service_info.SERVICE_TYPE_ID);
        DBMS_OUTPUT.PUT_LINE('Тип сервиса: ' || v_service_info.SERVICE_TYPE_NAME);
        DBMS_OUTPUT.PUT_LINE('Описание типа сервиса: ' || v_service_info.SERVICE_TYPE_DESCRIPTION);
        DBMS_OUTPUT.PUT_LINE('Стоимость сервиса в день: ' || v_service_info.SERVICE_TYPE_DAILY_PRICE);
        DBMS_OUTPUT.PUT_LINE('Имя сотрудника: ' || v_service_info.EMPLOYEE_NAME);
        DBMS_OUTPUT.PUT_LINE('Фамилия сотрудника: ' || v_service_info.EMPLOYEE_SURNAME);
        DBMS_OUTPUT.PUT_LINE('--------------------------');
    END LOOP;

    CLOSE service_cursor;
END GetAllServiceTypesInfo;

----------------------------------------------------------------
PROCEDURE BirthdayReportForMonth
AS
BEGIN
    FOR emp IN (
        SELECT
            employee_name || ' ' || employee_surname AS full_name,
            TO_CHAR(employee_birth_date, 'DD Month') AS birth_date,
            EXTRACT(YEAR FROM SYSDATE) - EXTRACT(YEAR FROM employee_birth_date) AS age
        FROM
            EMPLOYEES
        WHERE
            EXTRACT(MONTH FROM employee_birth_date) = EXTRACT(MONTH FROM ADD_MONTHS(SYSDATE, 1))
    )
    LOOP
        DBMS_OUTPUT.PUT_LINE(emp.full_name || ': ' || emp.birth_date || ' (' || emp.age || ' лет)');
    END LOOP;
END BirthdayReportForMonth;


----------------------------------------------------------------
PROCEDURE WorkAnniversaryReport
AS
BEGIN
    FOR emp IN (
        SELECT
            employee_name || ' ' || employee_surname AS full_name,
            employee_position,
            EXTRACT(YEAR FROM SYSDATE) - EXTRACT(YEAR FROM employee_hire_date) AS years_of_service
        FROM
            EMPLOYEES
        WHERE
            MOD(EXTRACT(YEAR FROM SYSDATE) - EXTRACT(YEAR FROM employee_hire_date), 5) = 0
    )
    LOOP
        DBMS_OUTPUT.PUT_LINE(emp.full_name || ' (' || emp.employee_position || ') - ' || emp.years_of_service || ' лет');
    END LOOP;
END WorkAnniversaryReport;

















END EmployeePack;
/