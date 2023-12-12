CREATE OR REPLACE PROCEDURE INSERT_SERVICE_TYPES AS
BEGIN
    FOR i IN 1..100000 LOOP
        DECLARE
            v_daily_price FLOAT := DBMS_RANDOM.VALUE(5, 200);
            v_employee_id NUMBER := DBMS_RANDOM.VALUE(1, 5);
        BEGIN
            INSERT INTO SERVICE_TYPES (
                service_type_name,
                service_type_description,
                service_type_daily_price,
                service_type_employee_id
            ) VALUES (
                'service ' || i,
                'service description ' || i,
                v_daily_price,
                -- Выбор случайного employee_id из существующих работников
                (SELECT employee_id FROM EMPLOYEES WHERE ROWNUM = 1)
            );
        END;
    END LOOP;

    COMMIT;

    DBMS_OUTPUT.PUT_LINE('Вставка успешно завершена.');
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Ошибка вставки: ' || SQLERRM);
        -- Откат изменений в случае ошибки
        ROLLBACK;
END INSERT_SERVICE_TYPES;
/

----------------------------------------------------------------
-- удаляем 100 000
----------------------------------------------------------------

CREATE OR REPLACE PROCEDURE DELETE_ALL_SERVICE_TYPES AS
BEGIN
DELETE FROM SERVICE_TYPES
WHERE SERVICE_TYPE_ID > 15;
    COMMIT;
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Ошибка удаления: ' || SQLERRM);
        ROLLBACK;
END DELETE_ALL_SERVICE_TYPES;
/

----------------------------------------------------------------
-- выполнение
----------------------------------------------------------------

Call INSERT_SERVICE_TYPES();



CALL DELETE_ALL_SERVICE_TYPES();


SELECT COUNT(*) FROM SERVICE_TYPES


----------------------------------------------------------------
-- селект запрос
----------------------------------------------------------------

SELECT * FROM SERVICE_TYPES
         JOIN SERVICES ON SERVICES.SERVICE_TYPE_ID= SERVICE_TYPES.SERVICE_TYPE_ID
         WHERE SERVICE_TYPE_DAILY_PRICE BETWEEN 25 AND 250
        ORDER BY SERVICE_TYPES.SERVICE_TYPE_DAILY_PRICE ASC;


SELECT * FROM SERVICE_TYPES
         JOIN SERVICES ON SERVICES.SERVICE_TYPE_ID= SERVICE_TYPES.SERVICE_TYPE_ID
         WHERE SERVICE_TYPE_DAILY_PRICE BETWEEN 25 AND 250
        ORDER BY SERVICE_TYPES.SERVICE_TYPE_DAILY_PRICE ASC;

SELECT * FROM SERVICE_TYPES WHERE SERVICE_TYPE_EMPLOYEE_ID = 1;