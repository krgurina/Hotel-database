
CREATE TABLESPACE HOTEL_TS
DATAFILE 'hotel_ts.dbf' SIZE 200M
AUTOEXTEND ON NEXT 20M MAXSIZE UNLIMITED
EXTENT MANAGEMENT LOCAL UNIFORM SIZE 2M;


CREATE TEMPORARY TABLESPACE HOTEL_TEMP_TS
TEMPFILE 'hotel_temp_ts.dbf' SIZE 100M
AUTOEXTEND ON NEXT 10M MAXSIZE UNLIMITED
EXTENT MANAGEMENT LOCAL UNIFORM SIZE 1M;


-------------------------ROOM_TYPE-------------------------

CREATE TABLE ROOM_TYPES (
    room_type_id NUMBER(10) GENERATED AS IDENTITY(START WITH 1 INCREMENT BY 1),
    room_type_name NVARCHAR2(50) NOT NULL,
    room_type_capacity NUMBER(10) NOT NULL,
    room_type_daily_price FLOAT(10) NOT NULL,
    room_type_description NVARCHAR2(200) NOT NULL,
    CONSTRAINT room_type_pk PRIMARY KEY (room_type_id)
) tablespace HOTEL_TS;

INSERT INTO ROOM_TYPES(room_type_name, room_type_capacity, room_type_description, room_type_daily_price) VALUES('Standard-one', 1, '37-38 м2, однокомнатные номера, телевизор, кондиционер, Wi-Fi, фен, кровать «King size», письменные принадлежности, чайный набор' , 40.00);
INSERT INTO ROOM_TYPES(room_type_name, room_type_capacity, room_type_description, room_type_daily_price) VALUES('Standard-two', 2, '39-40 м2, однокомнатные номера, телевизор, кондиционер, Wi-Fi, фен, 2 кровати «King size», письменные принадлежности, чайный набор', 50.00);
INSERT INTO ROOM_TYPES(room_type_name, room_type_capacity, room_type_description, room_type_daily_price) VALUES('Standard-three', 3, '42-43 м2, однокомнатные номера, телевизор, кондиционер, Wi-Fi, фен, 3 кровати «King size», письменные принадлежности, чайный набор', 60.00);
INSERT INTO ROOM_TYPES(room_type_name, room_type_capacity, room_type_description, room_type_daily_price) VALUES('Family-two', 2, '51 м2, однокомнатные номера, в номере имеются детские принадлежности, игры, детские полотенца и постельное белье', 45.00);
INSERT INTO ROOM_TYPES(room_type_name, room_type_capacity, room_type_description, room_type_daily_price) VALUES('Family-tree', 3, '60 м2, однокомнатные номера, расположены на 4 и 5 этажах, в номере имеются детские принадлежности, игры, детские полотенца и постельное белье', 55.00);
INSERT INTO ROOM_TYPES(room_type_name, room_type_capacity, room_type_description, room_type_daily_price) VALUES('Family-four', 4, '65 м2, однокомнатные номера, в номере имеются детские принадлежности, игры, детские полотенца и постельное белье', 65.00);
INSERT INTO ROOM_TYPES(room_type_name, room_type_capacity, room_type_description, room_type_daily_price) VALUES('Deluxe-one', 1, '51 м2, однокомнатные номера,  расположены на 3-7 этажах', 70.00);
INSERT INTO ROOM_TYPES(room_type_name, room_type_capacity, room_type_description, room_type_daily_price) VALUES('Deluxe-two', 2, '51 м2, однокомнатные номера,  расположены на 3-7 этажах', 85.00);
INSERT INTO ROOM_TYPES(room_type_name, room_type_capacity, room_type_description, room_type_daily_price) VALUES('Lux-one', 1, '76-80 м2, двухкомнатные номера (спальня + гостиная), в номере есть гостевой туалет. Расположены на 3-6 этажах', 100.00);
INSERT INTO ROOM_TYPES(room_type_name, room_type_capacity, room_type_description, room_type_daily_price) VALUES('Lux-two', 2, '76-80 м2, двухкомнатные номера (спальня + гостиная), в номере есть гостевой туалет. Расположены на 3-6 этажах', 130.00);
INSERT INTO ROOM_TYPES(room_type_name, room_type_capacity, room_type_description, room_type_daily_price) VALUES('Lux-three', 3, '80-85 м2, двухкомнатные номера (спальня + гостиная). Расположены на 3-6 этажах', 145.00);
INSERT INTO ROOM_TYPES(room_type_name, room_type_capacity, room_type_description, room_type_daily_price) VALUES('President lux', 4, '308 м2, восьмикомнатный номер (2 спальни с 2мя отдельными ванными комнатами), гостевые санузлы.', 250.00);
INSERT INTO ROOM_TYPES(room_type_name, room_type_capacity, room_type_description, room_type_daily_price) VALUES('President lux+', 5, '350 м2, восьмикомнатный номер (2 спальни с 2мя отдельными ванными комнатами), гостевые санузлы.', 330.00);
COMMIT;

