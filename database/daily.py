import sqlite3
import pandas as pd
import os

DB_NAME = "conference.db"

def export_daily_schedules(conn):
    """
    Queries for each day of the conference and exports the sessions for that day
    to a corresponding CSV file.
    """
    print("Querying for conference days and exporting daily schedules...")
    try:
        # 1. Query for all unique days
        days_df = pd.read_sql_query("SELECT dia FROM sessions GROUP BY dia", conn)
        days = days_df['dia'].tolist()
        print(f"Found {len(days)} conference day(s): {days}")

        # 2. Use the list to query for sessions each day and save to CSV
        for day in days:
            daily_sessions_df = pd.read_sql_query(
                "SELECT * FROM sessions WHERE dia = ? AND ocupados > 0 ORDER BY inicia ASC", conn, params=(day,)
            )
            file_name = f"{day}.csv"
            daily_sessions_df.to_csv(file_name, index=False)
            print(f"  - Successfully exported sessions for {day} to {file_name}")
        print("Daily schedule export complete.\n")
    except Exception as e:
        print(f"An error occurred while exporting daily schedules: {e}")


def export_presentations_by_session(conn):
    """
    Queries for each session session and exports the presentations for that session
    to a corresponding CSV file.
    """
    print("Querying for session sessions and exporting presentations...")
    try:
        # 3. Query for all unique session sessions
        sessions_df = pd.read_sql_query("SELECT bloque FROM sessions GROUP BY bloque", conn)
        sessions = sessions_df['bloque'].tolist()
        print(f"Found {len(sessions)} unique session session(s).")

        # 4. Use the list to query for presentations in each session and save to CSV
        for session in sessions:
            presentations_df = pd.read_sql_query(
                "SELECT * FROM presentations WHERE bloque = ? ORDER BY turno ASC", conn, params=(session,)
            )
            if not presentations_df.empty:
                file_name = f"{session}.csv"
                presentations_df.to_csv(file_name, index=False)
                print(f"  - Successfully exported presentations for {session} to {file_name}")
            else:
                print(f"  - No presentations found for {session}")
        print("Presentation export complete.\n")
    except Exception as e:
        print(f"An error occurred while exporting presentations by session: {e}")


def main():
    """Main function to orchestrate the data exporting process."""
    if not os.path.exists(DB_NAME):
        print(f"Error: Database file '{DB_NAME}' not found.")
        print("Please run 'database.py' first to create and populate the database.")
        return

    conn = None
    try:
        # Establish a single database connection
        conn = sqlite3.connect(DB_NAME)

        # Run the export functions
        export_daily_schedules(conn)
        export_presentations_by_session(conn)
        print("Process finished successfully!")

    except sqlite3.Error as e:
        print(f"Database error: {e}")
    finally:
        if conn:
            conn.close()

if __name__ == '__main__':
    main()

