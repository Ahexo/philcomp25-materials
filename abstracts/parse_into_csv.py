import re
import csv

PATTERN = r"^Page\s+\d+\s*([\s\S]+?)Authors:\s*([\s\S]+?)Topic:\s*([\s\S]*?)Keywords:\s*([\s\S]*?)Abstract:\s+([A-Z][\s\S]*?)(?=^Page|\Z)"
MULTISPACES = r"(\s){2,}"


pattern = re.compile(PATTERN, re.MULTILINE)
source = open("abstracts.txt", "rt").read()
matches = pattern.findall(source)

parsed_abstracts = []

for match in matches:
    title = match[0].strip().replace("\n", " ")

    authors = match[1].strip().replace("\n", " ")

    topic = match[2].strip().replace("\n", " ")

    keywords = match[3].strip().replace("\n", " ")
    keywords = keywords.replace(";", ",")
    keywords = keywords.replace(" •", ",")


    abstract = match[4].strip().replace("\n", " ")
    abstract = re.sub(r'\s+', ' ', abstract)

    parsed_abstracts.append({
        "title": title,
        "authors": authors,
        "topic": topic,
        "keywords": keywords,
        "abstract": abstract
    })

with open("abstracts.csv", mode='w', newline='', encoding='utf-8') as file:
    writer = csv.DictWriter(file, fieldnames=parsed_abstracts[0].keys())
    writer.writeheader()
    writer.writerows(parsed_abstracts)
