
PRAGMA foreign_keys = ON;

BEGIN IMMEDIATE;

-- ==========================================
-- 1. ADD FIVE USERS
-- Registration date is set automatically.
-- User IDs are generated automatically.
-- ==========================================

INSERT INTO users (first_name, last_name, email, gender, occupation_id)
SELECT 'Yaroslav', 'Muntyan', 'yaroslav.muntyan@example.invalid', 'male', occupation_id
FROM occupations
WHERE name = 'student'
AND NOT EXISTS (
    SELECT 1 FROM users
    WHERE email = 'yaroslav.muntyan@example.invalid'
);

INSERT INTO users (first_name, last_name, email, gender, occupation_id)
SELECT 'Vladislav', 'Romanov', 'vladislav.romanov@example.invalid', 'male', occupation_id
FROM occupations
WHERE name = 'student'
AND NOT EXISTS (
    SELECT 1 FROM users
    WHERE email = 'vladislav.romanov@example.invalid'
);

INSERT INTO users (first_name, last_name, email, gender, occupation_id)
SELECT 'Roman', 'Salagaev', 'roman.salagaev@example.invalid', 'male', occupation_id
FROM occupations
WHERE name = 'student'
AND NOT EXISTS (
    SELECT 1 FROM users
    WHERE email = 'roman.salagaev@example.invalid'
);

INSERT INTO users (first_name, last_name, email, gender, occupation_id)
SELECT 'Stanislav', 'Serov', 'stanislav.serov@example.invalid', 'male', occupation_id
FROM occupations
WHERE name = 'student'
AND NOT EXISTS (
    SELECT 1 FROM users
    WHERE email = 'stanislav.serov@example.invalid'
);

INSERT INTO users (first_name, last_name, email, gender, occupation_id)
SELECT 'Alexander', 'Smirnov', 'alexander.smirnov@example.invalid', 'male', occupation_id
FROM occupations
WHERE name = 'student'
AND NOT EXISTS (
    SELECT 1 FROM users
    WHERE email = 'alexander.smirnov@example.invalid'
);


-- ==========================================
-- 2. ADD THREE MOVIES
-- All movies have different genres.
-- Movie IDs are generated automatically.
-- ==========================================

INSERT INTO movies (title, year)
SELECT 'The Aurora Protocol', 2024
WHERE NOT EXISTS (
    SELECT 1 FROM movies
    WHERE title = 'The Aurora Protocol' AND year = 2024
);

INSERT INTO movies (title, year)
SELECT 'Coffee Before Tomorrow', 2023
WHERE NOT EXISTS (
    SELECT 1 FROM movies
    WHERE title = 'Coffee Before Tomorrow' AND year = 2023
);

INSERT INTO movies (title, year)
SELECT 'The Last Orchard', 2022
WHERE NOT EXISTS (
    SELECT 1 FROM movies
    WHERE title = 'The Last Orchard' AND year = 2022
);


-- ==========================================
-- 3. ASSIGN DIFFERENT GENRES TO THE MOVIES
-- ==========================================

INSERT INTO movie_genres (movie_id, genre_id)
SELECT m.id, g.genre_id
FROM movies m
JOIN genres g ON g.name = 'Sci-Fi'
WHERE m.title = 'The Aurora Protocol'
  AND m.year = 2024
  AND NOT EXISTS (
      SELECT 1 FROM movie_genres mg
      WHERE mg.movie_id = m.id
        AND mg.genre_id = g.genre_id
  );

INSERT INTO movie_genres (movie_id, genre_id)
SELECT m.id, g.genre_id
FROM movies m
JOIN genres g ON g.name = 'Comedy'
WHERE m.title = 'Coffee Before Tomorrow'
  AND m.year = 2023
  AND NOT EXISTS (
      SELECT 1 FROM movie_genres mg
      WHERE mg.movie_id = m.id
        AND mg.genre_id = g.genre_id
  );

INSERT INTO movie_genres (movie_id, genre_id)
SELECT m.id, g.genre_id
FROM movies m
JOIN genres g ON g.name = 'Drama'
WHERE m.title = 'The Last Orchard'
  AND m.year = 2022
  AND NOT EXISTS (
      SELECT 1 FROM movie_genres mg
      WHERE mg.movie_id = m.id
        AND mg.genre_id = g.genre_id
  );


-- ==========================================
-- 4. ADD THREE RATINGS FROM YAROSLAV
-- User and movie IDs are obtained automatically.
-- ==========================================

INSERT INTO ratings (user_id, movie_id, rating)
SELECT u.id, m.id, 5.0
FROM users u
CROSS JOIN movies m
WHERE u.email = 'yaroslav.muntyan@example.invalid'
  AND m.title = 'The Aurora Protocol'
  AND m.year = 2024
  AND NOT EXISTS (
      SELECT 1 FROM ratings r
      WHERE r.user_id = u.id AND r.movie_id = m.id
  );

INSERT INTO ratings (user_id, movie_id, rating)
SELECT u.id, m.id, 4.5
FROM users u
CROSS JOIN movies m
WHERE u.email = 'yaroslav.muntyan@example.invalid'
  AND m.title = 'Coffee Before Tomorrow'
  AND m.year = 2023
  AND NOT EXISTS (
      SELECT 1 FROM ratings r
      WHERE r.user_id = u.id AND r.movie_id = m.id
  );

INSERT INTO ratings (user_id, movie_id, rating)
SELECT u.id, m.id, 4.0
FROM users u
CROSS JOIN movies m
WHERE u.email = 'yaroslav.muntyan@example.invalid'
  AND m.title = 'The Last Orchard'
  AND m.year = 2022
  AND NOT EXISTS (
      SELECT 1 FROM ratings r
      WHERE r.user_id = u.id AND r.movie_id = m.id
  );

COMMIT;
