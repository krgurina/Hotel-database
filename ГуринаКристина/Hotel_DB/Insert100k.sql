----------------------------------------------------------------
-- выполнение
----------------------------------------------------------------

Call INSERT_SERVICE_TYPES();

CALL DELETE_ALL_SERVICE_TYPES();

SELECT COUNT(*) FROM SERVICE_TYPES;

----------------------------------------------------------------
-- Процедура вставки
----------------------------------------------------------------
CREATE OR REPLACE PROCEDURE INSERT_SERVICE_TYPES AS
BEGIN
    FOR i IN 1..100000 LOOP
        DECLARE
            v_daily_price FLOAT;
            v_employee_id NUMBER;
        BEGIN
            v_daily_price := ROUND(DBMS_RANDOM.VALUE(5, 200), 2);

            SELECT employee_id
            INTO v_employee_id
            FROM EMPLOYEES
            WHERE ROWNUM = 1
            ORDER BY DBMS_RANDOM.VALUE;

            INSERT INTO SERVICE_TYPES (
                service_type_name,
                service_type_description,
                service_type_daily_price,
                service_type_employee_id
            ) VALUES (
                'service ' || i,
                'service description ' || i,
                v_daily_price,
                v_employee_id
            );
        END;
    END LOOP;
    COMMIT;

    DBMS_OUTPUT.PUT_LINE('Вставка успешно завершена.');
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Ошибка вставки: ' || SQLERRM);
        ROLLBACK;
END INSERT_SERVICE_TYPES;


select count(*) from SERVICE_TYPES;
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
-- селект запрос
----------------------------------------------------------------

SELECT * FROM SERVICE_TYPES
         JOIN SERVICES ON SERVICES.SERVICE_TYPE_ID= SERVICE_TYPES.SERVICE_TYPE_ID
         WHERE SERVICE_TYPE_DAILY_PRICE BETWEEN 25 AND 250
            AND SERVICE_TYPE_NAME LIKE '%1890%'
        ORDER BY SERVICE_TYPES.SERVICE_TYPE_DAILY_PRICE ASC;


SELECT * FROM SERVICE_TYPES
         JOIN SERVICES ON SERVICES.SERVICE_TYPE_ID= SERVICE_TYPES.SERVICE_TYPE_ID
         WHERE SERVICE_TYPE_DAILY_PRICE BETWEEN 25 AND 250
        ORDER BY SERVICE_TYPES.SERVICE_TYPE_DAILY_PRICE ASC;

SELECT * FROM SERVICE_TYPES WHERE SERVICE_TYPE_EMPLOYEE_ID = 1;

SELECT * FROM SERVICE_TYPES
         WHERE SERVICE_TYPE_DAILY_PRICE BETWEEN 25 AND 250
            AND SERVICE_TYPE_NAME LIKE '%1890%';
