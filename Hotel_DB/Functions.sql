-- --инфа о брони
-- CREATE OR REPLACE FUNCTION GetBookingDetails(
--     p_booking_id IN NUMBER
-- )
-- RETURN booking_details_view%ROWTYPE
-- AS
--     v_booking_details booking_details_view%ROWTYPE;
-- BEGIN
--     -- Извлекаем информацию о брони с использованием представления
--     SELECT *
--     INTO v_booking_details
--     FROM ADMIN.booking_details_view  -- Укажите правильную схему
--     WHERE booking_id = p_booking_id;
--
--     RETURN v_booking_details;
-- EXCEPTION
--     WHEN NO_DATA_FOUND THEN
--         RAISE_APPLICATION_ERROR(-20001, 'Бронь с указанным ID (' || p_booking_id || ') не найдена.');
--     WHEN OTHERS THEN
--         RAISE_APPLICATION_ERROR(-20002, 'Произошла ошибка: ' || SQLERRM);
-- END GetBookingDetails;
-- /
--

-- Рассчет итоговой стоимости
CREATE OR REPLACE FUNCTION CALCULATE_STAY_COST(p_booking_id IN NUMBER) RETURN FLOAT AS
  v_total_cost FLOAT := 0;

  -- Получаем информацию о брони
  v_booking_status NUMBER;
  v_start_date DATE;
  v_end_date DATE;
  v_room_id NUMBER;
  v_tariff_id NUMBER;
  v_guest_id NUMBER;
BEGIN
  -- Получаем информацию о брони
  SELECT booking_state, booking_start_date, booking_end_date, booking_room_id, booking_tariff_id, booking_guest_id
  INTO v_booking_status, v_start_date, v_end_date, v_room_id, v_tariff_id, v_guest_id
  FROM BOOKING
  WHERE BOOKING.booking_id = p_booking_id;

  -- Проверяем статус брони
  IF v_booking_status = 1 THEN
    -- Рассчитываем стоимость проживания с учетом заказанных сервисов
    SELECT
      (v_end_date - v_start_date) * rt.room_type_daily_price +
      (v_end_date - v_start_date) * tt.tariff_type_daily_price
    INTO v_total_cost
    FROM ROOMS r
    JOIN ROOM_TYPES rt ON r.room_room_type_id = rt.room_type_id
    JOIN TARIFF_TYPES tt ON v_tariff_id = tt.tariff_type_id
    WHERE r.room_id = v_room_id;

    -- Добавляем стоимость сервисов
    FOR service_info IN (
      SELECT s.service_type_id, s.service_start_date, s.service_end_date, st.service_type_daily_price
      FROM SERVICES s
      JOIN SERVICE_TYPES st ON s.service_type_id = st.service_type_id
      WHERE s.service_guest_id = v_guest_id
    ) LOOP
      v_total_cost := v_total_cost + (service_info.service_end_date - service_info.service_start_date) * service_info.service_type_daily_price;
    END LOOP;

  ELSIF v_booking_status = 0 THEN
    -- Рассчитываем стоимость проживания без учета сервисов
    SELECT
      (v_end_date - v_start_date) * rt.room_type_daily_price +
      (v_end_date - v_start_date) * tt.tariff_type_daily_price
    INTO v_total_cost
    FROM ROOMS r
    JOIN ROOM_TYPES rt ON r.room_room_type_id = rt.room_type_id
    JOIN TARIFF_TYPES tt ON v_tariff_id = tt.tariff_type_id
    WHERE r.room_id = v_room_id;
  END IF;

  RETURN v_total_cost;
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    RETURN NULL; -- Обработка ошибки, если бронь не найдена
     WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Произошла ошибка: ' || SQLERRM);
        RETURN NULL; -- Обработка ошибки, если бронь не найдена

END CALCULATE_STAY_COST;
/

--вызов
DECLARE
  v_booking_id NUMBER := 6; -- Замените на фактический идентификатор брони
  v_cost FLOAT;
BEGIN
  v_cost := CALCULATE_STAY_COST(v_booking_id);
  IF v_cost IS NOT NULL THEN
    DBMS_OUTPUT.PUT_LINE('Стоимость проживания: ' || TO_CHAR(v_cost, '999999.99'));
  ELSE
    DBMS_OUTPUT.PUT_LINE('Бронь не найдена или произошла ошибка.');
  END IF;
END;
/

------
select * from BOOKING where BOOKING_ID = 21;

update  BOOKING set booking_state = 1 where booking_id = 4