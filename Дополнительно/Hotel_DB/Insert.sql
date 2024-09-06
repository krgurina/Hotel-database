INSERT INTO GUESTS (guest_email, guest_name, guest_surname)
VALUES
    ('user1@example.com', 'Иван', 'Иванов');
INSERT INTO GUESTS (guest_email, guest_name, guest_surname)
VALUES
    ('user2@example.com', 'Мария', 'Петрова');
INSERT INTO GUESTS (guest_email, guest_name, guest_surname)
VALUES
    ('user3@example.com', 'Виктория', 'Смирнова');

----------------------------------------------------------------
-- Вставка работников отеля
INSERT INTO EMPLOYEES (employee_name, employee_surname, employee_position, employee_email, employee_hire_date, employee_birth_date)
VALUES
    ('Анна', 'Иванова', 'Повар', 'anna@example.com', TO_DATE('2023-01-01', 'YYYY-MM-DD'), TO_DATE('1980-05-15', 'YYYY-MM-DD'));

INSERT INTO EMPLOYEES (employee_name, employee_surname, employee_position, employee_email, employee_hire_date, employee_birth_date)
VALUES
    ('Дмитрий', 'Петров', 'Водитель', 'dmitrwwey@example.com', TO_DATE('2023-02-15', 'YYYY-MM-DD'), TO_DATE('1982-11-22', 'YYYY-MM-DD'));

INSERT INTO EMPLOYEES (employee_name, employee_surname, employee_position, employee_email, employee_hire_date, employee_birth_date)
VALUES
    ('Екатерина', 'Сидорова', 'Горничная', 'ekaterina12e@example.com', TO_DATE('2023-03-10', 'YYYY-MM-DD'), TO_DATE('1988-07-03', 'YYYY-MM-DD'));

INSERT INTO EMPLOYEES (employee_name, employee_surname, employee_position, employee_email, employee_hire_date, employee_birth_date)
VALUES
    ('Елизавета', 'Петрова', 'Горничная', 'eliz37rr@example.com', TO_DATE('2023-03-10', 'YYYY-MM-DD'), TO_DATE('1988-07-03', 'YYYY-MM-DD'));

----------------------------------------------------------------
INSERT INTO ROOMS (room_room_type_id, room_number) VALUES (1, '201');
INSERT INTO ROOMS (room_room_type_id, room_number) VALUES (1, '202');
INSERT INTO ROOMS (room_room_type_id, room_number) VALUES (2, '203');
INSERT INTO ROOMS (room_room_type_id, room_number) VALUES (2, '204');
INSERT INTO ROOMS (room_room_type_id, room_number) VALUES (3, '301');
INSERT INTO ROOMS (room_room_type_id, room_number) VALUES (4, '401');

-- Вставка данных о бронировании
INSERT INTO BOOKING (booking_room_id, booking_guest_id, booking_start_date, booking_end_date, booking_tariff_id, booking_state)
VALUES
    (1, 1, TO_DATE('2023-05-01', 'YYYY-MM-DD'), TO_DATE('2023-05-07', 'YYYY-MM-DD'), 1, 0);

INSERT INTO BOOKING (booking_room_id, booking_guest_id, booking_start_date, booking_end_date, booking_tariff_id, booking_state)
VALUES
    (2, 1, TO_DATE('2023-06-10', 'YYYY-MM-DD'), TO_DATE('2023-06-15', 'YYYY-MM-DD'), 2, 0);

INSERT INTO BOOKING (booking_room_id, booking_guest_id, booking_start_date, booking_end_date, booking_tariff_id, booking_state)
VALUES
    (3, 2, TO_DATE('2023-07-20', 'YYYY-MM-DD'), TO_DATE('2023-07-25', 'YYYY-MM-DD'), 1, 0);

INSERT INTO BOOKING (booking_room_id, booking_guest_id, booking_start_date, booking_end_date, booking_tariff_id, booking_state)
VALUES
    (1, 2, TO_DATE('2023-08-15', 'YYYY-MM-DD'), TO_DATE('2023-08-20', 'YYYY-MM-DD'), 2, 0);

INSERT INTO BOOKING (booking_room_id, booking_guest_id, booking_start_date, booking_end_date, booking_tariff_id, booking_state)
VALUES
    (2, 3, TO_DATE('2023-09-05', 'YYYY-MM-DD'), TO_DATE('2023-09-10', 'YYYY-MM-DD'), 1, 0);


commit;
