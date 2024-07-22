----------------------------------------------------------------
-- триггер для экспорта гостей
----------------------------------------------------------------
create or replace trigger UPDATE_GUEST_XML_TRIGGER
    after insert or delete or update
    on GUESTS
begin
    EXPORT_TO_FILE('select * from Guests', 'Guests');
    DBMS_OUTPUT.PUT_LINE('Данные о гостях успешно обновлены');
EXCEPTION
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('Произошла ошибка при экспорте гостей: ' || SQLERRM);
end;

----------------------------------------------------------------
-- триггер для экспорта сотрудников
----------------------------------------------------------------
create or replace trigger UPDATE_EMPLOYEE_XML_TRIGGER
    after insert or delete or update
    on EMPLOYEES
begin
    EXPORT_TO_FILE('select * from EMPLOYEES', 'Employees');
    DBMS_OUTPUT.PUT_LINE('Данные о сотрудников успешно обновлены');
EXCEPTION
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('Произошла ошибка при экспорте сотрудников: ' || SQLERRM);
end;

----------------------------------------------------------------

select * from USER_TRIGGERS
