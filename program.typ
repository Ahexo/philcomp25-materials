#import "icphilcomp25.typ": icphilcomp25, schedule, timetable, resumes
#show: icphilcomp25.with(
  titulo: "Programa",
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

// Inicio
= Bienvenidos a ICPHILCOMP'25
\
#grid(
  columns: (16em, 1fr),
  gutter: 24pt,
  text(size: 8pt)[],
  text(size: 7pt)[
    *Entidades co-organizadoras*
   - Universidad Nacional Autónoma de México
   - Grupo de Investigación en Filosofía de la Computación
   - Facultad de Ciencias, UNAM
   - Licenciatura en Ciencias de la Computación, Facultad de Ciencias, UNAM
   - Secretaría de Educación, Ciencia, Tecnología e Innovación del Gobierno de la Ciudad de México

    *Comité Directivo*
   - Enrique F. Soto-Astorga (Facultad de Ciencias, UNAM), _presidente_
   - Karla Ramírez-Pulido (Facultad de Ciencias, UNAM)
   - Lourdes del Carmen González Huesca (Facultad de Ciencias, UNAM)
   - Francisco Vergara Silva (Instituto de Biología de la UNAM)

    *Comité Organizador*
   - Enrique F. Soto-Astorga (Facultad de Ciencias, UNAM), _presidente_
   - Lucía Aumann Aso (DAUIC- Universidad Iberoamericana)
   - Alejandro Javier Solares-Rojas (ICC- Universidad de Buenos Aires)
   - Miguel Ángel Andrade Velázquez (Facultad de Ciencias, UNAM) UNAM)
   - Leonardo Abigail Castro Sánchez (Facultad de Derecho, UNAM)
   - Alejandro Axel Rodríguez Sánchez (Facultad de Ciencias, UNAM)
   - Sergio Mejía Caballero (Facultad de Ciencias, UNAM)
   - Laura Itzel Rodríguez Dimayuga (Facultad de Ciencias, UNAM)
   - Sara Barrios Rangel (DCSH, UAM-Cuajimalpa)

    *Comité de Programa*
   - Ana María Medeles-Hernández (IIMAS, UNAM), _presidenta_
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
  ]
)

#schedule("Día 1 (Lunes, Octubre 27)", "database/2025-10-27.csv", start_time: "8:30")
#pagebreak()

#schedule("Día 2 (Martes, Octubre 28)", "database/2025-10-28.csv")
#pagebreak()

#schedule("Día 3 (Miércoles, Octubre 29)", "database/2025-10-29.csv")
#pagebreak()

#schedule("Día 4 (Jueves, Octubre 30)", "database/2025-10-30.csv")
#pagebreak()

#schedule("Día 5 (Viernes, Octubre 31)", "database/2025-10-31.csv")

#resumes("Comité directivo", [], "database/steering_resumes.csv")

#resumes("Comité organizador", [Conoce a los responsables de esta edición de nuestra conferencia.], "database/staff_resumes.csv")

#resumes("Participantes", [Conoce a los ponentes y participantes varios de esta edición:#footnote("Esta lista no es exhaustiva y, dependiendo la disponibilidad de sus datos, puede que algunos ponentes no estén incluidos en ella.")], "database/resumes.csv")
