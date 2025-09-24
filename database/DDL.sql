--- SQLite
DROP TABLE IF EXISTS presentations;
DROP TABLE IF EXISTS sessions;
DROP TABLE IF EXISTS people;

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
);

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
);

CREATE TABLE people (
    fullname TEXT PRIMARY KEY,
    pronouns TEXT,
    lang TEXT,
    resume TEXT,
    picture TEXT,
    picture_source TEXT,
    website TEXT,
    email TEXT,
    linkedin TEXT,
    twitter TEXT,
    bluesky TEXT,
    facebook TEXT,
    instagram TEXT,
    youtube TEXT,
    tiktok TEXT,
    git TEXT
);
