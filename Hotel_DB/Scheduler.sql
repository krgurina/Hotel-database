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
/

----------------------------------------------------------------
-- удалить задачу
BEGIN
  DBMS_SCHEDULER.drop_job('DELETE_CANCEL_BOOKING_JOB');
END;
/

----------------------------------------------------------------
-- удалегие броней, которым больше 2 месяцев
BEGIN
  DBMS_SCHEDULER.create_job (
    job_name        => 'DELETE_OLD_BOOKINGS_JOB',
    job_type        => 'PLSQL_BLOCK',
    job_action      => 'BEGIN
                          DELETE FROM Booking
                          WHERE booking_end_date < ADD_MONTHS(SYSDATE, -2);
                        END;',
    start_date      => SYSTIMESTAMP,
    repeat_interval => 'FREQ=WEEKLY; BYHOUR=0; BYMINUTE=0; BYSECOND=0',
    enabled         => TRUE
  );
END;
/