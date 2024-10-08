----------------------------------------------------------------
-- информация о комнате
----------------------------------------------------------------
CREATE or replace VIEW room_info_view AS
SELECT
    R.room_id,
    R.room_number,
    RT.room_type_name,
    RT.room_type_capacity,
    RT.room_type_daily_price,
    RT.room_type_description,
    P.photo_source
FROM ROOMS R
JOIN ROOM_TYPES RT ON R.room_room_type_id = RT.room_type_id
LEFT JOIN PHOTO P ON R.room_room_type_id = P.photo_room_type_id;

select * from room_info_view;
----------------------------------------------------------------
-- информация о брони
----------------------------------------------------------------
CREATE or replace VIEW BOOKING_DETAILS_VIEW AS
SELECT
    B.booking_id,
    B.booking_start_date,
    B.booking_end_date,
    B.booking_state AS booking_state_id,
    BS.BOOKING_STATE,
    B.booking_guest_id,
    B.booking_room_id,
    G.guest_name,
    G.guest_surname,
    R.room_number,
    RT.room_type_id,
    RT.room_type_name,
    RT.ROOM_TYPE_DAILY_PRICE,
    TT.tariff_type_name,
    TT.TARIFF_TYPE_DAILY_PRICE
FROM BOOKING_STATE BS
JOIN BOOKING B ON BS.BOOKING_STATE_ID = B.BOOKING_STATE
JOIN GUESTS G ON B.booking_guest_id = G.guest_id
JOIN ROOMS R ON B.booking_room_id = R.room_id
JOIN ROOM_TYPES RT ON R.room_room_type_id = RT.room_type_id
JOIN TARIFF_TYPES TT ON B.booking_tariff_id = TT.tariff_type_id;

select * from BOOKING_DETAILS_VIEW;

----------------------------------------------------------------
--свободные комнаты
----------------------------------------------------------------
CREATE OR REPLACE VIEW AVAILABLE_ROOMS_VIEW AS
SELECT
    r.room_id,
    r.room_number,
    rt.room_type_name,
    rt.room_type_capacity,
    rt.room_type_daily_price,
    rt.room_type_description
FROM
    ROOMS r
    JOIN ROOM_TYPES rt ON r.room_room_type_id = rt.room_type_id
WHERE
    r.room_id NOT IN (
        SELECT b.booking_room_id
        FROM BOOKING b
        WHERE (b.booking_start_date <= SYSDATE AND b.booking_end_date >= SYSDATE)
    );

select * from AVAILABLE_ROOMS_VIEW;

----------------------------------------------------------------
-- ЗАНЯТЫЕ КОМНАТЫ
----------------------------------------------------------------
CREATE OR REPLACE VIEW BOOKED_ROOMS_VIEW AS
SELECT
    B.BOOKING_START_DATE,
    B.BOOKING_END_DATE,
    B.booking_room_id,
    r.room_id,
    r.room_number,
    rt.room_type_name,
    rt.room_type_capacity,
    rt.room_type_daily_price,
    rt.room_type_description
FROM
    BOOKING B
    JOIN ROOMS r ON B.BOOKING_ROOM_ID = r.ROOM_ID
    JOIN ROOM_TYPES rt ON r.room_room_type_id = rt.room_type_id;

----------------------------------------------------------------
-- вывод фото для типа команты
----------------------------------------------------------------
CREATE OR REPLACE VIEW GET_ROOM_PHOTO AS
       SELECT P.PHOTO_ID, P.PHOTO_ROOM_TYPE_ID, RT.ROOM_TYPE_NAME, P.PHOTO_SOURCE
       FROM PHOTO P
       JOIN ROOM_TYPES RT ON P.PHOTO_ROOM_TYPE_ID=RT.ROOM_TYPE_ID;

SELECT * FROM GET_ROOM_PHOTO;

-------------------------SERVICE_INFO_VIEW-------------------------

-- CREATE or replace VIEW SERVICE_TYPE_VIEW AS
-- SELECT
--     ST.service_type_id,
--     ST.service_type_name,
--     ST.service_type_description,
--     ST.service_type_daily_price,
--     E.employee_name,
--     E.employee_surname
-- FROM
--     SERVICES S
--     JOIN SERVICE_TYPES ST ON S.service_type_id = ST.service_type_id
--     JOIN EMPLOYEES E ON ST.service_type_employee_id = E.employee_id;
----------------------------------------------------------------
-- Информация о сервисах
----------------------------------------------------------------
CREATE or replace VIEW SERVICE_TYPE_VIEW AS
SELECT
    ST.service_type_id,
    ST.service_type_name,
    ST.service_type_description,
    ST.service_type_daily_price,
    E.employee_name,
    E.employee_surname,
    E.EMPLOYEE_POSITION
FROM
    SERVICE_TYPES ST
    JOIN EMPLOYEES E ON ST.service_type_employee_id = E.employee_id;


SELECT * FROM SERVICE_TYPE_VIEW;

DROP VIEW SERVICE_TYPE_VIEW;

----------------------------------------------------------------
-- заказанные сервисы
----------------------------------------------------------------
CREATE or replace VIEW SERVICE_VIEW
AS SELECT
    S.SERVICE_ID, S.SERVICE_START_DATE,s.SERVICE_END_DATE, S.SERVICE_GUEST_ID,
    ST.service_type_name, ST.service_type_daily_price,
    G.GUEST_NAME, G.GUEST_SURNAME, G.username, G.GUEST_ID,
    R.ROOM_NUMBER
FROM SERVICE_TYPES ST
JOIN SERVICES S ON ST.service_type_id = S.SERVICE_TYPE_ID
JOIN GUESTS G ON S.service_guest_id = G.guest_id
JOIN BOOKING B ON G.guest_id=B.BOOKING_GUEST_ID
JOIN ROOMS R ON B.BOOKING_ROOM_ID=R.ROOM_ID;

SELECT * FROM SERVICE_VIEW;

DROP VIEW SERVICE_VIEW;

CREATE or replace VIEW SERVICE_EMPLOYEE_VIEW
AS SELECT
    S.SERVICE_ID,
    S.SERVICE_START_DATE,
    S.SERVICE_END_DATE,
    G.GUEST_ID,
    G.GUEST_NAME,
    G.GUEST_SURNAME,
    ST.SERVICE_TYPE_NAME,
    ST.SERVICE_TYPE_DAILY_PRICE,
    E.EMPLOYEE_ID
FROM SERVICES S
JOIN SERVICE_TYPES ST ON S.SERVICE_TYPE_ID = ST.SERVICE_TYPE_ID
JOIN GUESTS G ON S.SERVICE_GUEST_ID = G.GUEST_ID
LEFT JOIN EMPLOYEES E ON ST.SERVICE_TYPE_EMPLOYEE_ID = E.EMPLOYEE_ID;

SELECT * FROM SERVICE_EMPLOYEE_VIEW;