SELECT * FROM ROOM_TYPES;

DROP TABLE ROOM_TYPES;


-------------------------PHOTO-------------------------

CREATE TABLE PHOTO (
    photo_id NUMBER(10) GENERATED AS IDENTITY(START WITH 1 INCREMENT BY 1),
    photo_room_type_id NUMBER(10) NOT NULL,
    photo_source BLOB DEFAULT EMPTY_BLOB(),
    CONSTRAINT photo_pk PRIMARY KEY (photo_id),
    CONSTRAINT photo_room_type_fk FOREIGN KEY (photo_room_type_id) REFERENCES ROOM_TYPES(room_type_id) ON DELETE CASCADE
) tablespace HOTEL_TS;

SELECT * FROM PHOTO;

DROP TABLE PHOTO;

-------------------------GUESTS-------------------------

CREATE TABLE GUESTS (
    guest_id NUMBER(10) GENERATED AS IDENTITY(START WITH 1 INCREMENT BY 1),
    guest_email NVARCHAR2(50) NOT NULL,
    guest_name NVARCHAR2(50) NOT NULL,
    guest_surname NVARCHAR2(50) NOT NULL,
    username NVARCHAR2(50) NOT NULL UNIQUE,
    CONSTRAINT guest_pk PRIMARY KEY (guest_id)
) tablespace HOTEL_TS;



-------------------------EMPLOYEES-------------------------

CREATE TABLE EMPLOYEES (
    employee_id NUMBER(10) GENERATED AS IDENTITY(START WITH 1 INCREMENT BY 1),
    employee_name NVARCHAR2(50) NOT NULL,
    employee_surname NVARCHAR2(50) NOT NULL,
    employee_position NVARCHAR2(50) NOT NULL,
    employee_email NVARCHAR2(50) NOT NULL,
    employee_hire_date DATE NOT NULL,
    employee_birth_date DATE NOT NULL,
    username NVARCHAR2(50) NOT NULL UNIQUE,
    CONSTRAINT employee_pk PRIMARY KEY (employee_id)
) tablespace HOTEL_TS;

-------------------------ROOMS-------------------------

CREATE TABLE ROOMS (
    room_id NUMBER(10) GENERATED AS IDENTITY(START WITH 1 INCREMENT BY 1),
    room_room_type_id NUMBER(10) NOT NULL,
    room_number NVARCHAR2(50) NOT NULL,
    CONSTRAINT room_pk PRIMARY KEY (room_id),
    CONSTRAINT room_room_type_fk FOREIGN KEY (room_room_type_id) REFERENCES ROOM_TYPES(room_type_id) ON DELETE CASCADE
) tablespace HOTEL_TS;

