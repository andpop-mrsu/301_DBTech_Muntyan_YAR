
#!/bin/bash
chcp 65001

sqlite3 movies_rating.db < db_init.sql

echo "1. Название фильма, год выпуска, средний рейтинг и ранг фильма среди всех фильмов. Первые 10 фильмов."
echo --------------------------------------------------
sqlite3 movies_rating.db -box -echo "WITH movie_ratings AS (SELECT m.id, m.title, m.year, AVG(r.rating) AS avg_rating FROM movies AS m LEFT JOIN ratings AS r ON r.movie_id = m.id GROUP BY m.id, m.title, m.year), ranked AS (SELECT title, year, avg_rating, RANK() OVER (ORDER BY avg_rating DESC) AS rank_by_avg_rating FROM movie_ratings) SELECT title, year, ROUND(avg_rating, 3) AS avg_rating, rank_by_avg_rating FROM ranked ORDER BY rank_by_avg_rating, title LIMIT 10;"
echo " "

echo "2. Все жанры фильмов, их средний рейтинг и ранг по убыванию среднего рейтинга. Используется рекурсивный CTE."
echo --------------------------------------------------
sqlite3 movies_rating.db -box -echo "WITH RECURSIVE genre_split(movie_id, genre, rest) AS (SELECT id, '', genres || '|' FROM movies WHERE genres IS NOT NULL AND genres <> '' UNION ALL SELECT movie_id, substr(rest, 1, instr(rest, '|') - 1), substr(rest, instr(rest, '|') + 1) FROM genre_split WHERE rest <> '' AND instr(rest, '|') > 0), genre_ratings AS (SELECT gs.genre, AVG(r.rating) AS avg_rating FROM genre_split AS gs JOIN ratings AS r ON r.movie_id = gs.movie_id WHERE gs.genre <> '' AND gs.genre <> '(no genres listed)' GROUP BY gs.genre), ranked AS (SELECT genre, avg_rating, RANK() OVER (ORDER BY avg_rating DESC) AS genre_rank FROM genre_ratings) SELECT genre, ROUND(avg_rating, 3) AS avg_rating, genre_rank FROM ranked ORDER BY genre_rank, genre;"
echo " "

echo "3. Количество фильмов в каждом жанре. Сортировка по убыванию количества фильмов."
echo --------------------------------------------------
sqlite3 movies_rating.db -box -echo "WITH RECURSIVE genre_split(movie_id, genre, rest) AS (SELECT id, '', genres || '|' FROM movies WHERE genres IS NOT NULL AND genres <> '' UNION ALL SELECT movie_id, substr(rest, 1, instr(rest, '|') - 1), substr(rest, instr(rest, '|') + 1) FROM genre_split WHERE rest <> '' AND instr(rest, '|') > 0) SELECT genre, COUNT(DISTINCT movie_id) AS movie_count FROM genre_split WHERE genre <> '' AND genre <> '(no genres listed)' GROUP BY genre ORDER BY movie_count DESC, genre;"
echo " "

echo "4. Количество тегов для каждого жанра и доля жанра в общем количестве тегов в процентах."
echo --------------------------------------------------
sqlite3 movies_rating.db -box -echo "WITH RECURSIVE genre_split(movie_id, genre, rest) AS (SELECT id, '', genres || '|' FROM movies WHERE genres IS NOT NULL AND genres <> '' UNION ALL SELECT movie_id, substr(rest, 1, instr(rest, '|') - 1), substr(rest, instr(rest, '|') + 1) FROM genre_split WHERE rest <> '' AND instr(rest, '|') > 0), genre_movies AS (SELECT DISTINCT movie_id, genre FROM genre_split WHERE genre <> '' AND genre <> '(no genres listed)'), tag_counts AS (SELECT gm.genre, COUNT(t.id) AS tag_count FROM genre_movies AS gm LEFT JOIN tags AS t ON t.movie_id = gm.movie_id GROUP BY gm.genre) SELECT genre, tag_count, ROUND(100.0 * tag_count / (SELECT COUNT(*) FROM tags), 2) AS tag_share FROM tag_counts ORDER BY tag_count DESC, genre;"
echo " "

echo "5. Статистика оценок каждого пользователя: количество, средний рейтинг, дата первой и последней оценки. Первые 10 пользователей."
echo --------------------------------------------------
sqlite3 movies_rating.db -box -echo "SELECT u.id AS user_id, COUNT(r.id) AS rating_count, ROUND(AVG(r.rating), 3) AS avg_rating, date(MIN(r.timestamp), 'unixepoch') AS first_rating_date, date(MAX(r.timestamp), 'unixepoch') AS last_rating_date FROM users AS u LEFT JOIN ratings AS r ON r.user_id = u.id GROUP BY u.id ORDER BY rating_count DESC, u.id LIMIT 10;"
echo " "

echo "6. Сегментация пользователей по поведению: комментаторы, оценщики, активные и пассивные. Используется CASE."
echo --------------------------------------------------
sqlite3 movies_rating.db -box -echo "WITH rating_counts AS (SELECT user_id, COUNT(*) AS rating_count FROM ratings GROUP BY user_id), tag_counts AS (SELECT user_id, COUNT(*) AS tag_count FROM tags GROUP BY user_id), user_activity AS (SELECT u.id AS user_id, COALESCE(r.rating_count, 0) AS rating_count, COALESCE(t.tag_count, 0) AS tag_count FROM users AS u LEFT JOIN rating_counts AS r ON r.user_id = u.id LEFT JOIN tag_counts AS t ON t.user_id = u.id) SELECT user_id, rating_count, tag_count, CASE WHEN rating_count >= 10 AND tag_count >= 10 THEN 'Активные' WHEN rating_count < 5 AND tag_count < 5 THEN 'Пассивные' WHEN tag_count > rating_count THEN 'Комментаторы' WHEN rating_count > tag_count THEN 'Оценщики' ELSE 'Сбалансированные' END AS behavior FROM user_activity ORDER BY user_id;"
echo " "

echo "7. Для каждого пользователя вывести имя и последний оцененный фильм, включая пользователей без оценок."
echo --------------------------------------------------
sqlite3 movies_rating.db -box -echo "WITH ranked_ratings AS (SELECT user_id, movie_id, timestamp, ROW_NUMBER() OVER (PARTITION BY user_id ORDER BY timestamp DESC, id DESC) AS rn FROM ratings) SELECT u.id AS user_id, u.name, m.title AS last_rated_movie_title, rr.timestamp AS last_rating_timestamp FROM users AS u LEFT JOIN ranked_ratings AS rr ON rr.user_id = u.id AND rr.rn = 1 LEFT JOIN movies AS m ON m.id = rr.movie_id ORDER BY u.id;"
echo " "
