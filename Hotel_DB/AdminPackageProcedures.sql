CREATE OR REPLACE PACKAGE HotelAdminPackage AS






END HotelAdminPackage;
--/
CREATE OR REPLACE PACKAGE BODY HotelAdminPackage AS
--создать тип комнаты
CREATE OR REPLACE PROCEDURE CreateRoomType(
  p_room_type_name        NVARCHAR2,
  p_room_type_capacity    NUMBER,
  p_room_type_daily_price FLOAT,
  p_room_type_description NVARCHAR2
) AS
    existing_count NUMBER;
BEGIN
  -- Проверка, что имя типа комнаты не является NULL или пустым
    IF p_room_type_name IS NULL OR p_room_type_name = '' THEN
        RAISE_APPLICATION_ERROR(-20001, 'Имя типа комнаты не может быть NULL или пустым.');
    END IF;
  -- Проверка, что вместимость типа комнаты больше 0
    IF p_room_type_capacity < 0 THEN
        RAISE_APPLICATION_ERROR(-20002, 'Вместимость типа комнаты должна быть больше 0.');
    END IF;
  -- Проверка, что ежедневная цена типа комнаты больше 0
    IF p_room_type_daily_price <= 0 THEN
        RAISE_APPLICATION_ERROR(-20003, 'Ежедневная цена типа комнаты должна быть больше 0.');
    END IF;

    SELECT COUNT(*) INTO existing_count FROM ROOM_TYPES
        WHERE ROOM_TYPE_NAME = p_room_type_name AND ROOM_TYPE_CAPACITY=p_room_type_capacity;
    IF existing_count > 0 THEN
        RAISE_APPLICATION_ERROR(-20005, 'Тип комнаты с таким именем уже существует.');
    END IF;
--   -- Проверка, что описание типа комнаты не превышает 200 символов
--   IF LENGTH(p_room_type_description) > 200 THEN
--     RAISE_APPLICATION_ERROR(-20004, 'Длина описания типа комнаты не может превышать 200 символов.');
--   END IF;

  -- Вставка данных в таблицу ROOM_TYPES
  INSERT INTO ROOM_TYPES (room_type_name, room_type_capacity, room_type_daily_price, room_type_description)
  VALUES (p_room_type_name, p_room_type_capacity, p_room_type_daily_price, p_room_type_description);
  COMMIT;

  DBMS_OUTPUT.PUT_LINE('Тип комнаты успешно создан.');
EXCEPTION
  WHEN OTHERS THEN
    -- Обработка других ошибок
    DBMS_OUTPUT.PUT_LINE('Ошибка: ' || SQLERRM);
    ROLLBACK;
END CreateRoomType;


--изменить тип комнаты
CREATE OR REPLACE PROCEDURE Update_Room_type(
  p_room_type_id         NUMBER,
  p_new_room_type_name        NVARCHAR2,
  p_new_room_type_capacity    NUMBER,
  p_new_room_type_daily_price FLOAT,
  p_new_room_type_description NVARCHAR2
) AS
  existing_count NUMBER;

BEGIN

  -- Проверка, что тип комнаты существует
    SELECT COUNT(*) INTO existing_count FROM ROOM_TYPES
        WHERE room_type_id = p_room_type_id;
    IF existing_count = 0 THEN
        RAISE_APPLICATION_ERROR(-20001, 'Тип комнаты с указанным ID не существует.');
    END IF;

    SELECT COUNT(*) INTO existing_count FROM ROOM_TYPES
        WHERE ROOM_TYPE_NAME = p_new_room_type_name AND ROOM_TYPE_CAPACITY=p_new_room_type_capacity;
    IF existing_count > 0 THEN
        RAISE_APPLICATION_ERROR(-20005, 'Тип комнаты с таким именем уже существует.');
    END IF;

  -- Проверка, что новое имя типа комнаты не является NULL или пустым
    IF p_new_room_type_name IS NULL OR p_new_room_type_name = '' THEN
        RAISE_APPLICATION_ERROR(-20002, 'Новое имя типа комнаты не может быть NULL или пустым.');
    END IF;

  -- Проверка, что новая вместимость типа комнаты больше 0
    IF p_new_room_type_capacity <= 0 THEN
        RAISE_APPLICATION_ERROR(-20003, 'Новая вместимость типа комнаты должна быть больше 0.');
    END IF;

  -- Проверка, что новая ежедневная цена типа комнаты больше 0
  IF p_new_room_type_daily_price <= 0 THEN
    RAISE_APPLICATION_ERROR(-20004, 'Новая ежедневная цена типа комнаты должна быть больше 0.');
  END IF;

  -- Проверка, что новое описание типа комнаты не превышает 200 символов
  IF LENGTH(p_new_room_type_description) > 200 THEN
    RAISE_APPLICATION_ERROR(-20005, 'Длина нового описания типа комнаты не может превышать 200 символов.');
  END IF;

  -- Обновление данных типа комнаты
  UPDATE ROOM_TYPES
  SET
    room_type_name = p_new_room_type_name,
    room_type_capacity = p_new_room_type_capacity,
    room_type_daily_price = p_new_room_type_daily_price,
    room_type_description = p_new_room_type_description
  WHERE room_type_id = p_room_type_id;

  -- Фиксация изменений
  COMMIT;

  DBMS_OUTPUT.PUT_LINE('Тип комнаты успешно обновлен.');
