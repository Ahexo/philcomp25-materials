#import "icphilcomp25.typ": icphilcomp25, schedule, timetable
#show: icphilcomp25.with(
  titulo: "Sessions calendar",
  updates_url: "https://drive.google.com/file/d/1kR97YspS40mHsdXjjjF-reV81PQmhc1J/view?usp=sharing",
  edition: 3
)

// English translations
#show "Inauguración": [Opening]
#show "Presentación oral (30 min. + 10 min. preguntas)": [Oral presentation (max 30 min. + 10 min. Q&A)]
#show "Introducción por el host": [Introduction by the host]
#show "Presentaciones de libros": [Book presentations]
#show "Presentación de libro" : [Book presentation]
#show "Acto inaugural": [Opening speech]
#show "Obra de Teatro": [Theatre play]
#show "Mesa redonda": [Round table]
#show "Mesa Redonda": [Round Table]
#show "Otros contenidos": [Others]
#show "Clausura y concierto": [Ending]
#show "Concierto y actos de Clausura": [Ending ceremony & concert]


#schedule("Day 1 (Mon, October 27)", "database/2025-10-27.csv")
#pagebreak()

#schedule("Day 2 (Tue, October 28)", "database/2025-10-28.csv")
#pagebreak()

#schedule("Day 3 (Wed, October 29)", "database/2025-10-29.csv")
#pagebreak()

#schedule("Day 4 (Thu, October 30)", "database/2025-10-30.csv")
#pagebreak()

#schedule("Day 6 (Fri, October 31)", "database/2025-10-31.csv")

