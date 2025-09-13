# PHILCOMP 25 Materials
 - [x] Program preview
 - [ ] EN/ES ver
 
## How to build
1. Set up a virtual environment and install dependencies as usual. UV usage us highly recommended:
```sh
uv venv
uv pip install -r requirements.txt
```
Make sure to install the [Typst compiler](https://github.com/typst/typst) for your system beforehand.

2. Set up the source tables into a `.env` file, these are privately shared on demand:
```
URL_PRESENTATIONS="https://docs.google.com/spreadsheets/d/.../export?format=csv&gid=..."
URL_SESSIONS="https://docs.google.com/spreadsheets/d/.../export?format=csv&gid=..."
URL_SPEAKERS="https://docs.google.com/spreadsheets/d/.../export?format=csv&gid=..."

```

2. Get into your virtual environment and issue ```sh python build.sh```, this automatically download the required data, build a database, query for the needed information in the correct format and compile the documents from the Typst templates.
