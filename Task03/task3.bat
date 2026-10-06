#!/bin/bash
chcp 65001

sqlite3 movies_rating.db < db_init.sql

echo "1. Составить список фильмов, имеющих хотя бы одну оценку. Список фильмов отсортировать по году выпуска и по названиям. В списке оставить первые 10 фильмов."
echo --------------------------------------------------
sqlite3 movies_rating.db -box -echo "SELECT DISTINCT m.id, m.title, m.year FROM movies AS m JOIN ratings AS r ON r.movie_id = m.id ORDER BY m.year, m.title LIMIT 10;"
echo " "

echo "2. Вывести список всех пользователей, фамилии (не имена!) которых начинаются на букву 'A'. Полученный список отсортировать по дате регистрации. В списке оставить первых 5 пользователей."
echo --------------------------------------------------
sqlite3 movies_rating.db -box -echo "SELECT id, substr(name, instr(name, ' ') + 1) AS surname, register_date FROM users WHERE substr(name, instr(name, ' ') + 1) LIKE 'A%' ORDER BY register_date LIMIT 5;"
echo " "

echo "3. Информация о рейтингах в читаемом формате: имя и фамилия эксперта, название фильма, год выпуска, оценка и дата оценки."
echo --------------------------------------------------
sqlite3 movies_rating.db -box -echo "SELECT u.name AS expert, m.title AS movie, m.year, r.rating, date(r.timestamp, 'unixepoch') AS rating_date FROM ratings AS r JOIN users AS u ON u.id = r.user_id JOIN movies AS m ON m.id = r.movie_id ORDER BY u.name, m.title, r.rating LIMIT 50;"
echo " "

echo "4. Список фильмов с указанием тегов, которые были им присвоены пользователями."
echo --------------------------------------------------
sqlite3 movies_rating.db -box -echo "SELECT m.title, m.year, t.tag FROM tags AS t JOIN movies AS m ON m.id = t.movie_id ORDER BY m.year, m.title, t.tag LIMIT 40;"
echo " "

echo "5. Список самых свежих фильмов."
echo --------------------------------------------------
sqlite3 movies_rating.db -box -echo "SELECT id, title, year FROM movies WHERE year = (SELECT MAX(year) FROM movies) ORDER BY title;"
echo " "

echo "6. Драмы, выпущенные после 2005 года, которые понравились женщинам с оценкой не ниже 4.5."
echo --------------------------------------------------
sqlite3 movies_rating.db -box -echo "SELECT m.title, m.year, COUNT(*) AS ratings_count FROM ratings AS r JOIN users AS u ON u.id = r.user_id JOIN movies AS m ON m.id = r.movie_id WHERE u.gender = 'female' AND r.rating >= 4.5 AND m.year > 2005 AND instr('|' || m.genres || '|', '|Drama|') > 0 GROUP BY m.id, m.title, m.year ORDER BY m.year, m.title;"
echo " "

echo "7. Количество пользователей, зарегистрировавшихся на сайте в каждом году."
echo --------------------------------------------------
sqlite3 movies_rating.db -box -echo "SELECT strftime('%Y', register_date) AS registration_year, COUNT(*) AS users_count FROM users GROUP BY registration_year ORDER BY registration_year;"
echo " "

echo "Годы с максимальным и минимальным количеством регистраций:"
sqlite3 movies_rating.db -box -echo "WITH yearly AS (SELECT strftime('%Y', register_date) AS registration_year, COUNT(*) AS users_count FROM users GROUP BY registration_year) SELECT 'maximum' AS type, registration_year, users_count FROM yearly WHERE users_count = (SELECT MAX(users_count) FROM yearly) UNION ALL SELECT 'minimum', registration_year, users_count FROM yearly WHERE users_count = (SELECT MIN(users_count) FROM yearly);"