CREATE DATABASE text_complexity;
USE text_complexity; 

-- 1. Создание таблиц. Кроме существующих уровней (фонологического, грамматического, лексического)
-- а также количественных метрик, уровень сложности текста можно определять исходя из семантики,
-- в частности темы. Создадим таблицу для семантического уровня текста и заполним ее темами для выборки из текстов
-- Создаем саму таблицу, определяем столбцы и тип данных
CREATE TABLE semantic_level 
(
	text_id INT PRIMARY KEY,
	semantic VARCHAR(15)
);

-- Добавляем значения в таблицу
INSERT INTO semantic_level VALUES 
(5068377, "travelling"), 
(1597194, "home"), 
(6295736, "work"), 
(6993046, "work"), 
(5788279, "studying"), 
(1726484, "travelling"), 
(4967492, "home"), 
(2551007, "studying"); 

-- Выводим полученные значения 
SELECT * FROM semantic_level;

-- Изменим название столбца
ALTER TABLE semantic_level RENAME COLUMN topic TO semantic_topic;
SELECT * FROM semantic_level; 

-- Изменим тип данных в столбце text_id
ALTER TABLE semantic_level MODIFY COLUMN text_id INT;
SELECT * FROM semantic_level
WHERE text_id=1597194;

-- 2. Вставка данных в таблицы. Вставим новый текст в таблицу general_no_texts 
INSERT INTO general_no_texts VALUES (1494, "7345672");
SELECT * FROM general_no_texts 
WHERE text_id="7345672";

-- 3. Обновление данных. Обновим уровень CEFR для уровня C1, заменим его на C2, если значения ttr больше 0.6 и cttr больше 10
-- Выведем количество текстов, уровень языка у которых С1
SELECT COUNT(text_id) FROM lexical_level
WHERE cefr_level="C1"; 

-- Обновим уровень до С2, если ttr больше 0.6 и cttr больше 10
UPDATE lexical_level 
SET cefr_level="C2"
WHERE cefr_level="C1" AND ttr > 0.6 AND cttr > 10;

-- Выведем количество текстов, у которых на данных момент уровень С1 (убедимся, что число уменьшилось)
SELECT COUNT(text_id) FROM lexical_level 
WHERE cefr_level="C1"

-- 4. Удаление данных. Удалим все столбцы с числительными в таблице grammatical_level
ALTER TABLE grammatical_level DROP COLUMN numerals; 
SELECT * FROM grammatical_level LIMIT 5;

-- 5. Выгрузки данных. Посчитаем количество текстов в датасете, уровня В1 и выше, у которых ttr больше 0.6
SELECT COUNT(text_id) AS "Количество текстов" FROM lexical_level
WHERE cefr_level in ("B1", "B2", "C1", "C2") AND ttr > 0.6;

-- Найдем распределение текстов по уровням. Выведем ответ в порядке возрастания
SELECT cefr_level, COUNT(text_id) AS "Распределение текстов по уровням" FROM lexical_level
GROUP BY cefr_level
ORDER BY COUNT(text_id);

-- Выведем количество текстов, в которых индекс FRE больше среднего
SELECT COUNT(text_id) AS "Количество текстов с индексом FRE выше среднего" FROM statistical_level
WHERE fre > (SELECT AVG(fre) FROM statistical_level);

-- Выведем количество текстов, у которых все индексы сложности выше среднего
SELECT COUNT(text_id) AS "Количество текстов, у которых все индексы сложности выше среднего" FROM statistical_level
WHERE fre > (SELECT AVG(fre) FROM statistical_level)
AND gunning_fog_index > (SELECT AVG(gunning_fog_index) FROM statistical_level)
AND smog > (SELECT AVG(smog) FROM statistical_level)
AND ari > (SELECT AVG(ari) FROM statistical_level)
AND spache_formula > (SELECT AVG(spache_formula) FROM statistical_level)
AND smog > (SELECT AVG(smog) FROM statistical_level)
AND dale_chall > (SELECT AVG(dale_chall) FROM statistical_level)
AND powers_sumner_kearl > (SELECT AVG(powers_sumner_kearl) FROM statistical_level)
AND coleman_liau_index > (SELECT AVG(coleman_liau_index) FROM statistical_level)
AND lix > (SELECT AVG(lix) FROM statistical_level)
AND rix > (SELECT AVG(rix) FROM statistical_level);

-- Выведем основные статистические показатели распределения датасета (минимальное, максимальное значения; 
-- среднее арифметическое, размах, стандартное отклонение) по индексу SMOG
SELECT MIN(smog) AS "Минимальное значение SMOG", 
MAX(smog) AS "Максимальное значение SMOG", 
ROUND(AVG(smog), 2) AS "Среднее арифметическое значение SMOG", 
MAX(smog)-MIN(smog) AS "Размах SMOG", 
ROUND(STDDEV(smog), 2) AS "Стандартное отклонение SMOG" FROM statistical_level;

