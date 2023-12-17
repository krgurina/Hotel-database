CREATE INDEX service_daily_price_index ON SERVICE_TYPES(service_type_daily_price);
CREATE INDEX service_employee_id_index ON SERVICE_TYPES(service_type_employee_id); --удалить
----------------------------------------------------------------
       DROP INDEX service_daily_price_index;
       DROP INDEX service_employee_id_index;
----------------------------------------------------------------



CREATE INDEX room_capacity_index ON ROOM_TYPES(room_type_capacity);
CREATE INDEX room_daily_price_index ON ROOM_TYPES(room_type_daily_price);

CREATE INDEX photo_room_type_index ON PHOTO(photo_room_type_id);    --удалить

CREATE INDEX guest_name_surname_index ON GUESTS(guest_name, guest_surname);
CREATE INDEX guest_email_index ON GUESTS(guest_email);  --удалить

CREATE INDEX employee_name_surname_index ON EMPLOYEES(employee_name, employee_surname);
CREATE INDEX employee_position_index ON EMPLOYEES(employee_position);   --удалить
CREATE INDEX employee_email_index ON EMPLOYEES(employee_email);

CREATE INDEX room_number_index ON ROOMS(room_number);--- --удалить
CREATE INDEX room_room_type_id_index ON ROOMS(room_room_type_id);

CREATE INDEX tariff_daily_price_index ON TARIFF_TYPES(tariff_type_daily_price);

CREATE INDEX service_type_index ON SERVICES(service_type_id);
CREATE INDEX service_guest_index ON SERVICES(service_guest_id);
CREATE INDEX service_dates_index ON SERVICES(service_start_date, service_end_date);

CREATE INDEX booking_room_index ON BOOKING(booking_room_id);
CREATE INDEX booking_guest_index ON BOOKING(booking_guest_id);  --удалить
CREATE INDEX booking_dates_index ON BOOKING(booking_start_date, booking_end_date);
CREATE INDEX booking_state_index ON BOOKING(booking_state);





DROP INDEX service_daily_price_index;
