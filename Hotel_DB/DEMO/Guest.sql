----------------------------------------------------------------
-- Просмотр свободных комнат
----------------------------------------------------------------
BEGIN
    GUEST.GET_AVAILABLE_ROOMS(
        P_CAPACITY => 2,
        p_start_date => TO_DATE('2023-12-11', 'YYYY-MM-DD'),
        p_end_date => TO_DATE('2023-12-12', 'YYYY-MM-DD')
    );
EXCEPTION
    WHEN VALUE_ERROR THEN
        DBMS_OUTPUT.PUT_LINE('Ошибка преобразования числа в строку.');
    WHEN NO_DATA_FOUND THEN
            DBMS_OUTPUT.PUT_LINE('Не найдено доступных комнат.');
    WHEN others THEN
        DBMS_OUTPUT.PUT_LINE('Произошла ошибка: ' || SQLERRM);
END;


----------------------------------------------------------------
-- Просмотр фото
----------------------------------------------------------------
SELECT * FROM GET_ROOM_PHOTO;
----------------------------------------------------------------
-- Просмотр тарифов
----------------------------------------------------------------
call GUEST.Get_Tariff_Info();

----------------------------------------------------------------
-- Забронировать сейчас
----------------------------------------------------------------
BEGIN
    GUEST.BOOKING_NOW(
        p_room_id =>4,
        p_end_date => TO_DATE('2024-01-05', 'YYYY-MM-DD'),
        p_tariff_id => 4
    );
EXCEPTION
    WHEN VALUE_ERROR THEN
        DBMS_OUTPUT.PUT_LINE('Ошибка преобразования числа в строку.');
    WHEN others THEN
        DBMS_OUTPUT.PUT_LINE('Произошла ошибка: ' || SQLERRM);
END;


----------------------------------------------------------------
-- Забронировать предварительно
----------------------------------------------------------------
BEGIN
    GUEST.PRE_BOOKING(
        p_room_id => 9,
        p_start_date => TO_DATE('2024-05-01', 'YYYY-MM-DD'),
        p_end_date => TO_DATE('2024-06-15', 'YYYY-MM-DD'),
        p_tariff_id => 2
    );
EXCEPTION
    WHEN VALUE_ERROR THEN
        DBMS_OUTPUT.PUT_LINE('Ошибка преобразования числа в строку.');
    WHEN others THEN
        DBMS_OUTPUT.PUT_LINE('Произошла ошибка: ' || SQLERRM);
END;

----------------------------------------------------------------
-- Изменить бронь
----------------------------------------------------------------
DECLARE
    v_booking_id NUMBER(10):=24;
BEGIN
    GUEST.Edit_Booking(
        p_booking_id => v_booking_id,
        p_start_date => TO_DATE('2024-02-01', 'YYYY-MM-DD'),
        p_end_date => TO_DATE('2024-02-20', 'YYYY-MM-DD'),
        p_tariff_id => 4
    );
    GUEST.Get_BookingDetails_By_Id(v_booking_id);
EXCEPTION
    WHEN VALUE_ERROR THEN
        DBMS_OUTPUT.PUT_LINE('Ошибка преобразования числа в строку.');
    WHEN others THEN
        DBMS_OUTPUT.PUT_LINE('Произошла ошибка: ' || SQLERRM);
END;

----------------------------------------------------------------
-- Просмотреть все брони текущего пользователя
----------------------------------------------------------------
CALL GUEST.GET_MY_BOOKINGS();

----------------------------------------------------------------
-- Отменить предварительную бронь
----------------------------------------------------------------
BEGIN
    GUEST.Deny_Booking(
        p_booking_id => 23
    );
EXCEPTION
    WHEN VALUE_ERROR THEN
        DBMS_OUTPUT.PUT_LINE('Ошибка преобразования числа в строку.');
    WHEN others THEN
        DBMS_OUTPUT.PUT_LINE('Произошла ошибка: ' || SQLERRM);
END;
----------------------------------------------------------------
-- Восстановить отмененную бронь
----------------------------------------------------------------
BEGIN
    GUEST.Restore_Booking(
        p_booking_id => 22
    );
EXCEPTION
    WHEN VALUE_ERROR THEN
        DBMS_OUTPUT.PUT_LINE('Ошибка преобразования числа в строку.');
    WHEN others THEN
        DBMS_OUTPUT.PUT_LINE('Произошла ошибка: ' || SQLERRM);
END;


----------------------------------------------------------------
-- Заказать сервис
----------------------------------------------------------------
BEGIN
    GUEST.Order_Service(
        p_service_type_id => 10,
        p_service_start_date => TO_DATE('2023-12-30', 'YYYY-MM-DD'),
        p_service_end_date => TO_DATE('2023-12-31', 'YYYY-MM-DD')
    );
EXCEPTION
    WHEN VALUE_ERROR THEN
        DBMS_OUTPUT.PUT_LINE('Ошибка преобразования числа в строку.');
    WHEN others THEN
        DBMS_OUTPUT.PUT_LINE('Произошла ошибка: ' || SQLERRM);
END;

----------------------------------------------------------------
-- Просмотреть брони текущего пользователя
----------------------------------------------------------------
CALL GUEST.GET_MY_SERVICES();

----------------------------------------------------------------
-- Изменить сервис
----------------------------------------------------------------
BEGIN
    GUEST.Edit_Service(
        p_service_id =>22,
        p_service_type_id => 5,
        p_service_start_date => TO_DATE('2024-01-08', 'YYYY-MM-DD'),
        p_service_end_date => TO_DATE('2024-01-11', 'YYYY-MM-DD')
    );
EXCEPTION
    WHEN VALUE_ERROR THEN
        DBMS_OUTPUT.PUT_LINE('Ошибка преобразования числа в строку.');
    WHEN others THEN
        DBMS_OUTPUT.PUT_LINE('Произошла ошибка: ' || SQLERRM);
END;

----------------------------------------------------------------
-- Отменить предварительную бронь
----------------------------------------------------------------
BEGIN
    GUEST.DenyService(
        p_service_id => 22
    );
EXCEPTION
    WHEN VALUE_ERROR THEN
        DBMS_OUTPUT.PUT_LINE('Ошибка преобразования числа в строку.');
    WHEN others THEN
        DBMS_OUTPUT.PUT_LINE('Произошла ошибка: ' || SQLERRM);
END;

----------------------------------------------------------------
-- Рассчитать стоимость проживания
----------------------------------------------------------------
BEGIN
    GUEST.GET_STAY_COST(
        p_booking_id => 26
    );
EXCEPTION
    WHEN VALUE_ERROR THEN
        DBMS_OUTPUT.PUT_LINE('Ошибка преобразования числа в строку.');
    WHEN others THEN
        DBMS_OUTPUT.PUT_LINE('Произошла ошибка: ' || SQLERRM);
END;

----------------------------------------------------------------
-- Выселиться
----------------------------------------------------------------
BEGIN
    GUEST.Check_Out(
        p_booking_id => 26
    );
EXCEPTION
    WHEN VALUE_ERROR THEN
        DBMS_OUTPUT.PUT_LINE('Ошибка преобразования числа в строку.');
    WHEN others THEN
        DBMS_OUTPUT.PUT_LINE('Произошла ошибка: ' || SQLERRM);
END;