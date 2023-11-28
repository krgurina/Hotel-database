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

--НЕПОНЯТНО не работает
CREATE VIEW available_room_types_view AS
SELECT
    RT.room_type_id,
    RT.room_type_name,
    RT.room_type_capacity,
    COUNT(B.booking_id) AS booked_rooms
FROM ROOM_TYPES RT
LEFT JOIN ROOMS R ON RT.room_type_id = R.room_room_type_id
LEFT JOIN BOOKING B ON R.room_id = B.booking_room_id AND
    NOT (B.booking_end_date <= :start_date OR B.booking_start_date >= :end_date)
GROUP BY RT.room_type_id, RT.room_type_name, RT.room_type_capacity;


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


