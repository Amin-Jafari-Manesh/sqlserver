import logging
from datetime import datetime
from os import environ
import pyodbc

logging.basicConfig(level=logging.INFO)

db_config = {
    'PASS': environ.get('PASS', ''),
    'DOMAIN': environ.get('DOMAIN', ''),
    'HASH_SIZE': int(environ.get('HASH_SIZE', '')),
    'RECORDS': int(environ.get('RECORDS', '')),
}


def generate_random_hash(numb: int = 1) -> str:
    import random
    import string
    import hashlib
    if numb == 1:
        return hashlib.sha256(''.join(random.choices(string.ascii_letters + string.digits, k=64)).encode()).hexdigest()
    else:
        return ''.join(
            [hashlib.sha256(''.join(random.choices(string.ascii_letters + string.digits, k=64)).encode()).hexdigest()
             for _ in range(numb)])


def test_mssql_connection():
    try:
        conn = pyodbc.connect(
            'DRIVER={ODBC Driver 17 for SQL Server};'
            f'SERVER={db_config["DOMAIN"]};'
            'UID=sa;'
            f'PWD={db_config["PASS"]};'
        )
        logging.info("Successfully connected to SQL Server.")
        cur = conn.cursor()
        cur.execute("CREATE DATABASE test;")
        conn.commit()

        cur.execute("USE test;")
        cur.execute("CREATE TABLE hashes (id INT IDENTITY(1,1) PRIMARY KEY, hash varchar(MAX), created_at DATETIME);")
        conn.commit()

        conn.close()
        return True
    except Exception as e:
        logging.error(f"SQL Server connection failed: {e}")
        return False


def mssql_write_hash(size: int = 100) -> bool:
    if test_mssql_connection():
        conn = pyodbc.connect(
            'DRIVER={ODBC Driver 17 for SQL Server};'
            f'SERVER={db_config["DOMAIN"]};'
            'UID=sa;'
            f'PWD={db_config["PASS"]};'
        )
        cur = conn.cursor()
        cur.execute("USE test;")
        for _ in range(size):
            cur.execute(
                f"INSERT INTO hashes (hash, created_at) VALUES ('{generate_random_hash(db_config['HASH_SIZE'])}', '{datetime.now()}')")
        conn.commit()
        conn.close()
        return True
    return False


if __name__ == '__main__':
    if mssql_write_hash(db_config['RECORDS']):
        logging.info("Hashes successfully written to the database.")
    else:
        logging.error("Failed to write hashes to the database.")