INSERT INTO ROOMS (room_room_type_id, room_number) VALUES (1, '201');
INSERT INTO ROOMS (room_room_type_id, room_number) VALUES (1, '202');
INSERT INTO ROOMS (room_room_type_id, room_number) VALUES (1, '203');
INSERT INTO ROOMS (room_room_type_id, room_number) VALUES (1, '204');
INSERT INTO ROOMS (room_room_type_id, room_number) VALUES (2, '205');
INSERT INTO ROOMS (room_room_type_id, room_number) VALUES (2, '206');
INSERT INTO ROOMS (room_room_type_id, room_number) VALUES (2, '207');
INSERT INTO ROOMS (room_room_type_id, room_number) VALUES (2, '301');
INSERT INTO ROOMS (room_room_type_id, room_number) VALUES (2, '302');
INSERT INTO ROOMS (room_room_type_id, room_number) VALUES (3, '303');
INSERT INTO ROOMS (room_room_type_id, room_number) VALUES (3, '304');
INSERT INTO ROOMS (room_room_type_id, room_number) VALUES (3, '305');
INSERT INTO ROOMS (room_room_type_id, room_number) VALUES (3, '306');
INSERT INTO ROOMS (room_room_type_id, room_number) VALUES (4, '307');
INSERT INTO ROOMS (room_room_type_id, room_number) VALUES (4, '308');
INSERT INTO ROOMS (room_room_type_id, room_number) VALUES (4, '309');
INSERT INTO ROOMS (room_room_type_id, room_number) VALUES (4, '310');
INSERT INTO ROOMS (room_room_type_id, room_number) VALUES (5, '311');
INSERT INTO ROOMS (room_room_type_id, room_number) VALUES (5, '312');
INSERT INTO ROOMS (room_room_type_id, room_number) VALUES (5, '313');
INSERT INTO ROOMS (room_room_type_id, room_number) VALUES (6, '401');
INSERT INTO ROOMS (room_room_type_id, room_number) VALUES (6, '402');
INSERT INTO ROOMS (room_room_type_id, room_number) VALUES (6, '403');
INSERT INTO ROOMS (room_room_type_id, room_number) VALUES (7, '404');
INSERT INTO ROOMS (room_room_type_id, room_number) VALUES (7, '405');
INSERT INTO ROOMS (room_room_type_id, room_number) VALUES (8, '406');
INSERT INTO ROOMS (room_room_type_id, room_number) VALUES (8, '501');
INSERT INTO ROOMS (room_room_type_id, room_number) VALUES (8, '502');
INSERT INTO ROOMS (room_room_type_id, room_number) VALUES (9, '503');
INSERT INTO ROOMS (room_room_type_id, room_number) VALUES (9, '601');
INSERT INTO ROOMS (room_room_type_id, room_number) VALUES (10, '602');
INSERT INTO ROOMS (room_room_type_id, room_number) VALUES (10, '603');
INSERT INTO ROOMS (room_room_type_id, room_number) VALUES (11, '604');
INSERT INTO ROOMS (room_room_type_id, room_number) VALUES (11, '701');
INSERT INTO ROOMS (room_room_type_id, room_number) VALUES (12, '702');
INSERT INTO ROOMS (room_room_type_id, room_number) VALUES (13, '801');
INSERT INTO ROOMS (room_room_type_id, room_number) VALUES (13, '901');
commit;

-------------------------TARIFF_TYPES-------------------------

CREATE TABLE TARIFF_TYPES (
    tariff_type_id NUMBER(10) GENERATED AS IDENTITY(START WITH 1 INCREMENT BY 1),
    tariff_type_name NVARCHAR2(50) NOT NULL,
    tariff_type_description NVARCHAR2(200) NOT NULL,
    tariff_type_daily_price FLOAT(10) NOT NULL,
    CONSTRAINT tariff_type_pk PRIMARY KEY (tariff_type_id)
) tablespace HOTEL_TS;

SELECT * FROM TARIFF_TYPES;

