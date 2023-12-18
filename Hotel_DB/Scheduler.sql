ALTER DATABASE SET TIME_ZONE='Europe/Moscow';

-------------------------------------------------------
-- Выселение гостей
-------------------------------------------------------
begin
dbms_scheduler.create_schedule(
  schedule_name => 'DAILY_CHECKOUT_SCHEDULE',
  start_date => SYSTIMESTAMP,
    end_date => NULL,
  repeat_interval => 'FREQ=DAILY; BYHOUR=12; BYMINUTE=0; BYSECOND=0',
  comments => 'DAILY_CHECKOUT_SCHEDULE starts now'
);
end;

begin
dbms_scheduler.create_program(
  program_name => 'DAILY_CHECKOUT_PROGRAM',
  program_type => 'STORED_PROCEDURE',
  program_action => 'ADMIN.HOTELADMINPACK.CHECK_OUT_GUESTS',
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
----------------------------------------------------------------
-- заселение гостей
----------------------------------------------------------------
BEGIN
  DBMS_SCHEDULER.create_job (
    job_name        => 'CHECK_IN_JOB',
    job_type        => 'PLSQL_BLOCK',
    job_action      => 'BEGIN ADMIN.HOTELADMINPACK.CHECK_IN_GUESTS; END;',
    start_date      => SYSTIMESTAMP,
    repeat_interval => 'FREQ=DAILY; BYHOUR=6; BYMINUTE=0; BYSECOND=0',
    enabled         => TRUE
  );
END;


----------------------------------------------------------------
-- УДАЛЕНИЕ
----------------------------------------------------------------
BEGIN
    DBMS_SCHEDULER.drop_job('DAILY_CHECKOUT_JOB');
    DBMS_SCHEDULER.drop_schedule('DAILY_CHECKOUT_SCHEDULE');
    DBMS_SCHEDULER.DROP_PROGRAM('DAILY_CHECKOUT_PROGRAM');
END;
BEGIN
    DBMS_SCHEDULER.drop_job('DELETE_CANCEL_BOOKING_JOB');
END;

--отчет
SELECT * FROM user_scheduler_job_run_details WHERE job_name = 'DAILY_CHECKOUT_JOB';
SELECT * FROM user_scheduler_job_run_details WHERE job_name = 'DELETE_JOB';
SELECT * FROM user_scheduler_job_log WHERE job_name = 'DAILY_CHECKOUT_JOB';


select job_name, next_run_date from user_scheduler_jobs; --where job_name = 'DAILY_CHECKOUT_JOB';

----
begin
dbms_scheduler.run_job('DAILY_CHECKOUT_JOB');
end;
--------------------------------------------------------------
BEGIN
  DBMS_SCHEDULER.create_job (
    job_name        => 'DELETE_JOB',
    job_type        => 'PLSQL_BLOCK',
    job_action      => 'BEGIN Check_Out_GUESTS; END;',
    start_date      => SYSTIMESTAMP,
    repeat_interval => 'FREQ=DAILY; BYHOUR=8; BYMINUTE=15; BYSECOND=0',
    enabled         => TRUE
  );
END;


-------------------------------------------------------
-- удаление отмененных броней
-------------------------------------------------------
BEGIN
  DBMS_SCHEDULER.create_job (
    job_name        => 'DELETE_CANCEL_BOOKING_JOB',
    job_type        => 'PLSQL_BLOCK',
    job_action      => 'BEGIN
                          DELETE FROM Booking
                          WHERE booking_state = 3;' ||
                       'commit;
                        END;',
    start_date      => TRUNC(SYSTIMESTAMP) + INTERVAL '1' DAY,
    repeat_interval => 'FREQ=DAILY; INTERVAL=3; BYHOUR=0; BYMINUTE=0; BYSECOND=0',
    enabled         => TRUE
  );
END;


----------------------------------------------------------------
-- удалить задачу
BEGIN
  DBMS_SCHEDULER.drop_job('DELETE_CANCEL_BOOKING_JOB');
END;


