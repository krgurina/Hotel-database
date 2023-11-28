--1.
BEGIN
    HotelAdminPackageCRUD.InsertEmployee(
    p_name => 'Кристина',
    p_surname => 'Гурина',
    p_position => 'Менеджер',
    p_email => 'kristina.fjdnvk@example.com',
    p_hire_date => TO_DATE('2023-01-01', 'YYYY-MM-DD'),
    p_birth_date => TO_DATE('1990-01-01', 'YYYY-MM-DD')
  );
END;
/
--1.
BEGIN
    HotelAdminPackageCRUD.INSERTTARIFFTYPE(
      p_tariff_type_name =>'имя тарифа',
      p_tariff_type_description =>'описание',
      p_tariff_type_daily_price =>12.3
  );
END;
/