EXCEPTION
  WHEN OTHERS THEN
    -- Обработка других ошибок
    DBMS_OUTPUT.PUT_LINE('Ошибка: ' || SQLERRM);
    ROLLBACK;
END Update_Room_type;

--удалить тип комнаты

----------------------------------------------------------------
--создать тип тарифа
CREATE OR REPLACE PROCEDURE AddTariffType(
  p_tariff_type_name        NVARCHAR2,
  p_tariff_type_description NVARCHAR2,
  p_tariff_type_daily_price FLOAT
) AS
  v_existing_count NUMBER;

BEGIN
  -- Проверка, что имя тарифа не является NULL или пустым
  IF p_tariff_type_name IS NULL OR p_tariff_type_name = '' THEN
    RAISE_APPLICATION_ERROR(-20001, 'Имя тарифа не может быть NULL или пустым.');
  END IF;

  -- Проверка, что ежедневная цена тарифа больше 0
  IF p_tariff_type_daily_price <= 0 THEN
    RAISE_APPLICATION_ERROR(-20002, 'Ежедневная цена тарифа должна быть больше 0.');
  END IF;

  -- Проверка, что описание тарифа не превышает 200 символов
  IF LENGTH(p_tariff_type_description) > 200 THEN
    RAISE_APPLICATION_ERROR(-20003, 'Длина описания тарифа не может превышать 200 символов.');
  END IF;

  -- Проверка наличия такого же тарифа
  SELECT COUNT(*) INTO v_existing_count
  FROM TARIFF_TYPES
  WHERE tariff_type_name = p_tariff_type_name;

  IF v_existing_count > 0 THEN
    RAISE_APPLICATION_ERROR(-20004, 'Тариф с таким именем уже существует.');
  END IF;

  -- Вставка данных в таблицу TARIFF_TYPES
  INSERT INTO TARIFF_TYPES (tariff_type_name, tariff_type_description, tariff_type_daily_price)
  VALUES (p_tariff_type_name, p_tariff_type_description, p_tariff_type_daily_price);

  -- Фиксация изменений
  COMMIT;

  DBMS_OUTPUT.PUT_LINE('Тариф успешно добавлен.');
EXCEPTION
  WHEN OTHERS THEN
    -- Обработка других ошибок
    DBMS_OUTPUT.PUT_LINE('Ошибка: ' || SQLERRM);
    ROLLBACK;
END AddTariffType;
/

--изменить тип тарифа
CREATE OR REPLACE PROCEDURE UpdateTariffType(
  p_tariff_type_id          NUMBER,
  p_new_tariff_type_name    NVARCHAR2,
  p_new_tariff_type_description NVARCHAR2,
  p_new_tariff_type_daily_price FLOAT
) AS
  v_existing_count NUMBER;

BEGIN
  -- Проверка, что тариф существует
  SELECT COUNT(*) INTO v_existing_count
  FROM TARIFF_TYPES
  WHERE tariff_type_id = p_tariff_type_id;

  IF v_existing_count = 0 THEN
    RAISE_APPLICATION_ERROR(-20001, 'Тариф с указанным ID не существует.');
  END IF;

  -- Проверка, что новое имя тарифа не является NULL или пустым
  IF p_new_tariff_type_name IS NULL OR p_new_tariff_type_name = '' THEN
    RAISE_APPLICATION_ERROR(-20002, 'Новое имя тарифа не может быть NULL или пустым.');
  END IF;

  -- Проверка, что новая ежедневная цена тарифа больше 0
  IF p_new_tariff_type_daily_price <= 0 THEN
    RAISE_APPLICATION_ERROR(-20003, 'Новая ежедневная цена тарифа должна быть больше 0.');
  END IF;

  -- Проверка, что новое описание тарифа не превышает 200 символов
  IF LENGTH(p_new_tariff_type_description) > 200 THEN
    RAISE_APPLICATION_ERROR(-20004, 'Длина нового описания тарифа не может превышать 200 символов.');
  END IF;

  -- Проверка наличия такого же тарифа
  SELECT COUNT(*) INTO v_existing_count
  FROM TARIFF_TYPES
  WHERE tariff_type_name = p_new_tariff_type_name
    AND tariff_type_id != p_tariff_type_id;

  IF v_existing_count > 0 THEN
    RAISE_APPLICATION_ERROR(-20005, 'Тариф с таким именем уже существует.');
  END IF;

  -- Обновление данных тарифа
  UPDATE TARIFF_TYPES
  SET
    tariff_type_name = p_new_tariff_type_name,
    tariff_type_description = p_new_tariff_type_description,
    tariff_type_daily_price = p_new_tariff_type_daily_price
  WHERE tariff_type_id = p_tariff_type_id;

  -- Фиксация изменений
  COMMIT;

  DBMS_OUTPUT.PUT_LINE('Тариф успешно обновлен.');
