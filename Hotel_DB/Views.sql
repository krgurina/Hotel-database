-- информация о комнате
CREATE VIEW room_info_view AS
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
--
CREATE or replace VIEW booking_details_view AS
SELECT
    B.booking_id,
    B.booking_start_date,
    B.booking_end_date,
    B.booking_state AS booking_state_id,
    BS.BOOKING_STATE,
    B.booking_guest_id,
    G.guest_name,
    G.guest_surname,
    R.room_number,
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

select * from booking_details_view;

--свободные комнаты
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
--           OR (b.booking_start_date > SYSDATE AND b.booking_start_date <= ADD_MONTHS(SYSDATE, 1))
    );

select * from AVAILABLE_ROOMS_VIEW;

-- ЗАНЯТЫЕ КОМНАТЫ
CREATE OR REPLACE VIEW BOOKED_ROOMS_VIEW AS
SELECT
    B.BOOKING_START_DATE,
    B.BOOKING_END_DATE,
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

-- занятые сейчас комнаты
CREATE VIEW OCCUPIED_ROOMS_VIEW AS
SELECT
    b.booking_id,
    r.room_id,
    r.room_number,
    rt.room_type_name,
    b.booking_start_date,
    b.booking_end_date
FROM
    BOOKING b
    JOIN ROOMS r ON b.booking_room_id = r.room_id
    JOIN ROOM_TYPES rt ON r.room_room_type_id = rt.room_type_id
WHERE
    (b.booking_start_date <= SYSDATE AND b.booking_end_date >= SYSDATE)
    OR (b.booking_start_date > SYSDATE AND b.booking_start_date <= ADD_MONTHS(SYSDATE, 1));

select * from OCCUPIED_ROOMS_VIEW;

----------------------------------------------------------------
-- вывод фото для типа команты
----------------------------------------------------------------
CREATE OR REPLACE VIEW GET_ROOM_PHOTO AS
       SELECT P.PHOTO_ROOM_TYPE_ID, RT.ROOM_TYPE_NAME, P.PHOTO_SOURCE
       FROM PHOTO P
       JOIN ROOM_TYPES RT ON P.PHOTO_ROOM_TYPE_ID=RT.ROOM_TYPE_ID;

SELECT * FROM GET_ROOM_PHOTO;

-------------------------SERVICE_INFO_VIEW-------------------------

CREATE or replace VIEW SERVICE_TYPE_VIEW AS
SELECT
    S.service_id,
    ST.service_type_id,
    ST.service_type_name,
    ST.service_type_description,
    ST.service_type_daily_price,
    E.employee_name,
    E.employee_surname
FROM
    SERVICES S
    JOIN SERVICE_TYPES ST ON S.service_type_id = ST.service_type_id
    JOIN EMPLOYEES E ON ST.service_type_employee_id = E.employee_id;


SELECT * FROM SERVICE_TYPE_VIEW;

DROP VIEW SERVICE_TYPE_VIEW;

-------------------------SERVICE_VIEW-------------------------
--именно заказанные сервисы
CREATE or replace VIEW service_view
AS SELECT
    S.SERVICE_ID, S.SERVICE_START_DATE,s.SERVICE_END_DATE,
    ST.service_type_name, ST.service_type_daily_price, --service_type_table fields
    G.GUEST_NAME, G.GUEST_SURNAME, G.username, G.GUEST_ID,
    R.ROOM_NUMBER
FROM SERVICE_TYPES ST
INNER JOIN SERVICES S ON ST.service_type_id = S.SERVICE_ID
LEFT OUTER JOIN GUESTS G ON S.service_guest_id = G.guest_id
INNER JOIN BOOKING B ON G.guest_id=B.BOOKING_GUEST_ID
INNER JOIN ROOMS R ON B.BOOKING_ROOM_ID=R.ROOM_ID;

SELECT * FROM service_view;

DROP VIEW service_view;


