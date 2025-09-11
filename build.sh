source .venv/bin/activate
cd database
python database.py
python daily.py
cd ..
mkdir output
typst compile program_preview.typ ./output/program_preview.pdf

