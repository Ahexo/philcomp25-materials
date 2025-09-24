import os
import sqlite3
import pandas as pd
import requests
from dotenv import load_dotenv

DB_NAME = "database/conference.db"
CSV_OUTPUT_DIR = "database"
PRESENTATIONS_CSV = "database/presentations.csv"
SESSIONS_CSV = "database/sessions.csv"
SPEAKERS_CSV = "database/speakers.csv"


def download_file(url: str, local_filename: str):
    """
    Downloads a file from a URL and saves it locally.

    Args:
        url: File source.
        local_filename: Where and how to name it.
    """
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


def setup_database():
    """
    Downloads CSVs and builds the SQLite database.
    """
    print("--- Starting Database Setup ---")
    load_dotenv()
    URL_PRESENTATIONS = os.getenv("URL_PRESENTATIONS")
    URL_SESSIONS = os.getenv("URL_SESSIONS")
    URL_SPEAKERS = os.getenv("URL_SPEAKERS")

    if not all([URL_PRESENTATIONS, URL_SESSIONS, URL_SPEAKERS]):
        print("Error: Sources must be set in the .env file.")
        return False

    try:
        presentations_downloaded = download_file(URL_PRESENTATIONS, PRESENTATIONS_CSV)
        sessions_downloaded = download_file(URL_SESSIONS, SESSIONS_CSV)
        speakers_downloaded = download_file(URL_SPEAKERS, SPEAKERS_CSV)

        if not (
            presentations_downloaded and sessions_downloaded and speakers_downloaded
        ):
            print("Could not download necessary files. Aborting.")
            return

        print("Loading data into pandas DataFrames...")
        presentations_df = pd.read_csv(PRESENTATIONS_CSV)
        sessions_df = pd.read_csv(SESSIONS_CSV)
        speakers_df = pd.read_csv(SPEAKERS_CSV)

        print(f"Creating SQLite database at '{DB_NAME}'...")
        if os.path.exists(DB_NAME):
            os.remove(DB_NAME)

        conn = sqlite3.connect(DB_NAME)
        cursor = conn.cursor()
        ddl = open("database/DDL.sql", "r").read()
        cursor.executescript(ddl)

        print("Creating tables and loading data...")
        presentations_df.to_sql("presentations", conn, if_exists="replace", index=False)
        sessions_df.to_sql("sessions", conn, if_exists="replace", index=False)

        conn.close()
        print("Database setup complete.")
        return True
    except requests.exceptions.RequestException as e:
        print(f"Error downloading data: {e}")
        return False
    except Exception as e:
        print(f"An error occurred during database setup: {e}")
        return False


def export_csvs():
    """
    Queries the database and exports daily and session CSVs.
    """
    print("\n--- Starting CSV Export ---")
    if not os.path.exists(DB_NAME):
        print(f"Error: Database '{DB_NAME}' not found. Cannot export CSVs.")
        return False

    conn = None
    try:
        conn = sqlite3.connect(DB_NAME)

        # Export daily schedules
        days_df = pd.read_sql_query(
            "SELECT dia FROM sessions GROUP BY dia ORDER BY dia", conn
        )
        for day in days_df["dia"]:
            daily_df = pd.read_sql_query(
                "SELECT * FROM sessions WHERE dia = ? AND ocupados > 0 ORDER BY time(inicia) ASC",
                conn,
                params=(day,),
            )
            daily_df.to_csv(
                os.path.join(CSV_OUTPUT_DIR, f"{day}.csv"),
                index=False,
                encoding="utf-8",
            )
        print(f"Exported {len(days_df)} daily schedule CSVs.")

        # Export presentations by session block
        blocks_df = pd.read_sql_query(
            "SELECT bloque FROM sessions GROUP BY bloque", conn
        )
        for block in blocks_df["bloque"]:
            pres_df = pd.read_sql_query(
                "SELECT * FROM presentations WHERE bloque = ? ORDER BY turno ASC",
                conn,
                params=(block,),
            )
            if not pres_df.empty:
                pres_df.to_csv(
                    os.path.join(CSV_OUTPUT_DIR, f"{block}.csv"),
                    index=False,
                    encoding="utf-8",
                )
        print(f"Exported CSVs for session presentations.")

        print("CSV export complete.")
        return True

    except sqlite3.Error as e:
        print(f"Database error during CSV export: {e}")
        return False
    finally:
        if conn:
            conn.close()


def run():
    if setup_database():
        export_csvs()


if __name__ == "__main__":
    run()
