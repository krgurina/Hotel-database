select * from dba_users;
----------------------------------------------------------------
CREATE ROLE Hotel_admin_role;

GRANT create session to Hotel_admin_role ;
GRANT create synonym to Hotel_admin_role ;
GRANT execute on ADMIN.HotelAdminPack to Hotel_admin_role ;
--GRANT execute on ADMIN.HotelAdminPack.INSERTEMPLOYEE to Hotel_admin_role ;


----------------------------------------------------------------
CREATE ROLE Employee_role;

GRANT create session to Employee_role ;
GRANT EXECUTE ON ADMIN.EmployeePack TO Employee_role;

----------------------------------------------------------------
CREATE ROLE Guest_role;

GRANT create session to Guest_role ;
GRANT EXECUTE ON ADMIN.UserPack TO Guest_role;
GRANT SELECT ON booking_details_view TO Guest_role;
GRANT READ ON DIRECTORY MEDIA_DIR TO Guest_role;


CREATE PROFILE PF_USER LIMIT
    PASSWORD_LIFE_TIME 180          -- количество дней жизни пароля
    SESSIONS_PER_USER 3             -- количество сессий для пользователя
    FAILED_LOGIN_ATTEMPTS 7         -- количество попыток входа
    PASSWORD_LOCK_TIME 1            -- количество дней блокирования после ошибок
    PASSWORD_REUSE_TIME 5          -- через сколько дней можно повторить пароль
    CONNECT_TIME 180                -- время соединения, минут
    IDLE_TIME 45;                   -- количество минут простоя

----------------------------------------------------------------
create USER Hotel_admin identified by 123;
grant Hotel_admin_role to Hotel_admin;
GRANT READ, WRITE ON DIRECTORY MEDIA_DIR TO Hotel_admin;





create USER Guest identified by 123;
grant Guest_role to Guest;