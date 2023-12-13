-------------------------------------------------------
-- Выселение гостей
-------------------------------------------------------
-- Создание плана
BEGIN
  DBMS_SCHEDULER.create_schedule(
    schedule_name   => 'DAILY_CHECKOUT_SCHEDULE',
    start_date      => SYSTIMESTAMP,
    repeat_interval => 'FREQ=DAILY; BYHOUR=12; BYMINUTE=0; BYSECOND=0'
  );
END;
/

-- Создание задачи
BEGIN
  DBMS_SCHEDULER.create_job (
    job_name        => 'DAILY_CHECKOUT_JOB',
    job_type        => 'PLSQL_BLOCK',
    job_action      => 'BEGIN CheckOutForExpiredBookings; END;',
    start_date      => SYSTIMESTAMP,
    repeat_interval => 'FREQ=DAILY; BYHOUR=12; BYMINUTE=0; BYSECOND=0',
    enabled         => TRUE
  );
END;
/


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

