import csv
import re
from pathlib import Path


BASE_DIR = Path(__file__).resolve().parent
DATA_DIR = BASE_DIR
SQL_FILE = BASE_DIR / "db_init.sql"


def sql_string(value):
    if value is None:
        return "NULL"
    value = str(value).replace("'", "''")
    return f"'{value}'"


def read_csv_file(filename):
    with open(DATA_DIR / filename, "r", encoding="utf-8", newline="") as file:
        yield from csv.DictReader(file)


def read_users():
    with open(DATA_DIR / "users.txt", "r", encoding="utf-8") as file:
        for line in file:
            parts = line.rstrip("\n").split("|")
            if len(parts) == 6:
                yield parts


def movie_data(title):
    match = re.search(r"\((\d{4})\)\s*$", title)
    if match:
        year = int(match.group(1))
        clean_title = title[:match.start()].rstrip()
    else:
        year = None
        clean_title = title

    return clean_title, year


def generate_sql():
    with open(SQL_FILE, "w", encoding="utf-8", newline="\n") as sql:
        sql.write("PRAGMA foreign_keys = OFF;\n\n")

        sql.write("DROP TABLE IF EXISTS movies;\n")
        sql.write("DROP TABLE IF EXISTS ratings;\n")
        sql.write("DROP TABLE IF EXISTS tags;\n")
        sql.write("DROP TABLE IF EXISTS users;\n\n")

        sql.write("""CREATE TABLE movies (
    id INTEGER PRIMARY KEY,
    title VARCHAR(158),
    year INTEGER,
    genres VARCHAR(77)
);

""")

        sql.write("""CREATE TABLE ratings (
    id INTEGER PRIMARY KEY,
    user_id INTEGER,
    movie_id INTEGER,
    rating DECIMAL(3,1),
    timestamp INTEGER
);

""")

        sql.write("""CREATE TABLE tags (
    id INTEGER PRIMARY KEY,
    user_id INTEGER,
    movie_id INTEGER,
    tag VARCHAR(85),
    timestamp INTEGER
);

""")

        sql.write("""CREATE TABLE users (
    id INTEGER PRIMARY KEY,
    name VARCHAR(22),
    email VARCHAR(32),
    gender VARCHAR(6),
    register_date DATE,
    occupation VARCHAR(13)
);

""")

        sql.write("BEGIN TRANSACTION;\n\n")

        for row in read_csv_file("movies.csv"):
            title, year = movie_data(row["title"])
            genres = row["genres"]
            sql.write(
                "INSERT INTO movies (id, title, year, genres) VALUES "
                f"({int(row['movieId'])}, {sql_string(title)}, "
                f"{year if year is not None else 'NULL'}, {sql_string(genres)});\n"
            )

        for index, row in enumerate(read_csv_file("ratings.csv"), start=1):
            sql.write(
                "INSERT INTO ratings "
                "(id, user_id, movie_id, rating, timestamp) VALUES "
                f"({index}, {int(row['userId'])}, {int(row['movieId'])}, "
                f"{row['rating']}, {int(row['timestamp'])});\n"
            )

        for index, row in enumerate(read_csv_file("tags.csv"), start=1):
            sql.write(
                "INSERT INTO tags "
                "(id, user_id, movie_id, tag, timestamp) VALUES "
                f"({index}, {int(row['userId'])}, {int(row['movieId'])}, "
                f"{sql_string(row['tag'])}, {int(row['timestamp'])});\n"
            )

        for row in read_users():
            user_id, name, email, gender, register_date, occupation = row
            sql.write(
                "INSERT INTO users "
                "(id, name, email, gender, register_date, occupation) VALUES "
                f"({int(user_id)}, {sql_string(name)}, {sql_string(email)}, "
                f"{sql_string(gender)}, {sql_string(register_date)}, "
                f"{sql_string(occupation)});\n"
            )

        sql.write("\nCOMMIT;\n")


if __name__ == "__main__":
    generate_sql()
    print(f"SQL script created: {SQL_FILE}")
