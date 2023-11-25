ALTER SESSION SET "_ORACLE_SCRIPT" = TRUE;
--alter pluggable database Hotel_DB open;
-- alter session set container = Hotel_DB;
grant all privileges to admin;
-------------------------ROLE-------------------------
-- роли не будет
-- CREATE TABLE ROLES (
--     role_id NUMBER(10) GENERATED AS IDENTITY(START WITH 1 INCREMENT BY 1),
--     role_name NVARCHAR2(50) NOT NULL,
--     CONSTRAINT role_pk PRIMARY KEY (role_id)
-- );
--
-- SELECT * FROM ROLES;
--
-- INSERT INTO ROLES(role_name) VALUES('Administrator');
-- INSERT INTO ROLES(role_name) VALUES('Staff');
-- INSERT INTO ROLES(role_name) VALUES('Guest');
-- COMMIT;
--
-- DROP TABLE ROLES;

-------------------------ROOM_TYPE-------------------------

CREATE TABLE ROOM_TYPES (
    room_type_id NUMBER(10) GENERATED AS IDENTITY(START WITH 1 INCREMENT BY 1),
    room_type_name NVARCHAR2(50) NOT NULL,
    room_type_capacity NUMBER(10) NOT NULL,
    room_type_daily_price FLOAT(10) NOT NULL,
    room_type_description NVARCHAR2(200) NOT NULL,
    CONSTRAINT room_type_pk PRIMARY KEY (room_type_id)
);

--ДОБАВИТЬ ТИПОВ люкс стандарт и тд
INSERT INTO ROOM_TYPES(room_type_name, room_type_capacity, room_type_description, room_type_daily_price) VALUES('Standard-one', 1, '37-38 м2, однокомнатные номера, телевизор, кондиционер, Wi-Fi, фен, кровать «King size», письменные принадлежности, чайный набор' , 40.00);
INSERT INTO ROOM_TYPES(room_type_name, room_type_capacity, room_type_description, room_type_daily_price) VALUES('Standard-two', 2, '39-40 м2, однокомнатные номера, телевизор, кондиционер, Wi-Fi, фен, 2 кровати «King size», письменные принадлежности, чайный набор', 50.00);
INSERT INTO ROOM_TYPES(room_type_name, room_type_capacity, room_type_description, room_type_daily_price) VALUES('Standard-three', 3, '42-43 м2, однокомнатные номера, телевизор, кондиционер, Wi-Fi, фен, 3 кровати «King size», письменные принадлежности, чайный набор', 60.00);
INSERT INTO ROOM_TYPES(room_type_name, room_type_capacity, room_type_description, room_type_daily_price) VALUES('Family-two', 2, '51 м2, однокомнатные номера,  расположены на 4 и 5 этажах, в номере имеются детские принадлежности, игры, детские полотенца и постельное белье', 45.00);
INSERT INTO ROOM_TYPES(room_type_name, room_type_capacity, room_type_description, room_type_daily_price) VALUES('Family-tree', 3, '60 м2, однокомнатные номера,  расположены на 4 и 5 этажах, в номере имеются детские принадлежности, игры, детские полотенца и постельное белье', 55.00);
INSERT INTO ROOM_TYPES(room_type_name, room_type_capacity, room_type_description, room_type_daily_price) VALUES('Family-four', 4, '65 м2, однокомнатные номера,  расположены на 4 и 5 этажах, в номере имеются детские принадлежности, игры, детские полотенца и постельное белье', 65.00);
INSERT INTO ROOM_TYPES(room_type_name, room_type_capacity, room_type_description, room_type_daily_price) VALUES('Deluxe-one', 1, '51 м2, однокомнатные номера,  расположены на 3-7 этажах', 70.00);
INSERT INTO ROOM_TYPES(room_type_name, room_type_capacity, room_type_description, room_type_daily_price) VALUES('Deluxe-two', 2, '51 м2, однокомнатные номера,  расположены на 3-7 этажах', 85.00);
INSERT INTO ROOM_TYPES(room_type_name, room_type_capacity, room_type_description, room_type_daily_price) VALUES('Lux-one', 1, '76-80 м2, двухкомнатные номера (спальня + гостиная), в номере есть гостевой туалет. Расположены на 3-6 этажах', 100.00);
INSERT INTO ROOM_TYPES(room_type_name, room_type_capacity, room_type_description, room_type_daily_price) VALUES('Lux-two', 2, '76-80 м2, двухкомнатные номера (спальня + гостиная), в номере есть гостевой туалет. Расположены на 3-6 этажах', 130.00);
INSERT INTO ROOM_TYPES(room_type_name, room_type_capacity, room_type_description, room_type_daily_price) VALUES('President lux', 4, '308 м2, восьмикомнатный номер (2 спальни с 2мя отдельными ванными комнатами), гостевые санузлы. Расположен на 7 этаже', 250.00);
COMMIT;

