import os
import sqlite3
import pandas as pd
import requests
from dotenv import load_dotenv

DB_NAME = "conference.db"
PRESENTATIONS_CSV = "presentations.csv"
SESSIONS_CSV = "sessions.csv"


def download_file(url, local_filename):
    """Downloads a file from a URL and saves it locally."""
    print(f"Downloading {local_filename} from {url}...")
    try:
        with requests.get(url, stream=True) as r:
            r.raise_for_status()
            with open(local_filename, "wb") as f:
                for chunk in r.iter_content(chunk_size=8192):
                    f.write(chunk)
        print(f"Successfully downloaded {local_filename}.")
        return True
    except requests.exceptions.RequestException as e:
        print(f"Error downloading {url}: {e}")
        return False


def create_database_and_tables(db_name):
    """Creates the SQLite database and the necessary tables with relationships."""
    print(f"Creating database and tables in '{db_name}'...")
    conn = sqlite3.connect(db_name)
    cursor = conn.cursor()

    # Drop tables if they exist to ensure a fresh start
    cursor.execute("DROP TABLE IF EXISTS presentations")
    cursor.execute("DROP TABLE IF EXISTS sessions")

    # Create sessions table
    # 'bloque' is the primary key that links presentations to a session.
    cursor.execute("""
        CREATE TABLE sessions (
            bloque TEXT PRIMARY KEY,
            dia TEXT,
            inicia TEXT,
            termina TEXT,
            sala TEXT,
            horario TEXT,
            duracion INTEGER,
            turnos INTEGER,
            ocupados INTEGER,
            garantia INTEGER,
            delay INTEGER,
            tolerancia INTEGER,
            advertencias TEXT,
            nombre TEXT,
            tematica TEXT,
            notas TEXT,
            host TEXT
        )
    """)

    # Create presentations table
    # The FOREIGN KEY constraint links each presentation to a specific session block.
    cursor.execute("""
        CREATE TABLE presentations (
            id INTEGER PRIMARY KEY,
            titulo TEXT,
            atraccion INTEGER,
            formato TEXT,
            timeframe INTEGER,
            eje TEXT,
            autores TEXT,
            integrantes INTEGER,
            afiliacion TEXT,
            pais TEXT,
            notas TEXT,
            bloque TEXT,
            tematica TEXT,
            turno INTEGER,
            FOREIGN KEY (bloque) REFERENCES sessions (bloque)
        )
    """)

    conn.commit()
    conn.close()
    print("Database and tables created successfully.")


def populate_tables(db_name, presentations_df, sessions_df):
    """Populates the database tables from pandas DataFrames."""
    print("Populating tables with data from CSV files...")
    conn = sqlite3.connect(db_name)
    try:
        # Use pandas `to_sql` to efficiently insert data.
        # 'append' adds the data to our pre-defined tables.
        sessions_df.to_sql("sessions", conn, if_exists="append", index=False)
        presentations_df.to_sql("presentations", conn, if_exists="append", index=False)
        print("Tables populated successfully.")
    except Exception as e:
        print(f"An error occurred while populating tables: {e}")
    finally:
        conn.close()


def main():
    """Main function to orchestrate the database creation process."""
    # Load environment variables from a .env file
    load_dotenv()
    URL_PRESENTATIONS = os.getenv("URL_PRESENTATIONS")
    URL_SESSIONS = os.getenv("URL_SESSIONS")

    if not URL_PRESENTATIONS or not URL_SESSIONS:
        print("Error: Please set URL_PRESENTATIONS and URL_SESSIONS in your .env file.")
        return

    # 1. Download the files
    presentations_downloaded = download_file(URL_PRESENTATIONS, PRESENTATIONS_CSV)
    sessions_downloaded = download_file(URL_SESSIONS, SESSIONS_CSV)

    if not (presentations_downloaded and sessions_downloaded):
        print("Could not download necessary files. Aborting.")
        return

    # 2. Create the database and table structures
    create_database_and_tables(DB_NAME)

    # 3. Load CSV data into pandas DataFrames
    print("Reading CSV files into memory...")
    presentations_df = pd.read_csv(PRESENTATIONS_CSV)
    sessions_df = pd.read_csv(SESSIONS_CSV)

    # 4. Populate the database with the data
    populate_tables(DB_NAME, presentations_df, sessions_df)

    print("\nProcess complete! Your database 'conference.db' is ready.")


if __name__ == "__main__":
    main()
