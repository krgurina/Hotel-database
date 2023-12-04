select * from  ALL_USERS;
SELECT * FROM GUESTS;


----------------------------------------------------------------
--1. InsertGuest
----------------------------------------------------------------
BEGIN
    ADMIN.HotelAdminPack.InsertGuest(
        p_email => 'guest2@example.com',
        p_name => 'Елизавета',
        p_surname => 'Скроцкая',
        p_username => 'user3');
END;
/



----------------------------------------------------------------
--2. InsertEmployee
----------------------------------------------------------------
BEGIN
    ADMIN.HotelAdminPack.InsertEmployee(
        p_name => 'Кристина',
        p_surname => 'Гурина',
        p_position => 'Менеджер',
        p_email => 'example_manager@email.com',
        p_hire_date => TO_DATE('2023-01-01', 'YYYY-MM-DD'),
        p_birth_date => TO_DATE('2003-09-28', 'YYYY-MM-DD'),
        p_username => 'employee2'
    );
END;
/


----------------------------------------------------------------
--2. DeleteGuestCompletely
----------------------------------------------------------------
BEGIN
    ADMIN.HotelAdminPack.DeleteGuestCompletely(2);
END;

----------------------------------------------------------------
--3. InsertGuest
----------------------------------------------------------------
BEGIN
    ADMIN.HotelAdminPack.InsertGuest(
        p_email => 'guest1@example.com',
        p_name => 'Елизавета',
        p_surname => 'Скроцкая',
        p_username => 'user1');
END;
/