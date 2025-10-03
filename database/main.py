import os
import sqlite3
import pandas as pd
import requests
import unicodedata
from dotenv import load_dotenv
import normalize

HEADERS = {
    "User-Agent": "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36"
}
DB_NAME = "database/conference.db"
PHOTOS_DIR = "database/photos/"
CSV_OUTPUT_DIR = "database"
PRESENTATIONS_CSV = "database/presentations.csv"
SESSIONS_CSV = "database/sessions.csv"
SPEAKERS_CSV = "database/speakers.csv"
ABSTRACTS_CSV = "database/abstracts.csv"
pd.options.mode.copy_on_write = True

def download_file(url: str, local_filename: str) -> bool:
    '''
    Downloads a file from a URL and saves it locally.

    Args:
        url: File source.
        local_filename: Where and how to name it.
    Returns:
        bool: True is successful, False if errors occured.
    '''
    print(f"Downloading {local_filename} from {url}...")
    try:
        # Add the headers to your request
        with requests.get(url, stream=True, headers=HEADERS) as r:
            r.raise_for_status()
            with open(local_filename, "wb") as f:
                for chunk in r.iter_content(chunk_size=8192):
                    f.write(chunk)
            print(f"Successfully downloaded {local_filename}.")
            return True
    except requests.exceptions.RequestException as e:
        print(f"Error downloading {url}: {e}")
        return False


def setup_photos_database(name_and_pfp: pd.core.frame.DataFrame):
    '''
    Downloads and procceses all of the profile photos for the speakers and staff.
    Args:
        name_and_pfp: A dataframe with two columns, first for names and second for source urls.
    '''
    for entry in name_and_pfp.itertuples():
        # We always assume a Google Drive download, so we can guarantee the id starts from the 33th char on.
        pfp_id = entry.pfp[33:]
        print(f"proccesing {entry.normalname}, {pfp_id}")
        if not os.path.exists(f"{PHOTOS_DIR}{entry.normalname}.png"):
            download_file(
                f"https://drive.google.com/uc?export=download&id={pfp_id}",
                f"{PHOTOS_DIR}{entry.normalname}.png")


def setup_database(process_photos=False) -> bool:
    '''
    Downloads CSVs and builds the SQLite database.

    Args:
        process_photos: Download and proccess photos or not
    Returns:
        bool: True is successful, False if errors occured.
    '''
    print("--- Starting Database Setup ---")
    load_dotenv()
    URL_PRESENTATIONS = os.getenv("URL_PRESENTATIONS")
    URL_SESSIONS = os.getenv("URL_SESSIONS")
    URL_SPEAKERS = os.getenv("URL_SPEAKERS")
    URL_ABSTRACTS = os.getenv("URL_ABSTRACTS")

    if not all([URL_PRESENTATIONS, URL_SESSIONS, URL_SPEAKERS, URL_ABSTRACTS]):
        print("Error: Sources must be set in the .env file.")
        return False

    try:
        presentations_downloaded = download_file(URL_PRESENTATIONS, PRESENTATIONS_CSV)
        sessions_downloaded = download_file(URL_SESSIONS, SESSIONS_CSV)
        speakers_downloaded = download_file(URL_SPEAKERS, SPEAKERS_CSV)
        abstracts_downloaded = download_file(URL_ABSTRACTS, ABSTRACTS_CSV)

        if not (
            presentations_downloaded and sessions_downloaded and speakers_downloaded and abstracts_downloaded
        ):
            print("Could not download necessary files. Aborting.")
            return

        print("Loading data into pandas DataFrames...")

        # Load presentations, pretty straightforward
        presentations_df = pd.read_csv(PRESENTATIONS_CSV)
        # We don't need these
        presentations_df = presentations_df.drop(columns=["atraccion", "pais", "notas"], axis=1)

        # Load sessions, we need to zip authors and affiliations later
        sessions_df = pd.read_csv(SESSIONS_CSV)
        # We don't need these
        sessions_df = sessions_df.drop(columns=["advertencias"], axis=1)

        # Load speakers, these need some special treatment
        speakers_df = pd.read_csv(SPEAKERS_CSV)
        # We don't need these
        speakers_df = speakers_df.drop(columns=["Marca temporal", "email"], axis=1)
        # We will use this plenty to name photo files and so on
        normalnames = speakers_df["fullname"]
        speakers_df["normalname"] = normalnames.apply(normalize.fullname)
        # Sigh, sometimes people won't hear basic instructions...
        speakers_df["linkedin"] = speakers_df["linkedin"].apply(normalize.user)
        speakers_df["instagram"] = speakers_df["instagram"].apply(normalize.user)
        speakers_df["twitter"] = speakers_df["twitter"].apply(normalize.user)
        speakers_df["youtube"] = speakers_df["youtube"].apply(normalize.user)
        speakers_df["tiktok"] = speakers_df["tiktok"].apply(normalize.user)
        speakers_df["git"] = speakers_df["git"].apply(normalize.user)

        # Finally, we download abstracts.
        abstracts_df = pd.read_csv(ABSTRACTS_CSV)

        # Downloading and naming photos use to take time, we do it only on demmand
        if process_photos:
            pfps = speakers_df[["normalname", "pfp"]]
            setup_photos_database(pfps)

        # Let's build a fresh database to populate
        print(f"Creating SQLite database at '{DB_NAME}'...")
        if os.path.exists(DB_NAME):
            os.remove(DB_NAME)
        conn = sqlite3.connect(DB_NAME)
        cursor = conn.cursor()
        ddl = open("database/DDL.sql", "r").read()
        cursor.executescript(ddl)

        print("Creating tables and loading data...")

        # Presentations one needs some special treatment since we have to split authors and affiliations
        # and load them into the people database afterwards:
        for index, row in presentations_df.iterrows():
            if isinstance(row["autores"], str) and isinstance(row["afiliacion"], str):
                authors = row["autores"].split(" | ")
                affiliations = row["afiliacion"].strip('"').split(" | ") if row["afiliacion"] else [""]

                # Ensure both lists have the same length
                max_length = max(len(authors), len(affiliations))
                authors.extend([""] * (max_length - len(authors)))  # Fill with empty strings if needed
                affiliations.extend(affiliations * (max_length - len(affiliations)))  # Fill with empty strings if needed

                # Normal names are the keys of people entries
                normalnames = list(map(normalize.fullname, authors))

                # Insert each author-affiliation pair into the database, and associate them with their presentations
                for normalname, author, affiliation in zip(normalnames, authors, affiliations):
                    cursor.execute("INSERT OR IGNORE INTO people (normalname, fullname, affiliation) VALUES (?, ?, ?)", (normalname, author.strip(), affiliation.strip()))
                    cursor.execute("INSERT OR IGNORE INTO casting (id, person) VALUES (?, ?)", (row["id"], normalname) )


        presentations_df.to_sql("presentations", conn, if_exists="append", index=False)

        sessions_df.to_sql("sessions", conn, if_exists="append", index=False)

        #speakers_df.to_sql("people", conn, if_exists="append", index=False)
        for index, row in speakers_df.iterrows():
            to_input = [
                row['fullname'].strip(),
                row['normalname'],
                row['pronouns'],
                row['lang'],
                row['resume'].strip(),
                row['linkedin'],
                row['twitter'],
                row['bluesky'],
                row['facebook'],
                row['website'],
                row['public_email'],
                row['youtube'],
                row['instagram'],
                row['tiktok'],
                row['git'],
                row['staff']]

            cursor.execute('SELECT COUNT(*) FROM people WHERE normalname = ?', (to_input[1],))
            exists = cursor.fetchone()[0]

            if exists:
                # Update the existing record, keeping the affiliation
                # First, we have to relocate the normalname
                argss = to_input.copy()
                argss.append(to_input[1])
                del argss[1]

                cursor.execute('''
                UPDATE people
                SET fullname = ?, pronouns  = ?, lang = ?, resume = ?, linkedin = ?, twitter = ?, bluesky = ?, facebook = ?, website = ?, public_email = ? , youtube = ?, instagram = ?, tiktok = ?, git=?, staff = ?
                WHERE normalname = ?
                ''', argss)
            else:
                # Insert a new record
                cursor.execute('''
                INSERT OR REPLACE INTO people (fullname,normalname,pronouns,lang,resume,linkedin,twitter,bluesky,facebook,website,public_email,youtube,instagram,tiktok,git, staff)
                VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
                ''', to_input)

        abstracts_df.to_sql("abstracts", conn, if_exists="append", index=False)

        conn.close()
        print("Database setup complete.")
        return True
    except requests.exceptions.RequestException as e:
        print(f"Error downloading data: {e}")
        return False
    except Exception as e:
        print(f"An error occurred during database setup: {e}")
        return False


