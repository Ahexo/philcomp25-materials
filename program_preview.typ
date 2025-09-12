#import "icphilcomp25.typ": icphilcomp25, schedule, timetable
#show: icphilcomp25.with(
  titulo: "Sessions calendar",
  edition: 3
)

#show "Inauguración": [Opening]
#show "Presentación oral (30 min. + 10 min. preguntas)": [Oral presentation (max 30 min. + 10 min. Q&A)]
#show "Introducción por el host": [Introduction by our host]
#show "Presentación de libro" : [Book presentation]
#show "Acto inaugural": [Opening speech]
#show "Obra de teatro": [Theatre play]
#show "Mesa redonda": [Round table]
#show "Otros contenidos": [Others]

= Day 1 (Mon, October 27)
#schedule("database/2025-10-27.csv")
#pagebreak()

= Day 2 (Tue, October 28)
#schedule("database/2025-10-28.csv")
#pagebreak()

= Day 3 (Wed, October 29)
#schedule("database/2025-10-29.csv")
#pagebreak()

= Day 4 (Thu, October 30)
#schedule("database/2025-10-30.csv")
#pagebreak()

= Day 6 (Fri, October 31)
#schedule("database/2025-10-31.csv")

