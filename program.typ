#import "icphilcomp25.typ": icphilcomp25, schedule, timetable, resumes, abstracts, separator
#show: icphilcomp25.with(
  titulo: "Conference program",
  subtitulo: "Programa",
  updates_url: "https://drive.google.com/file/d/1P6Q7BNf8e_h03Z9nysydlVLi31Dheahy/view?usp=sharing",
  edition: 2,
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

// Horarios
#schedule(1, datetime(year:2025, month: 10, day: 27), "database/2025-10-27.csv", start_time: "8:30", show_timetable: true)
#pagebreak()
#schedule(2, datetime(year:2025, month: 10, day: 28), "database/2025-10-28.csv", show_timetable: true)
#pagebreak()
#schedule(3, datetime(year:2025, month: 10, day: 29), "database/2025-10-29.csv", show_timetable: true)
#pagebreak()
#schedule(4, datetime(year:2025, month: 10, day: 30), "database/2025-10-30.csv", show_timetable: true)
#pagebreak()
#schedule(5, datetime(year:2025, month: 10, day: 31), "database/2025-10-31.csv", show_timetable: true)

// Abstracts
#abstracts("database/keynote_abstracts.csv", title:"Keynote abstracts")
#abstracts("database/available_abstracts.csv", title: "Presentation abstracts", subtitle: "In alphabetical order")

// Semblanzas
#separator(title: "Participant Directory")
#resumes("Conferencistas Magistrales (Keynote Speakers)", [Conoce a nuestros ponentes magistrales invitados para esta conferencia.\ Meet our guest keynote speakers for this conference.], "database/keynote_resumes.csv")
#resumes("Comité directivo (Steering Committee)", [], "database/steering_resumes.csv")
#resumes("Comité organizador (Organizing Committee)", [Conoce a los responsables de esta edición de nuestra conferencia.\ Meet the people in charge of this edition of our conference.], "database/staff_resumes.csv")
#resumes("Participantes (Speakers)", [Conoce a los ponentes y participantes varios de esta edición:\ Meet the speakers and various participants of this edition:#footnote("Esta está en orden alfababético y no es exhaustiva: Dependiendo la disponibilidad de sus datos, puede que algunos ponentes no estén incluidos en ella.\nThis list is in alphabetical order and is not exhaustive: Depending on the availability of their data, some speakers may not be included.")], "database/resumes.csv")