SELECT * FROM ROOM_TYPES;

DROP TABLE ROOM_TYPES;


-------------------------PHOTO-------------------------

CREATE TABLE PHOTO (
    photo_id NUMBER(10) GENERATED AS IDENTITY(START WITH 1 INCREMENT BY 1),
    photo_room_type_id NUMBER(10) NOT NULL,
    photo_source BLOB DEFAULT EMPTY_BLOB(),
    CONSTRAINT photo_pk PRIMARY KEY (photo_id),
    CONSTRAINT photo_room_type_fk FOREIGN KEY (photo_room_type_id) REFERENCES ROOM_TYPES(room_type_id)
);

SELECT * FROM PHOTO;

DROP TABLE PHOTO;

-------------------------GUESTS-------------------------

CREATE TABLE GUESTS (
    guest_id NUMBER(10) GENERATED AS IDENTITY(START WITH 1 INCREMENT BY 1),
    guest_email NVARCHAR2(50) NOT NULL,
    guest_name NVARCHAR2(50) NOT NULL,
    guest_surname NVARCHAR2(50) NOT NULL,
    CONSTRAINT guest_pk PRIMARY KEY (guest_id)
);

-------------------------EMPLOYEES-------------------------

CREATE TABLE EMPLOYEES (
    employee_id NUMBER(10) GENERATED AS IDENTITY(START WITH 1 INCREMENT BY 1),
    employee_name NVARCHAR2(50) NOT NULL,
    employee_surname NVARCHAR2(50) NOT NULL,
    employee_position NVARCHAR2(50) NOT NULL,
    employee_email NVARCHAR2(50) NOT NULL,
    employee_hire_date DATE NOT NULL,   --дата найма
    employee_birth_date DATE NOT NULL,
    CONSTRAINT employee_pk PRIMARY KEY (employee_id)
);

-------------------------ROOMS-------------------------

CREATE TABLE ROOMS (
    room_id NUMBER(10) GENERATED AS IDENTITY(START WITH 1 INCREMENT BY 1),
    room_room_type_id NUMBER(10) NOT NULL,
    room_number NVARCHAR2(50) NOT NULL,
    CONSTRAINT room_pk PRIMARY KEY (room_id),
    CONSTRAINT room_room_type_fk FOREIGN KEY (room_room_type_id) REFERENCES ROOM_TYPES(room_type_id)
);

INSERT INTO ROOMS(room_room_type_id, room_number) VALUES(1, '101');
COMMIT;

-------------------------TARIFF_TYPES-------------------------

CREATE TABLE TARIFF_TYPES (
    tariff_type_id NUMBER(10) GENERATED AS IDENTITY(START WITH 1 INCREMENT BY 1),
    tariff_type_name NVARCHAR2(50) NOT NULL,
    tariff_type_description NVARCHAR2(200) NOT NULL,
    tariff_type_daily_price FLOAT(10) NOT NULL,
    CONSTRAINT tariff_type_pk PRIMARY KEY (tariff_type_id)
);

SELECT * FROM TARIFF_TYPES;

INSERT INTO TARIFF_TYPES (tariff_type_name, tariff_type_description, tariff_type_daily_price) VALUES('Standart','без завтрака', 0.0);
INSERT INTO TARIFF_TYPES (tariff_type_name, tariff_type_description, tariff_type_daily_price) VALUES('Standart+','завтрак включен',  15.0);
INSERT INTO TARIFF_TYPES (tariff_type_name, tariff_type_description, tariff_type_daily_price) VALUES('Business','завтрак включен,  доступ в бизнес-центр, возможность позднего выезда',  20.0);
INSERT INTO TARIFF_TYPES (tariff_type_name, tariff_type_description, tariff_type_daily_price) VALUES('Half Board','2 приёма пищи, доступ к фитнес-залу',  35.50);
INSERT INTO TARIFF_TYPES (tariff_type_name, tariff_type_description, tariff_type_daily_price) VALUES('Full Board','3 приёма пищи, доступ к фитнес-залу',  45.0);
INSERT INTO TARIFF_TYPES (tariff_type_name, tariff_type_description, tariff_type_daily_price) VALUES('All-Inclusive','неограниченное посещение ресторана, доступ к фитнес-залу, спа-услуги, выезд в любое время',  95.0);
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
    CONSTRAINT service_type_employee_fk FOREIGN KEY (service_type_employee_id) REFERENCES EMPLOYEES(employee_id)
);