EXCEPTION
  WHEN OTHERS THEN
    -- Обработка других ошибок
    DBMS_OUTPUT.PUT_LINE('Ошибка: ' || SQLERRM);
    ROLLBACK;
END UpdateTariffType;
/



--удалить тип тарифа
CREATE OR REPLACE PROCEDURE DeleteTariffType(
  p_tariff_type_id NUMBER
) AS
  v_existing_count NUMBER;

BEGIN
  -- Проверка, что тариф существует
  SELECT COUNT(*) INTO v_existing_count
  FROM TARIFF_TYPES
  WHERE tariff_type_id = p_tariff_type_id;

  IF v_existing_count = 0 THEN
    RAISE_APPLICATION_ERROR(-20001, 'Тариф с указанным ID не существует.');
  END IF;

  -- Удаление тарифа
  DELETE FROM TARIFF_TYPES
  WHERE tariff_type_id = p_tariff_type_id;

  -- Фиксация изменений
  COMMIT;

  DBMS_OUTPUT.PUT_LINE('Тариф успешно удален.');
EXCEPTION
  WHEN OTHERS THEN
    -- Обработка других ошибок
    DBMS_OUTPUT.PUT_LINE('Ошибка: ' || SQLERRM);
    ROLLBACK;
END DeleteTariffType;
/


----------------------------------------------------------------
--создать тип сервиса
--изменить тип сервиса
--удалить тип сервиса

----------------------------------------------------------------
--создать галерею фото
CREATE OR REPLACE PROCEDURE Add_Photo(
  p_photo_room_type_id NUMBER,
  p_photo_source       BLOB
    )
IS
    --photo_count NUMBER;
BEGIN
--     SELECT COUNT(*) INTO photo_count FROM PHOTO WHERE PHOTO_ID = p_photo_id;
--     IF (photo_count > 0) THEN
--             RAISE_APPLICATION_ERROR(-20061, 'Фото с таким ID уже существует');
--     END IF;

INSERT INTO photo(photo_room_type_id, photo_source)
    VALUES (p_photo_room_type_id, p_photo_source);
END Add_Photo;

--изменить галерею фото
CREATE OR REPLACE PROCEDURE Update_Photo(
  p_photo_id          NUMBER,
  p_new_photo_source  BLOB
) IS
  photo_count NUMBER;

BEGIN
  SELECT COUNT(*) INTO photo_count FROM photo WHERE photo_id = p_photo_id;

  IF photo_count = 0 THEN
    RAISE_APPLICATION_ERROR(-20001, 'Фотография с указанным ID не существует.');
  END IF;

  UPDATE photo SET photo_source = p_new_photo_source
  WHERE photo_id = p_photo_id;
  COMMIT;

--   DBMS_OUTPUT.PUT_LINE('Фотография успешно обновлена.');
-- EXCEPTION
--   WHEN OTHERS THEN
--     -- Обработка других ошибок
--     DBMS_OUTPUT.PUT_LINE('Ошибка: ' || SQLERRM);
--     ROLLBACK;
END Update_Photo;

--удалить галерею фото
CREATE OR REPLACE PROCEDURE Delete_Photo(
  p_photo_id NUMBER
) IS
  photo_count NUMBER;

BEGIN
  SELECT COUNT(*) INTO photo_count FROM photo WHERE photo_id = p_photo_id;

  IF photo_count = 0 THEN
    RAISE_APPLICATION_ERROR(-20001, 'Фотография с указанным ID не существует.');
  END IF;

  DELETE FROM photo
  WHERE photo_id = p_photo_id;
  COMMIT;
  --DBMS_OUTPUT.PUT_LINE('Фотография успешно удалена.');
EXCEPTION
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('Ошибка: ' || SQLERRM);
    ROLLBACK;
END Delete_Photo;

----------------------------------------------------------------
--создать комнату
--изменить комнату
--удалить комнату

----------------------------------------------------------------
--создать тариф
--изменить тариф
--удалить тариф

----------------------------------------------------------------
--создать сервис
--изменить сервис
--удалить сервис

----------------------------------------------------------------
--создать роль
--изменить роль
--удалить роль

----------------------------------------------------------------
--создать пользователя
--изменить пользователя
--удалить пользователя











END HotelAdminPackage;
--/