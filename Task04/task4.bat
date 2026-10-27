#!/bin/bash


sqlite3 movies_rating.db < db_init.sql

echo "1. Найти пары пользователей, оценивших один и тот же фильм. Исключить пары с самими собой и дубликаты. Первые 100 записей."
echo --------------------------------------------------
sqlite3 movies_rating.db -box -echo "SELECT u1.name AS user1, u2.name AS user2, m.title AS movie FROM ratings AS r1 JOIN ratings AS r2 ON r1.movie_id = r2.movie_id AND r1.user_id < r2.user_id JOIN users AS u1 ON u1.id = r1.user_id JOIN users AS u2 ON u2.id = r2.user_id JOIN movies AS m ON m.id = r1.movie_id ORDER BY u1.name, u2.name, m.title LIMIT 100;"
echo " "

echo "2. Найти 10 самых старых оценок от разных пользователей. Вывести фильмы, пользователей, оценки и даты отзывов."
echo --------------------------------------------------
sqlite3 movies_rating.db -box -echo "WITH ranked AS (SELECT r.*, ROW_NUMBER() OVER (PARTITION BY r.user_id ORDER BY r.timestamp) AS rn FROM ratings AS r) SELECT m.title AS movie, u.name AS user, r.rating, date(r.timestamp, 'unixepoch') AS review_date FROM ranked AS r JOIN users AS u ON u.id = r.user_id JOIN movies AS m ON m.id = r.movie_id WHERE r.rn = 1 ORDER BY r.timestamp LIMIT 10;"
echo " "

echo "3. Вывести фильмы с максимальным и минимальным средним рейтингом. Рекомендация: Да или Нет."
echo --------------------------------------------------
sqlite3 movies_rating.db -box -echo "WITH averages AS (SELECT m.id, m.title, m.year, AVG(r.rating) AS avg_rating FROM movies AS m JOIN ratings AS r ON r.movie_id = m.id GROUP BY m.id), extremes AS (SELECT MAX(avg_rating) AS max_rating, MIN(avg_rating) AS min_rating FROM averages) SELECT a.title, a.year, ROUND(a.avg_rating, 3) AS avg_rating, CASE WHEN a.avg_rating = e.max_rating THEN 'Да' ELSE 'Нет' END AS recommend FROM averages AS a CROSS JOIN extremes AS e WHERE a.avg_rating = e.max_rating OR a.avg_rating = e.min_rating ORDER BY a.year, a.title;"
echo " "

echo "4. Количество оценок и средняя оценка, поставленная мужчинами в период с 2011 по 2014 год."
echo --------------------------------------------------
sqlite3 movies_rating.db -box -echo "SELECT COUNT(*) AS ratings_count, ROUND(AVG(r.rating), 3) AS avg_rating FROM ratings AS r JOIN users AS u ON u.id = r.user_id WHERE u.gender = 'male' AND date(r.timestamp, 'unixepoch') >= '2011-01-01' AND date(r.timestamp, 'unixepoch') < '2015-01-01';"
echo " "

echo "5. Список фильмов со средней оценкой и количеством пользователей, оценивших их. Первые 20 записей."
echo --------------------------------------------------
sqlite3 movies_rating.db -box -echo "SELECT m.title, m.year, ROUND(AVG(r.rating), 3) AS avg_rating, COUNT(DISTINCT r.user_id) AS users_count FROM movies AS m JOIN ratings AS r ON r.movie_id = m.id GROUP BY m.id, m.title, m.year ORDER BY m.year, m.title LIMIT 20;"
echo " "

echo "6. Самый распространенный жанр фильма и количество фильмов в этом жанре."
echo --------------------------------------------------
sqlite3 movies_rating.db -box -echo "WITH RECURSIVE genres(movie_id, genre, rest) AS (SELECT id, '', genres || '|' FROM movies WHERE genres IS NOT NULL AND genres <> '' UNION ALL SELECT movie_id, substr(rest, 1, instr(rest, '|') - 1), substr(rest, instr(rest, '|') + 1) FROM genres WHERE rest <> '' AND instr(rest, '|') > 0), counts AS (SELECT genre, COUNT(DISTINCT movie_id) AS movies_count FROM genres WHERE genre <> '' AND genre <> '(no genres listed)' GROUP BY genre) SELECT genre, movies_count FROM counts WHERE movies_count = (SELECT MAX(movies_count) FROM counts) ORDER BY genre;"
echo " "

echo "7. Последние 10 зарегистрированных пользователей в формате Фамилия Имя / Дата регистрации."
echo --------------------------------------------------
sqlite3 movies_rating.db -box -echo "SELECT substr(name, instr(name, ' ') + 1) || ' ' || substr(name, 1, instr(name, ' ') - 1) AS user_name, register_date FROM users ORDER BY register_date DESC, id DESC LIMIT 10;"
echo " "

echo "8. День недели, на который приходится день рождения 3 июля в каждом году."
echo --------------------------------------------------
sqlite3 movies_rating.db -box -echo "WITH RECURSIVE years(y) AS (SELECT 2000 UNION ALL SELECT y + 1 FROM years WHERE y < CAST(strftime('%Y', 'now') AS INTEGER)) SELECT y AS year, date(y || '-07-03') AS birthday, CASE strftime('%w', date(y || '-07-03')) WHEN '0' THEN 'Воскресенье' WHEN '1' THEN 'Понедельник' WHEN '2' THEN 'Вторник' WHEN '3' THEN 'Среда' WHEN '4' THEN 'Четверг' WHEN '5' THEN 'Пятница' WHEN '6' THEN 'Суббота' END AS weekday FROM years ORDER BY y;"
echo " "