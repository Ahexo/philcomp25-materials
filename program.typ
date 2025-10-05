#import "icphilcomp25.typ": icphilcomp25, schedule, timetable, resumes, abstracts, separator
#show: icphilcomp25.with(
  titulo: "Conference program",
  subtitulo: "Programa",
  updates_url: "https://drive.google.com/file/d/1P6Q7BNf8e_h03Z9nysydlVLi31Dheahy/view?usp=sharing",
  edition: 1,
  partners: (
    (
      logo: "assets/partners/fciencias.svg",
      adaptive: true,
    ),
    (
      logo: "assets/partners/agile_design_studio.svg",
      adaptive: false,
    ),
    (
      logo: "assets/partners/sectei.svg",
      adaptive: true,
    ),
    (
      logo: "assets/partners/licenciaturacc.svg",
      adaptive: true,
    ),
    (
      logo: "assets/partners/philcomp.svg",
      adaptive: true,
    ),
  )
)

// English translations
#show "Presentación oral (30 min. + 10 min. preguntas)": [Oral presentation (max 30 min. + 10 min. Q&A)]
#show "Introducción por el host": [Introduction by the host]
#show "Presentaciones de libros": [Book presentations]
#show "Introducción por el host": [Introduction by the host]
#show "Presentaciones de libros": [Book presentations]

// Inicio
= Bienvenidos a ICPHILCOMP'25
_Welcome to ICPHILCOMP'25_
\
#grid(
  columns: (14em, 1fr),
  gutter: 24pt,
  text(size: 8pt)[],
  text(size: 8pt)[
  *Entidades co-organizadoras (Co-organizing entities)*
   - Universidad Nacional Autónoma de México
   - Grupo de Investigación en Filosofía de la Computación
   - Facultad de Ciencias, UNAM
   - Licenciatura en Ciencias de la Computación, Facultad de Ciencias, UNAM
   - Secretaría de Educación, Ciencia, Tecnología e Innovación del Gobierno de la Ciudad de México

  *Comité Directivo (Steering Committee)*
   - Enrique F. Soto-Astorga (Facultad de Ciencias, UNAM), _Presidente_.
   - Karla Ramírez-Pulido (Facultad de Ciencias, UNAM)
   - Lourdes del Carmen González Huesca (Facultad de Ciencias, UNAM)
   - Francisco Vergara Silva (Instituto de Biología de la UNAM)

  *Comité Organizador (Organizing Committee)*
   - Enrique F. Soto-Astorga (Facultad de Ciencias, UNAM), _Presidente_.
   - Lucía Aumann Aso (DAUIC, Universidad Iberoamericana)
   - Alejandro Javier Solares-Rojas (ICC, Universidad de Buenos Aires)
   - Miguel Ángel Andrade Velázquez (Facultad de Ciencias, UNAM)
   - Leonardo Abigail Castro Sánchez (Facultad de Derecho, UNAM)
   - Alejandro Axel Rodríguez Sánchez (Facultad de Ciencias, UNAM)
   - Sergio Mejía Caballero (Facultad de Ciencias, UNAM)
   - Laura Itzel Rodríguez Dimayuga (Facultad de Ciencias, UNAM)
   - Sara Barrios Rangel (DCSH, UAM-Cuajimalpa)

  *Comité de Programa (Program Committee)*
   - Ana María Medeles-Hernández (IIMAS, UNAM), _Presidenta_.
   - Miguel Ángel Andrade Velázquez (Facultad de Ciencias, UNAM)
   - Karen González-Fernández (Universidad Panamericana)
   - Lourdes del Carmen González-Huesca (Facultad de Ciencias, UNAM)
   - Marien Raat (Universidad de Leiden)
   - Alfonso Arroyo Santos (Facultad de Filosofía y Letras, UNAM)
   - José Antonio Neme Castillo (IIMAS, UNAM)
   - Melina Gastelum-Vargas (Facultad de Filosofía y Letras, UNAM)
   - Volodymyr Dziubinskyy (AgileEngine, LLC.)
   - Hugo I. Cruz-Rosas (Facultad de Ciencias, UNAM)
   - Annabel Castro-Meagher (Universidad de Monterrey)
   - Karla Ramírez-Pulido (Facultad de Ciencias, UNAM)
   - María Virginia Bon-Pereira (Universidad de Monterrey)
   - Rafael Reyes Sánchez (Facultad de Ciencias, UNAM)

  *Edición, diseño y composición tipográfica (Edition, design and typesetting)*
   - Alejandro Axel Rodríguez Sánchez (Facultad de Ciencias, UNAM). _Diseñador y editor_.
   - Lucía Aumann Aso (DAUIC, Universidad Iberoamericana), _Editora_.
   - Sara Barrios Rangel (DCSH, UAM-Cuajimalpa), _Editora_.
  ]
)

#schedule(1, datetime(year:2025, month: 10, day: 27), "database/2025-10-27.csv", start_time: "8:30")
#pagebreak()

#schedule(2, datetime(year:2025, month: 10, day: 28), "database/2025-10-28.csv")
#pagebreak()

#schedule(3, datetime(year:2025, month: 10, day: 29), "database/2025-10-29.csv")
#pagebreak()

#schedule(4, datetime(year:2025, month: 10, day: 30), "database/2025-10-30.csv")
#pagebreak()

#schedule(5, datetime(year:2025, month: 10, day: 31), "database/2025-10-31.csv")

#abstracts("database/keynote_abstracts.csv", title:"Keynote abstracts")

#abstracts("database/available_abstracts.csv", title: "Presentation abstracts", subtitle: "In alphabetical order")

#separator(title: "Participant Directory")

#resumes("Comité directivo (Steering Committee)", [], "database/steering_resumes.csv")

#resumes("Comité organizador (Organizing Committee)", [Conoce a los responsables de esta edición de nuestra conferencia.\ Meet the people in charge of this edition of our conference.], "database/staff_resumes.csv")

#resumes("Participantes (Speakers)", [Conoce a los ponentes y participantes varios de esta edición:\ Meet the speakers and various participants of this edition:#footnote("Esta está en orden alfababético y no es exhaustiva: Dependiendo la disponibilidad de sus datos, puede que algunos ponentes no estén incluidos en ella.\nThis list is in alphabetical order and is not exhaustive: Depending on the availability of their data, some speakers may not be included.")], "database/resumes.csv")