-- JOIN функции с таблицей lexical_level позволят считать различные метрики относительно кластеров уровня сложности языка. 
-- Построим гипотезу: количество трехсложных и четырехсложных слов будет увеличиваться от уровня к уровню
-- Посчитаем распределение среднего количества одно, двух, трех, четырех и многосложных слов по уровням языка в датасете
SELECT cefr_level AS "Уровень CEFR", 
ROUND(AVG(one_syllable_words), 2) AS "Среднее количество односложных слов",
ROUND(AVG(two_syllables_words), 2) AS "Среднее количество двусложных слов",
ROUND(AVG(three_syllables_words), 2) AS "Среднее количество трехсложных слов",
ROUND(AVG(four_syllables_words), 2) AS "Среднее количество четырехсложных слов"
FROM lexical_level INNER JOIN phonological_level ON lexical_level.text_id=phonological_level.text_id
GROUP BY cefr_level
ORDER BY cefr_level;
-- Вывод: cогласно данным количество и односложных, и двусложных, и трехсложных, а также четырехсложных слов 
-- увеличивается с увеличением уровня. Следовательно размер учебного текста также увеличивается с увеличением уровня

-- Посчитаем среднюю номинативность и дескриптивность в рапсределении по уровням языка. 
-- Гипотеза: тексты начального уровня будут более номинативны, а тексты сложных уровней более дескриптивны
SELECT cefr_level AS "Уровень CEFR", 
ROUND(AVG(nominativity), 2) AS "Номинативность", 
ROUND(AVG(descriptivity), 2) AS "Дескриптивность"
FROM lexical_level INNER JOIN grammatical_level ON lexical_level.text_id=grammatical_level.text_id
GROUP BY cefr_level
ORDER BY cefr_level;
-- Вывод: номинативность остается на примерно одном уровне вне зависимости от уровня языка 
-- диапазон от 0.48 до 0.51 без явного тренда на увеличение (или уменьшение). 
-- Однако что касается дескриптивности, то есть тренд на увеличение с увеличением уровня
-- (от 0.14 при уровне А2 до 0.21 при уровне С2)

-- Посчитаем распределение знаменательных частей речи по уровням языка
-- Гипотеза: при увеличении уровня языка будут увеличиваться средние показатели всех частей речи
SELECT cefr_level AS "Уровень языка", 
ROUND(AVG(nouns), 2) AS "Среднее количество существительных", 
ROUND(AVG(adjectives), 2) AS "Среднее количество прилагательных", 
ROUND(AVG(verbs), 2) AS "Среднее количество глаголов", 
ROUND(AVG(adverbs), 2) AS "Среднее количество наречий", 
ROUND(AVG(pronouns), 2) AS "Среднее количество местоимений"
FROM grammatical_level INNER JOIN lexical_level ON grammatical_level.text_id=lexical_level.text_id
GROUP BY cefr_level
ORDER BY cefr_level;
-- Вывод: при увеличении уровня сложности увеличиваются только показатели существительных, прилагательных, глаголов и наречий
-- Однако присутствует небольшой спад по количеству глаголов и наречий при переходе от уровня С1 к С2
-- Также присутствует небольшое преобладание глаголов над сушествительными на начальных уровнях (А1 и А2), 
-- однако при переходе к уровням В и С, наоборот, существительные начинают преобладать над глаголами.
-- Это можно объяснить большим использованием дополнений, обстоятельств (времени, места и т.д.) в предложениях

-- Посчитаем средние значения индексов сложности в распределении по уровням языка
-- Гипотеза: все заявленные метрики будут увеличиваться при увеличении сложности текстов в размеченном датасете
-- за исключением метрик, основанных на словарях spache formula и dale chall, так как данные словари неактуальны 
-- для современных текстов
SELECT cefr_level AS "Уровень языка", 
ROUND(AVG(fre), 2) AS "FRE",
ROUND(AVG(gunning_fog_index), 2) AS "Gunning Fog", 
ROUND(AVG(smog), 2) AS "SMOG", 
ROUND(AVG(ari), 2) AS "ARI", 
ROUND(AVG(spache_formula), 2) AS "Spache Formula", 
ROUND(AVG(dale_chall), 2) AS "Dale Chall", 
ROUND(AVG(powers_sumner_kearl), 2) AS "Powers Sumner Kearl", 
ROUND(AVG(coleman_liau_index), 2) AS "Coleman Liau Index", 
ROUND(AVG(lix), 2) AS "LIX", 
ROUND(AVG(rix), 2) AS "RIX"
FROM lexical_level INNER JOIN statistical_level ON lexical_level.text_id=statistical_level.text_id
GROUP BY cefr_level
ORDER BY cefr_level;
-- Вывод: все метрики показали увеличение тенденции при увеличении уровня языка в текстах датасета 
-- (в том числе и метрики spache formula и dale chall) 

 