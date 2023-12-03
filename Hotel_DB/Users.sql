CREATE ROLE Hotel_admin_role;
GRANT create session to Hotel_admin_role ;
GRANT create synonym to Hotel_admin_role ;
GRANT execute on ADMIN.HotelAdminPackageCRUD to Hotel_admin_role ;
GRANT execute on ADMIN.HotelAdminPackageCRUD.INSERTEMPLOYEE to Hotel_admin_role ;




CREATE ROLE Guest_role;
GRANT create session to Guest_role ;
GRANT EXECUTE ON ADMIN.UserPackageProc TO Guest_role;
GRANT EXECUTE ON ADMIN.UserPack TO Guest_role;
GRANT SELECT ON booking_details_view TO Guest_role;


----------------------------------------------------------------
create USER Hotel_admin identified by 123;
grant Hotel_admin_role to Hotel_admin;

create USER Guest identified by 123;
grant Guest_role to Guest;