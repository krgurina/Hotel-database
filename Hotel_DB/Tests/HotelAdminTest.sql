select * from  ALL_USERS;
SELECT * FROM GUESTS;

----------------------------------------------------------------
--1. DeleteGuestCompletely
----------------------------------------------------------------
BEGIN
    ADMIN.HotelAdminPackageCRUD.DeleteGuestCompletely(3);
END;

----------------------------------------------------------------
--2. InsertGuest
----------------------------------------------------------------
BEGIN
    ADMIN.HotelAdminPackageCRUD.InsertGuest(
        p_email => 'guest@example.com',
        p_name => 'Елизавета',
        p_surname => 'Скроцкая',
        p_username => 'user1');
END;
/