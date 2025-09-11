import os
import subprocess
import sys
from datetime import datetime


def write_time_to_cut():
    now = datetime.now().isoformat()
    with open(".cut", "w", encoding="utf-8") as f:
        f.write(now)


def run_command(command, cwd=None):
    """
    A helper function to run a command in a subprocess, stream its output,
    and exit if the command fails.
    """
    # Use sys.executable to ensure we're using the Python interpreter
    # from the currently active virtual environment.
    if command[0] == "python":
        command[0] = sys.executable

    print(f"\n[RUNNING] {' '.join(command)} in '{cwd or os.getcwd()}'")
    try:
        # Using check=True will raise an exception on non-zero exit codes.
        subprocess.run(command, cwd=cwd, check=True, text=True)
    except FileNotFoundError:
        print(f"Error: Command '{command[0]}' not found.", file=sys.stderr)
        print(
            "Please ensure it is installed and accessible in your PATH.",
            file=sys.stderr,
        )
        sys.exit(1)
    except subprocess.CalledProcessError as e:
        print(f"Error executing command: {' '.join(command)}", file=sys.stderr)
        print(f"Return code: {e.returncode}", file=sys.stderr)
        sys.exit(1)
    except Exception as e:
        print(f"An unexpected error occurred: {e}", file=sys.stderr)
        sys.exit(1)


def main():
    """Main function to orchestrate the build process."""
    # Assume this script is in the project root directory.
    write_time_to_cut()
    project_root = os.path.dirname(os.path.abspath(__file__))
    database_dir = os.path.join(project_root, "database")
    output_dir = os.path.join(project_root, "output")
    typst_input_file = os.path.join(project_root, "program_preview.typ")
    typst_output_file = os.path.join(output_dir, "program_preview.pdf")

    # --- Step 1 & 2: Run database and daily scripts ---
    # These commands will be run from within the 'database' directory.
    print("--- Initializing database and exporting CSVs ---")
    run_command(["python", "database.py"], cwd=database_dir)
    run_command(["python", "daily.py"], cwd=database_dir)

    # --- Step 3: Create the output directory ---
    print("\n--- Preparing output directory ---")
    os.makedirs(output_dir, exist_ok=True)
    print(f"Output directory '{output_dir}' is ready.")

    # --- Step 4: Compile the Typst document ---
    print("\n--- Compiling Typst document ---")
    run_command(["typst", "compile", typst_input_file, typst_output_file])

    print(f"\nPreview build completed!")
    print(f"PDF generated at: {typst_output_file}")


if __name__ == "__main__":
    main()
