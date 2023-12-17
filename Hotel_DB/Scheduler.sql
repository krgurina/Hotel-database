ALTER DATABASE SET TIME_ZONE='Europe/Moscow';

-------------------------------------------------------
-- Выселение гостей
-------------------------------------------------------
begin
dbms_scheduler.create_schedule(
  schedule_name => 'DAILY_CHECKOUT_SCHEDULE',
  start_date => SYSTIMESTAMP,
    end_date => NULL, -- добавить эту строку
  repeat_interval => 'FREQ=DAILY; BYHOUR=2; BYMINUTE=30; BYSECOND=0',
  comments => 'DAILY_CHECKOUT_SCHEDULE starts now'
);
end;

begin
dbms_scheduler.create_program(
  program_name => 'DAILY_CHECKOUT_PROGRAM',
  program_type => 'STORED_PROCEDURE',
  program_action => 'ADMIN.HotelAdminPack.CheckOutForExpiredBookings',
  number_of_arguments => 0,
  enabled => true,
  comments => 'DAILY_CHECKOUT_PROGRAM'
);
end;

begin
    dbms_scheduler.create_job(
            job_name => 'DAILY_CHECKOUT_JOB',
            program_name => 'DAILY_CHECKOUT_PROGRAM',
            schedule_name => 'DAILY_CHECKOUT_SCHEDULE',
            enabled => true
        );
end;


-- Создание плана
-- BEGIN
--   DBMS_SCHEDULER.create_schedule(
--     schedule_name   => 'DAILY_CHECKOUT_SCHEDULE',
--     start_date      => TRUNC(SYSTIMESTAMP) + INTERVAL '1' DAY + INTERVAL '1' HOUR + INTERVAL '25' MINUTE,
--     repeat_interval => 'FREQ=DAILY; BYHOUR=1; BYMINUTE=25; BYSECOND=0'
--   );
-- END;
-- /
--
-- -- Создание задачи
-- BEGIN
--   DBMS_SCHEDULER.create_job (
--     job_name        => 'DAILY_CHECKOUT_JOB',
--     job_type        => 'PLSQL_BLOCK',
--     job_action      => 'BEGIN CheckOutForExpiredBookings; END;',
--     start_date      => TRUNC(SYSTIMESTAMP) + INTERVAL '1' DAY + INTERVAL '1' HOUR + INTERVAL '25' MINUTE,
--     repeat_interval => 'FREQ=DAILY; BYHOUR=1; BYMINUTE=25; BYSECOND=0',
--     enabled         => TRUE
--   );
-- END;
-- /
----------------------------------------------------------------
BEGIN
      DBMS_SCHEDULER.drop_job('DAILY_CHECKOUT_JOB');

  DBMS_SCHEDULER.drop_schedule('DAILY_CHECKOUT_SCHEDULE');
DBMS_SCHEDULER.DROP_PROGRAM('DAILY_CHECKOUT_PROGRAM');
END;
  BEGIN
END;

SELECT * FROM user_scheduler_job_run_details WHERE job_name = 'DAILY_CHECKOUT_JOB';
SELECT * FROM user_scheduler_job_log WHERE job_name = 'DAILY_CHECKOUT_JOB';


select job_name, next_run_date from user_scheduler_jobs where job_name = 'DAILY_CHECKOUT_JOB';
select program_name, enabled, program_type, program_action from user_scheduler_programs;

select job_name, enabled, state, next_run_date from user_scheduler_jobs;
----
begin
dbms_scheduler.run_job('DAILY_CHECKOUT_JOB');
end;
----------------------------------------------------------------
drop procedure Check_Out_GUESTS;
create or replace PROCEDURE Check_Out_GUESTS AS
  v_booking_id NUMBER;
  v_cost FLOAT;
BEGIN
  FOR booking_rec IN (SELECT BOOKING_ID
                      FROM booking_details_view
                      WHERE TRUNC(BOOKING_END_DATE) = TRUNC(SYSDATE) or TRUNC(BOOKING_END_DATE) < TRUNC(SYSDATE))
  LOOP
    v_booking_id := booking_rec.BOOKING_ID;
    v_cost := GUEST.CALCULATE_STAY_COST(v_booking_id);
    IF v_cost IS NOT NULL THEN
      DBMS_OUTPUT.PUT_LINE('За проживание в отеле с вас ' || TO_CHAR(v_cost, '9999.99') || 'р.');
    ELSE
      RAISE_APPLICATION_ERROR(-20010,'Не удалось рассчитать стоимость проживания.');
    END IF;

    DELETE FROM BOOKING WHERE BOOKING_ID = v_booking_id;
    COMMIT;
  END LOOP;
END Check_Out_GUESTS;
-------------------------------------------------------
-- удаление отмененных броней
-------------------------------------------------------
BEGIN
  DBMS_SCHEDULER.create_job (
    job_name        => 'DELETE_CANCEL_BOOKING_JOB',
    job_type        => 'PLSQL_BLOCK',
    job_action      => 'BEGIN
                          DELETE FROM Booking
                          WHERE booking_state = 3;
                        END;',
    start_date      => TRUNC(SYSDATE) + INTERVAL '1' DAY,
    repeat_interval => 'FREQ=DAILY; INTERVAL=3; BYHOUR=0; BYMINUTE=0; BYSECOND=0',
    enabled         => TRUE
  );
END;


----------------------------------------------------------------
-- удалить задачу
BEGIN
  DBMS_SCHEDULER.drop_job('DELETE_CANCEL_BOOKING_JOB');
END;



----------------------------------------------------------------
-- тестик фонового процесса
----------------------------------------------------------------
BEGIN
  DBMS_SCHEDULER.create_job (
    job_name        => 'OUTPUT_MESSAGE_JOB',
    job_type        => 'PLSQL_BLOCK',
    job_action      => 'BEGIN
                          DBMS_OUTPUT.PUT_LINE(''Пример сообщения'');
                        END;',
    start_date      => SYSTIMESTAMP,
    repeat_interval => 'FREQ=MINUTELY; INTERVAL=1',
    enabled         => TRUE
  );
END;

BEGIN
  DBMS_SCHEDULER.drop_job('OUTPUT_MESSAGE_JOB');
END;

