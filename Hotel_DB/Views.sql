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
CREATE VIEW booking_details_view AS
SELECT
    B.booking_id,
    B.booking_start_date,
    B.booking_end_date,
    B.booking_state,
    G.guest_name,
    G.guest_surname,
    R.room_number,
    RT.room_type_name,
    TT.tariff_type_name
FROM BOOKING B
JOIN GUESTS G ON B.booking_guest_id = G.guest_id
JOIN ROOMS R ON B.booking_room_id = R.room_id
JOIN ROOM_TYPES RT ON R.room_room_type_id = RT.room_type_id
JOIN TARIFF_TYPES TT ON B.booking_tariff_id = TT.tariff_type_id;

select * from booking_details_view;

--свободные комнаты
CREATE VIEW AVAILABLE_ROOMS_VIEW AS
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
           OR (b.booking_start_date > SYSDATE AND b.booking_start_date <= ADD_MONTHS(SYSDATE, 1))
    );

select * from AVAILABLE_ROOMS_VIEW;

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

--не создавать пока нет сервисов
CREATE VIEW TotalRevenue AS
SELECT
    SUM(TT.tariff_type_daily_price * (B.booking_end_date - B.booking_start_date)) AS total_revenue
FROM
    BOOKING B
JOIN
    TARIFF_TYPES TT ON B.booking_tariff_id = TT.tariff_type_id;

-------------------------PERSON_VIEW-------------------------




-------------------------STAFF_VIEW-------------------------



-------------------------GUEST_VIEW-------------------------



-------------------------SERVICE_INFO_VIEW-------------------------

CREATE VIEW service_info_view
AS SELECT ST.service_type_id, ST.service_type_name, ST.service_type_daily_price, st.SERVICE_TYPE_DESCRIPTION --service_type_table fields
FROM SERVICE_TYPES ST
order by ST.service_type_id;

SELECT * FROM service_info_view;

DROP VIEW service_info_view;

-------------------------SERVICE_VIEW-------------------------

CREATE VIEW service_view
AS SELECT
    S.SERVICE_ID, S.SERVICE_START_DATE,s.SERVICE_END_DATE,
    ST.service_type_name, ST.service_type_daily_price, --service_type_table fields
    G.GUEST_NAME, G.GUEST_SURNAME,
    R.ROOM_NUMBER
FROM SERVICE_TYPES ST
INNER JOIN SERVICES S ON ST.service_type_id = S.SERVICE_ID
LEFT OUTER JOIN GUESTS G ON S.service_guest_id = G.guest_id
INNER JOIN BOOKING B ON G.guest_id=B.BOOKING_GUEST_ID
INNER JOIN ROOMS R ON B.BOOKING_ROOM_ID=R.ROOM_ID;

SELECT * FROM service_view;

DROP VIEW service_view;


