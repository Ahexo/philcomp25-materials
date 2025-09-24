// Metadata
#let main_color = rgb("#291F3A")
#let accent_color = rgb("#773898")
#let third_color = rgb("#CC97E2")
#let reduced_third_color = rgb(
    third_color.components().at(0),
    third_color.components().at(1),
    third_color.components().at(2),
    40)

#let icon_external = bytes(read("/assets/external.svg").replace("#000", accent_color.to-hex(),))
#let icon_icphilcomp = bytes(read("/assets/icphilcomp.svg").replace("#000", accent_color.to-hex(),))
#let illust = bytes(read("/assets/tiles/sociedad.svg").replace("#000", third_color.to-hex(),))

/* Se usan para desplegar el formato de la presentación. */
#let chip(color: third_color, content) = {
  box(
    width: auto,
    inset: 0.3em,
    fill: color,
    radius: 5pt,
    text(fill: black, size: 8pt,[#content]))
  linebreak()
}

/* Es una tabla que por defecto va de las 9 a las 19 y despliega las salas y
 * sesiones en orden cronológico */
#let timetable(path) = {
  let sessions = csv(path, row-type: dictionary)
  let start = datetime(hour:9, minute:0, second:0)
  let cursor = start
  let finish = datetime(hour:19, minute:0, second:0)
  let step = duration(minutes:30)

  // Una funcioncita para convertir datetimes a strings de la forma HH:MM
  let disp(timestamp) = {timestamp.display("[hour]:[minute]")}

  // Generar una lista de horarios con steps de media hora entre el inicio y el final
  let timestamps = (start,)
  while cursor < finish {
    cursor = cursor + step
    let frame = cursor
    timestamps.push(frame)
  }

  let columnas = ()
  for session in sessions {
    if not columnas.contains(session.sala) {columnas.push(session.sala)}
  }
  set table.hline(stroke: .6pt)
  table(
    fill: (x, y) =>
    if x == 0 or y == 0 {
      third_color.lighten(40%)
    },
    rows: (1.5fr, (1fr,) * timestamps.len()).flatten(),
    columns: (0.5fr, ((1fr,) * columnas.len())).flatten(),
    align: bottom,
    stroke: none,
    [],
    table.vline(start: 1),
    ..columnas,
    ..timestamps.map(disp),
  )
}

/* La sección completa destinada a una sola jornada de la conferencia. */
#let schedule(title, path, start_time: "9:00", show_timetable: false) = {
  [
    #set page(
      background:
        rect(
          fill: third_color,
          width: 100%,
          height: 100%
        ),
    )
    #set text(fill: accent_color)
    #v(1fr)
    #if show_timetable == true {
      heading(level: 1, [#title])
      timetable(path)
    } else {
      text(24pt)[#heading(level: 1, [#title])]
    }
    Registration and coffee table start at #start_time, open all day.\
    Break from 15:00 to 16:00.
    #v(1fr)
  ]
  set page(
    header: context{
      set text(size: 10pt)
      let current_day = query(selector(heading.where(level: 1)).before(here())).last().body
      box(width: 26pt, height: 22pt)[
        #box(height: 100%)[#align(horizon)[#image(icon_icphilcomp)]]
      ]
      box(width: 1fr, height: 22pt)[
        #box(height: 100%)[#align(horizon)[#text(fill: accent_color, weight: "bold", "ICPHILCOMP25 ") #current_day]]
      ]
      box(width: 22pt, height: 22pt)[
        #if counter(page).get().first() > 0 [
          #align(horizon+center)[#counter(page).display("1", both: false)]
        ]
      ]
    }
  )

  let sessions = csv(path, row-type: dictionary)
  for session in sessions {
    // Session header
    pad(top: 5pt,
    box(
      width: 100%,
      stroke: third_color,
      fill: reduced_third_color,
      inset: 0.7em,
      text(size: 10pt)[

      #text(size:12pt, weight: "bold", fill: accent_color)[
        #if session.bloque.first() != "X" {
          [== Session #session.bloque: #session.tematica]
          text(size: 12pt, fill: black, weight: "regular")[#if session.nombre != "" [#session.nombre]]
        } else {[== #session.nombre]}

      ]
      #box(image("assets/door.svg",height: 0.8em,)) #session.sala #h(5pt)#box(image("assets/clock.svg",height: 0.8em,)) #session.inicia - #session.termina (#session.duracion min.)
      #if session.host != "" [#h(5pt) #box(image("assets/user.svg",height: 0.8em,)) #session.host]
      ]
    ))

    let presentations = csv("database/" + session.bloque + ".csv", row-type: dictionary)

    // These are used to compute the timeframes between presentations
    let start_time_split = session.inicia.split(regex("[:]"))
    let start_time = datetime(hour: int(start_time_split.at(0)),minute: int(start_time_split.at(1)),second:0)
    let runtime = start_time

    // Does this session needs an intro?
    if int(session.delay) > 0 {
      grid(
          columns: (auto, 1fr),
          rows: (auto),
          gutter: 4pt,
          [#box(width: auto, inset: 0.5em, fill: reduced_third_color, text(fill: accent_color)[*#runtime.display("[hour]:[minute]")*])],
          [#box(width: auto, inset: 0.5em, [*Introducción por el host*])]
      )
      runtime = runtime + duration(minutes: int(session.delay))
    }

    // Layout presentations
    for presentation in presentations {
      grid(
        columns: (auto, 1fr),
        rows: (auto),
        gutter: 4pt,
        [#box(width: auto, inset: 0.5em, fill: reduced_third_color, text(fill: accent_color)[*#runtime.display("[hour]:[minute]")*])],
        [
          #chip([#presentation.formato])
          *#presentation.titulo*\
          #if presentation.autores != "" [#presentation.autores\ ]
          #if presentation.afiliacion != "" {
            text(size:10pt, fill: accent_color)[#presentation.afiliacion]
          }
          #linebreak()
        ]
      )
     // The unavoidable pass of time...
     let timespan = duration(minutes: int(presentation.timeframe))
     runtime = runtime + timespan + duration(minutes: 5)
    }
  }
  //pagebreak()
}

#let icphilcomp25(
  titulo: str,
  edition: 1,
  fecha: datetime.today(),
  updates_url: "https://philcomp.org/programa/",
  partners: (),
  doc,
) = {
  set document(
    title: titulo + " - ICPHILCOMP25 @ UNAM CDMX",
    author: "philcomp.org",
    date: fecha,
  )

  set page(
    paper: "a4",
  )

  set text(
    size: 12pt,
    font: "Inter",
    lang: "en"
  )

  // Colored headings
  show heading: set text(fill: accent_color)
  // Pretty separators
  show "|": bar => text(fill: accent_color)[#sym.diamond.filled.medium]
  // Show the external icon after all links
  show link: content => box[#content #box(image(icon_external ,height: 0.7em))]

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
      fill: third_color
    )
    #v(1fr)
    #grid(
      columns: (10em, 1fr),
      gutter: 18pt,
      align(horizon)[#box(image(illust ,height: auto))],
      align(horizon)[
        #text(size: 32pt, fill: third_color, weight: "bold")[#titulo]\
        #image("assets/banner-vertical-en-color.svg", width: 90%)
      ]
    )
    #v(1fr)

    Last updated: #read(".cut"), Revision #edition.

    This schedule is subject to changes at *any time*.

    #link(updates_url)[Check for updates following this link] as our materials are usually featured with new details, re-compiled and deployed daily.
  ]

  let contraportada() = align(center + top)[
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
      fill: third_color
    )
    #v(1fr)

    #grid(
    columns: (1fr,) * partners.len(),
    gutter: 14pt,
    ..partners.map(partner => {
      let logo = partner.logo
      if partner.adaptive { logo = bytes(read(partner.logo).replace("#000", third_color.to-hex(),)) }
      align(horizon+center)[#image(logo, width: 100%)]
    }))
    #v(0.1fr)
    #sym.copyright Grupo de Investigación en Filosofía de la Computación, México, 2025.
  ]


  portada()
  doc
  contraportada()
}