INSERT INTO TARIFF_TYPES (tariff_type_name, tariff_type_description, tariff_type_daily_price) VALUES('Стандарт','без завтрака', 0.0);
INSERT INTO TARIFF_TYPES (tariff_type_name, tariff_type_description, tariff_type_daily_price) VALUES('Стандарт+','завтрак включен',  15.0);
INSERT INTO TARIFF_TYPES (tariff_type_name, tariff_type_description, tariff_type_daily_price) VALUES('Бизнес','завтрак включен,  доступ в бизнес-центр, возможность позднего выезда',  20.0);
INSERT INTO TARIFF_TYPES (tariff_type_name, tariff_type_description, tariff_type_daily_price) VALUES('Полу-пансион','2 приёма пищи, доступ к фитнес-залу',  35.50);
INSERT INTO TARIFF_TYPES (tariff_type_name, tariff_type_description, tariff_type_daily_price) VALUES('Пансион','3 приёма пищи, доступ к фитнес-залу',  45.0);
INSERT INTO TARIFF_TYPES (tariff_type_name, tariff_type_description, tariff_type_daily_price) VALUES('Всё включено','неограниченное посещение ресторана, доступ к фитнес-залу, спа-услуги, выезд в любое время',  95.0);
COMMIT;

DROP TABLE TARIFF_TYPES ;

-------------------------SERVICE_TYPE-------------------------

CREATE TABLE SERVICE_TYPES (
    service_type_id NUMBER(10) GENERATED AS IDENTITY(START WITH 1 INCREMENT BY 1),
    service_type_name NVARCHAR2(50) NOT NULL,
    service_type_description NVARCHAR2(200) NOT NULL,
    service_type_daily_price FLOAT(10) NOT NULL,
    service_type_employee_id NUMBER(10) NOT NULL,
    CONSTRAINT service_type_pk PRIMARY KEY (service_type_id),
    CONSTRAINT service_type_employee_fk FOREIGN KEY (service_type_employee_id) REFERENCES EMPLOYEES(employee_id)  ON DELETE CASCADE
) tablespace HOTEL_TS;

SELECT * FROM SERVICE_TYPES ;
-- добавить работников
INSERT INTO SERVICE_TYPES (service_type_name, service_type_description, service_type_daily_price, service_type_employee_id) VALUES('Спа-услуги', 'Спа-центры предоставляют различные процедуры, массажи, сауны, джакузи, а также услуги парикмахера и маникюра', 50.0, 5);
INSERT INTO SERVICE_TYPES (service_type_name, service_type_description, service_type_daily_price, service_type_employee_id) VALUES('Трансфер', 'Услуги трансфера из/в аэропорт или другие места', 40.50, 3);
INSERT INTO SERVICE_TYPES (service_type_name, service_type_description, service_type_daily_price, service_type_employee_id) VALUES('Экскурсии', 'Организация поездок и экскурсий по местным достопримечательностям', 10.0, 7);
INSERT INTO SERVICE_TYPES (service_type_name, service_type_description, service_type_daily_price, service_type_employee_id) VALUES('Комната ожидания родителей', 'В комнате есть множество игрушек, с которыми Ваш ребенок может поиграть, специальный столик для рисования, горка и многое другое', 15.50, 1);
INSERT INTO SERVICE_TYPES (service_type_name, service_type_description, service_type_daily_price, service_type_employee_id) VALUES('Фитнес-центр', 'Оборудованный тренажерный зал с современными тренажерами и инструкторами', 20.0, 6);
INSERT INTO SERVICE_TYPES (service_type_name, service_type_description, service_type_daily_price, service_type_employee_id) VALUES('Бассейн','Крытый и открытый бассейн для отдыха и релаксации', 7.50, 5);
INSERT INTO SERVICE_TYPES (service_type_name, service_type_description, service_type_daily_price, service_type_employee_id) VALUES('Прачечная и Химчистка', 'Услуги стирки, глажения и химчистки одежды', 15.0, 8);
INSERT INTO SERVICE_TYPES (service_type_name, service_type_description, service_type_daily_price, service_type_employee_id) VALUES('Сейф', 'В лобби предоставляется услуга пользования сейфом, где Вы можете оставить ценные вещи', 18.0, 9);
INSERT INTO SERVICE_TYPES (service_type_name, service_type_description, service_type_daily_price, service_type_employee_id) VALUES('Услуга «звонок-будильник»', 'Для связи с сервисным центром наберите "0" и сообщите время, когда Вас необходимо разбудить', 5.0, 2);
INSERT INTO SERVICE_TYPES (service_type_name, service_type_description, service_type_daily_price, service_type_employee_id) VALUES('Аренда офисов', 'Гостиница предлагает площади для аренды под офисы', 15.0, 2);
INSERT INTO SERVICE_TYPES (service_type_name, service_type_description, service_type_daily_price, service_type_employee_id) VALUES('Доставка еды в номер ', 'Для гостей предоставляется круглосуточная услуга доставки еды в номер', 15.0, 4);
COMMIT;

