-- Создаем пространство 
CREATE DATABASE client_general();
-- Переходим в созданное пространство marketplace
USE marketplace; 

-- Создадим таблицу client_general, укажем столбцы и их типы данных
CREATE TABLE client_general 
(client_id INT, 
surname VARCHAR(20),
name VARCHAR(20), 
phone_number VARCHAR(11), 
email VARCHAR(30)
);

-- Вставляем тестовые значения в таблицу client_general
INSERT INTO client_general VALUES 
(786453, "Иванов", "Виктор", "89563452861", "ivanov_viktor@mail.ru"), 
(672406, "Петров", "Антон", "89783457820", "petrov1977@mail.ru"),
(783410, "Львова", "Анна", "89253881207", "livova_ann09@gmail.com"),
(147727, "Куницын", "Петр", "89375195620", "kunicin_petya00@mail.ru"), 
(672345, "Борисова", "Ольга", "89138679246", "olga_borisova2000@mail.ru");

-- Вставим столбец с отчествами клиентов
ALTER TABLE client_general ADD COLUMN paternal_name VARCHAR(20);

-- Заполним пропуски в новом столбце paternal_name
UPDATE client_general 
SET paternal_name="Александрович"
WHERE client_id=786453;

UPDATE client_general 
SET paternal_name="Михайлович"
WHERE client_id=672406;

UPDATE client_general 
SET paternal_name="Ивановна"
WHERE client_id=783410;

UPDATE client_general 
SET paternal_name="Петрович"
WHERE client_id=147727;

UPDATE client_general 
SET paternal_name="Алексеевна"
WHERE client_id=672345;

-- Выведем полученные значения
SELECT * FROM client_general;

-- Удалим столбец email
ALTER TABLE client_general DROP COLUMN email;
SELECT * FROM client_general;

-- Переименуем столбец phone_number в "Номер"
ALTER TABLE client_general RENAME COLUMN phone_number TO Номер; 
SELECT * FROM client_general;

-- Создадим таблицу по последнему купленному товару, определим столбцы и типы данных
CREATE TABLE last_good 
(client_id INT, 
good_id INT,
good_name VARCHAR(20), 
good_group_id INT, 
price INT
);

-- Вставим в таблицу данные
INSERT INTO last_good VALUES 
(786453, 67534, "Микроволновка", 34, 15500), 
(672406, 89756, "Чехол для телефона", 45, 1500),
(783410, 45234, "Дрип пакеты", 89, 1000),
(147727, 35667, "Чашка", 22, 800), 
(672345, 12310, "Носки", 12, 390);

-- Выведем все значения из таблицы, чтобы убедиться, что все данные корректно вставлены
SELECT * FROM last_good; 

-- Создажим таблицу, посвященную категориям товаров
CREATE TABLE good_groups (
group_id INT,
good_group VARCHAR(30)
); 

-- Вставим в таблицу необходимые значения
INSERT INTO good_groups VALUES 
(34, "Бытовая техника"), 
(45, "Аксессуары для телефонов"), 
(89, "Кофе и чай"), 
(22, "Посуда"), 
(12, "Одежда"); 

-- Выведем содержимое таблицы
SELECT * FROM good_groups; 

-- Добавим первичный ключ в таблицу good_groups через функцию ALTER TABLE
ALTER TABLE good_groups
ADD PRIMARY KEY (group_id);

-- Добавим первичный ключ в таблицу client_general через функцию ALTER TABLE
ALTER TABLE client_general
ADD PRIMARY KEY (client_id);

-- Добавим вторичный ключ, связывающий таблицу good_groups с таблицей last_good
ALTER TABLE last_good 
ADD CONSTRAINT fk_good_group_id
FOREIGN KEY (good_group_id) REFERENCES good_groups(group_id);

-- Добавим вторичный ключ, связывающий таблицу client_general с таблицей last_good
ALTER TABLE last_good 
ADD CONSTRAINT fk_client_id
FOREIGN KEY (client_id) REFERENCES client_general(client_id);

-- Удалим строчку из таблицы client_general с определенным номером id у клиента
DELETE FROM client_general
WHERE client_id=786453;
SELECT * FROM client_general;

-- Посчитаем количество мужчин среди покупателей
SELECT COUNT(client_id) FROM client_general
WHERE surname="Иванов" OR surname="Петров" OR surname="Куницын"; 

-- Посчитаем описательные статистики по заказам: минимальная сумма, максимальная, средний чек клиентов в базе
-- размах и стандартное отклонение
SELECT ROUND(MIN(price), 2) AS "Минимальная сумма", 
ROUND(MAX(price), 2) AS "Максимальная сумма", 
ROUND(AVG(price), 2) AS "Средний чек",
ROUND(MAX(price)-MIN(price), 2) AS "Размах", 
ROUND(STDDEV(price), 2) AS "Стандартное отклонение" FROM last_good;

-- Посчитаем, сколько категорий товаров с group_id больше 20 и меньше 40
SELECT COUNT(good_group) FROM good_groups
WHERE group_id > 20 AND group_id < 40;

-- Посчитаем, сколько людей в базе, у которых имена начинаются на букву А
SELECT COUNT(client_id) FROM client_general
WHERE name LIKE "А%";

-- Посчитаем сколько товаров, которые стоят больше 1000 рублей
SELECT COUNT(good_id) FROM last_good
WHERE price > 1000;