SELECT * FROM SERVICE_TYPES ;
-- добавить работников
INSERT INTO SERVICE_TYPES (service_type_name, service_type_description, service_type_daily_price) VALUES('Спа-услуги', 'Спа-центры предоставляют различные процедуры, массажи, сауны, джакузи, а также услуги парикмахера и маникюра', 50.0);
INSERT INTO SERVICE_TYPES (service_type_name, service_type_description, service_type_daily_price) VALUES('Трансфер', 'Услуги трансфера из/в аэропорт или другие места', 40.50);
INSERT INTO SERVICE_TYPES (service_type_name, service_type_description, service_type_daily_price) VALUES('Экскурсии', 'Организация поездок и экскурсий по местным достопримечательностям', 10.0);
INSERT INTO SERVICE_TYPES (service_type_name, service_type_description, service_type_daily_price) VALUES('Комната ожидания родителей', 'В комнате есть множество игрушек, с которыми Ваш ребенок может поиграть, специальный столик для рисования, горка и многое другое', 15.50);
INSERT INTO SERVICE_TYPES (service_type_name, service_type_description, service_type_daily_price) VALUES('Фитнес-центр', 'Оборудованный тренажерный зал с современными тренажерами и инструкторами', 20.0);
INSERT INTO SERVICE_TYPES (service_type_name, service_type_description, service_type_daily_price) VALUES('Бассейн','Крытый и открытый бассейн для отдыха и релаксации', 7.50);
INSERT INTO SERVICE_TYPES (service_type_name, service_type_description, service_type_daily_price) VALUES('Прачечная и Химчистка', 'Услуги стирки, глажения и химчистки одежды', 15.0);
INSERT INTO SERVICE_TYPES (service_type_name, service_type_description, service_type_daily_price) VALUES('Сейф', 'В лобби предоставляется услуга пользования сейфом, где Вы можете оставить ценные вещи', 18.0);
INSERT INTO SERVICE_TYPES (service_type_name, service_type_description, service_type_daily_price) VALUES('Услуга «звонок-будильник»', 'Для связи с сервисным центром наберите "0" и сообщите время, когда Вас необходимо разбудить', 5.0);
INSERT INTO SERVICE_TYPES (service_type_name, service_type_description, service_type_daily_price) VALUES('Аренда офисов', 'Гостиница предлагает площади для аренды под офисы', 15.0);
INSERT INTO SERVICE_TYPES (service_type_name, service_type_description, service_type_daily_price) VALUES('Доставка еды в номер ', 'Для гостей предоставляется круглосуточная услуга доставки еды в номер', 15.0);
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
    CONSTRAINT service_service_type_fk FOREIGN KEY (service_type_id) REFERENCES SERVICE_TYPES(service_type_id),
    CONSTRAINT service_guest_fk FOREIGN KEY (service_guest_id) REFERENCES GUESTS(guest_id)
);

SELECT * FROM SERVICES;

DROP TABLE SERVICES;

-------------------------BOOKING-------------------------

CREATE TABLE BOOKING (
    booking_id NUMBER(10) GENERATED AS IDENTITY(START WITH 1 INCREMENT BY 1),
    booking_room_id NUMBER(10) NOT NULL,
    booking_guest_id NUMBER(10) NOT NULL,
    booking_start_date DATE NOT NULL,
    booking_end_date DATE NOT NULL,
    booking_tariff_id NUMBER(10) NOT NULL,
    booking_state NUMBER(1) DEFAULT 0,
    CONSTRAINT booking_pk PRIMARY KEY (booking_id),
    CONSTRAINT booking_room_fk FOREIGN KEY (booking_room_id) REFERENCES ROOMS(room_id),
    CONSTRAINT booking_guest_fk FOREIGN KEY (booking_guest_id) REFERENCES GUESTS(guest_id),
    CONSTRAINT booking_tariff_fk FOREIGN KEY (booking_tariff_id) REFERENCES TARIFF_TYPES(tariff_type_id)
);
--booking_state:
--0 - забронирован онлайн
--1 - бронь одобрена админом

SELECT * FROM BOOKING;

DROP TABLE BOOKING;

-------------------------NONAME-------------------------

drop table booking;
drop table SERVICES;
drop table PERSONS;
drop table roles;