def export_csvs() -> bool:
    '''
    Queries the database and exports daily and session CSVs.

    Returns:
        bool: True is successful, False if errors occured.
    '''
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

        # Export resumes
        steering_resumes_df = pd.read_sql_query(
            """
            SELECT fullname, normalname, affiliation, pronouns, resume, website, public_email, linkedin, twitter, bluesky, facebook, instagram, youtube, tiktok, git, staff
            FROM people
            WHERE
            staff = "2"
            AND resume IS NOT NULL
            ORDER BY normalname ASC;
            """,
            conn,
        )
        steering_resumes_df.to_csv(
            os.path.join(CSV_OUTPUT_DIR, f"steering_resumes.csv"),
            index=False,
            encoding="utf-8",
        )

        staff_resumes_df = pd.read_sql_query(
            """
            SELECT fullname, normalname, affiliation, pronouns, resume, website, public_email, linkedin, twitter, bluesky, facebook, instagram, youtube, tiktok, git, staff
            FROM people
            WHERE
            staff = "1"
            AND resume IS NOT NULL
            ORDER BY normalname ASC;
            """,
            conn,
        )
        staff_resumes_df.to_csv(
            os.path.join(CSV_OUTPUT_DIR, f"staff_resumes.csv"),
            index=False,
            encoding="utf-8",
        )

        resumes_df = pd.read_sql_query(
            """
            SELECT fullname, normalname, affiliation, pronouns, resume, website, public_email, linkedin, twitter, bluesky, facebook, instagram, youtube, tiktok, git, staff
            FROM people
            WHERE
            EXISTS (SELECT person FROM casting WHERE normalname = person)
            AND resume IS NOT NULL
            AND staff IS NULL
            ORDER BY normalname ASC;
            """,
            conn,
        )
        resumes_df.to_csv(
            os.path.join(CSV_OUTPUT_DIR, f"resumes.csv"),
            index=False,
            encoding="utf-8",
        )

        print(f"Exported CSVs for resumes.")

        print("CSV export complete.")
        return True

    except sqlite3.Error as e:
        print(f"Database error during CSV export: {e}")
        return False
    finally:
        if conn:
            conn.close()


def main(proccess_photos=False):
    if setup_database(proccess_photos):
        export_csvs()


if __name__ == "__main__":
    main()
