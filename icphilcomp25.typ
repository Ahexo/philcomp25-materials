// Metadata
#let main_color = rgb("#291F3A")
#let ac_color = rgb("#CC97E2")
#let accent_color = rgb("#773898")
#let reduced_ac_color = rgb(
    ac_color.components().at(0),
    ac_color.components().at(1),
    ac_color.components().at(2),
    40)

#let icphilcomp25(
  titulo: str,
  edition: 1,
  fecha: datetime.today(),
  abstract: [],
  doc,
) = {

set document(
  title: titulo,
  author: "PHILCOMP",
  description: abstract,
  date: fecha,
)

set page(
  paper: "us-letter",
  header: context [
    #set align(left)
    #set text(fill: gray)
  ],
  footer: context [
    #set align(right)
    #set text(fill: gray)
    #h(1fr)
    #if counter(page).get().first() > 0 [
      #counter(page).display("1", both: false)
    ]
  ]
)

set text(
  size: 12pt,
  font: "Inter",
  lang: "en"
)

show heading: set text(fill: accent_color)

let portada() = align(left + top)[
  #set page(
    background:
      rect(
        fill: main_color,
        width: 100%,
        height: 100%
      ),
    footer: [],
    header: []
  )
  #set text(
    fill: ac_color
  )
  #v(50%)
  #text(size: 28pt, fill: ac_color, weight: "bold")[#titulo]\
  #image("assets/banner-vertical-en-color.svg", width: 50%)
  #v(1fr)
  Last updated: #fecha.display(), Revision #edition
]
portada()
pagebreak()
doc
}

#let chip(color: ac_color, content) = {
  box(
    width: auto,
    inset: 0.3em,
    fill: color,
    radius: 5pt,
    text(fill: black, size: 8pt,[#content]))
  linebreak()
}

#let schedule(path) = {
  let sessions = csv(path, row-type: dictionary)
  for session in sessions {
    pad(top: 10pt,
    box(
      width: 100%,
      stroke: ac_color,
      fill: reduced_ac_color,
      inset: 0.7em,
      text(size: 10pt)[

      #text(size:12pt, weight: "bold", fill: accent_color)[
        #if session.bloque.first() != "X" {
          [== Bloque #session.bloque: #session.tematica]
          text(size: 12pt, fill: black, weight: "regular")[#if session.nombre != "" [#session.nombre #linebreak()]]
        } else {[== #session.nombre]}

      ]
      #box(image("assets/door.svg",height: 0.8em,)) #session.sala #h(5pt)#box(image("assets/clock.svg",height: 0.8em,)) #session.inicia - #session.termina (#session.duracion min.)
      #if session.host != "" [#h(5pt) #box(image("assets/user.svg",height: 0.8em,)) #session.host]\
      ]
    ))

    let presentations = csv("database/" + session.bloque + ".csv", row-type: dictionary)

    // These are used to compute the timeframes between presentations
    let timesplit = session.inicia.split(regex("[:]"))
    let starting_time = datetime(hour: int(timesplit.at(0)),minute: int(timesplit.at(1)),second:0)
    let runtime = starting_time

    // Does this session needs an intro?
    if int(session.delay) > 0 {
      grid(
          columns: (auto, 1fr),
          rows: (auto),
          gutter: 4pt,
          [#box(width: auto, inset: 0.5em, fill: reduced_ac_color, text(fill: accent_color)[*#runtime.display("[hour]:[minute]")*])],
          [#box(width: auto, inset: 0.5em, [*Presentación*])]
      )
      runtime = runtime + duration(minutes: int(session.delay))
    }

    for presentation in presentations {
      grid(
        columns: (auto, 1fr),
        rows: (auto),
        gutter: 4pt,
        [#box(width: auto, inset: 0.5em, fill: reduced_ac_color, text(fill: accent_color)[*#runtime.display("[hour]:[minute]")*])],
        [
          #chip([#presentation.formato])
          *#presentation.titulo*\
          #presentation.autores\ #text(size:10pt, fill: accent_color)[#presentation.afiliacion]
          #linebreak()
        ]
      )
     // The unavoidable pass of time...
     let timespan = duration(minutes: int(presentation.timeframe))
     runtime = runtime + timespan
    }
  }
  pagebreak()
}

#let timetable(path) = {
  let sessions = csv(path, row-type: dictionary)
  let columnas = ("",)
  for session in sessions {
    if not columnas.contains(session.sala) {columnas.push(session.sala)}
  }
  table(
  columns: (1fr,) * columnas.len(),
  inset: 10pt,
  align: horizon,
  ..columnas
)
  pagebreak()
}
