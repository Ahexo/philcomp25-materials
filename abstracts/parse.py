import PyPDF2
import argparse
import os


def convert_pdf_to_txt(pdf_path):
    """
    Extracts text from a PDF file and saves it as a TXT file.

    Args:
        pdf_path (str): The full path to the input PDF file.
    """
    # --- Input Validation ---
    if not os.path.exists(pdf_path):
        print(f"Error: The file '{pdf_path}' was not found.")
        return
    if not pdf_path.lower().endswith(".pdf"):
        print(f"Error: The file '{pdf_path}' is not a PDF file.")
        return

    try:
        print(f"Processing '{pdf_path}'...")
        # --- File Processing ---
        # Open the PDF file in binary read mode
        with open(pdf_path, "rb") as pdf_file:
            # Create a PDF reader object
            pdf_reader = PyPDF2.PdfReader(pdf_file)
            # Initialize an empty string to store the text
            full_text = ""
            # Loop through all the pages and extract text
            for page_num, page in enumerate(pdf_reader.pages):
                # The extract_text() method can sometimes return None
                page_text = page.extract_text()
                if page_text:
                    full_text += page_text + "\n"
                print(f"  - Reading page {page_num + 1}/{len(pdf_reader.pages)}")

        # --- Output Generation ---
        # Determine the output filename by replacing .pdf with .txt
        output_txt_path = os.path.splitext(pdf_path)[0] + ".txt"
        # Write the extracted text to the new .txt file
        with open(output_txt_path, "w", encoding="utf-8") as txt_file:
            txt_file.write(full_text)
        print(f"\nSuccess! Content has been saved to '{output_txt_path}'")

    except PyPDF2.errors.PdfReadError:
        print(
            f"Error: Could not read the PDF file '{pdf_path}'. It might be corrupted or encrypted."
        )
    except Exception as e:
        print(f"An unexpected error occurred: {e}")


if __name__ == "__main__":
    # --- Command-Line Argument Parsing ---
    parser = argparse.ArgumentParser(
        description="A Python script to convert the content of a PDF file to a TXT file."
    )
    parser.add_argument(
        "pdf_file", help="The path to the PDF file you want to convert."
    )
    args = parser.parse_args()
    # Call the conversion function with the provided file path
    convert_pdf_to_txt(args.pdf_file)