DROP TABLE SERVICE_TYPES ;

-------------------------SERVICE-------------------------

CREATE TABLE SERVICES (
    service_id NUMBER(10) GENERATED AS IDENTITY(START WITH 1 INCREMENT BY 1),
    service_type_id NUMBER(10) NOT NULL,
    service_guest_id NUMBER(10) NOT NULL,
    service_start_date DATE NOT NULL,
    service_end_date DATE NOT NULL,
    CONSTRAINT service_pk PRIMARY KEY (service_id),
    CONSTRAINT service_service_type_fk FOREIGN KEY (service_type_id) REFERENCES SERVICE_TYPES(service_type_id) ON DELETE CASCADE,
    CONSTRAINT service_guest_fk FOREIGN KEY (service_guest_id) REFERENCES GUESTS(guest_id) ON DELETE CASCADE
) tablespace HOTEL_TS;

SELECT * FROM SERVICES;

DROP TABLE SERVICES;

-------------------------BOOKING_STATE-------------------------
CREATE TABLE BOOKING_STATE (
    booking_state_id NUMBER(2) GENERATED AS IDENTITY(START WITH 1 INCREMENT BY 1),
    booking_state NVARCHAR2(100) NOT NULL,
    CONSTRAINT booking_state_pk PRIMARY KEY (booking_state_id)
) tablespace HOTEL_TS;

insert into BOOKING_STATE (booking_state)  values ('Забронировано гостем');
insert into BOOKING_STATE (booking_state)  values ('Одобрено администратором');
insert into BOOKING_STATE (booking_state)  values ('Отменено гостем');
insert into BOOKING_STATE (booking_state)  values ('Отменено администратором');
commit;


select * from BOOKING_STATE;

drop table BOOKING_STATE;
-------------------------BOOKING-------------------------

CREATE TABLE BOOKING (
    booking_id NUMBER(10) GENERATED AS IDENTITY(START WITH 1 INCREMENT BY 1),
    booking_room_id NUMBER(10) NOT NULL,
    booking_guest_id NUMBER(10) NOT NULL,
    booking_start_date DATE NOT NULL,
    booking_end_date DATE NOT NULL,
    booking_tariff_id NUMBER(10) NOT NULL,
    booking_state NUMBER(2) DEFAULT 1,
    CONSTRAINT booking_pk PRIMARY KEY (booking_id),
    CONSTRAINT booking_room_fk FOREIGN KEY (booking_room_id) REFERENCES ROOMS(room_id) ON DELETE CASCADE,
    CONSTRAINT booking_guest_fk FOREIGN KEY (booking_guest_id) REFERENCES GUESTS(guest_id) ON DELETE CASCADE,
    CONSTRAINT booking_tariff_fk FOREIGN KEY (booking_tariff_id) REFERENCES TARIFF_TYPES(tariff_type_id)ON DELETE CASCADE,
    CONSTRAINT booking_state_fk FOREIGN KEY (booking_state) REFERENCES BOOKING_STATE(booking_state_id) ON DELETE CASCADE
) tablespace HOTEL_TS;
--booking_state:
--1 - забронирован онлайн
--2 - бронь одобрена админом
--3  отменено гостем
SELECT * FROM BOOKING;

DROP TABLE BOOKING;



