--- SQLite
DROP TABLE IF EXISTS presentations;
DROP TABLE IF EXISTS sessions;
DROP TABLE IF EXISTS people;
DROP TABLE IF EXISTS casting;

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
    nombre_en TEXT,
    tematica TEXT,
    notas TEXT,
    host TEXT,
    streaming TEXT
);

CREATE TABLE presentations (
    id INTEGER PRIMARY KEY,
    titulo TEXT,
    atraccion INTEGER,
    lang TEXT,
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
);

CREATE TABLE people (
    fullname TEXT,
    normalname TEXT PRIMARY KEY,
    affiliation TEXT,
    pronouns TEXT,
    lang TEXT,
    resume TEXT,
    pfp TEXT,
    website TEXT,
    public_email TEXT,
    linkedin TEXT,
    twitter TEXT,
    bluesky TEXT,
    facebook TEXT,
    instagram TEXT,
    youtube TEXT,
    tiktok TEXT,
    git TEXT,
    staff INTEGER,
    organization INTEGER
);

CREATE TABLE abstracts (
    id INTEGER REFERENCES presentations (id),
    title TEXT,
    authors TEXT,
    abstract TEXT,
    topic TEXT,
    keywords TEXT
);

CREATE TABLE casting (
    id REFERENCES presentations (id),
    person REFERENCES people (normalname)
);
