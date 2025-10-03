// Metadata
#let main_color = rgb("#291F3A")
#let accent_color = rgb("#773898")
#let third_color = rgb("#BC5FD3")
#let alternative_color = rgb("#e6b700")

#let icon_external = bytes(read("/assets/external.svg").replace("#000", accent_color.to-hex(),))
#let icon_icphilcomp = bytes(read("/assets/icphilcomp.svg").replace("#000", accent_color.to-hex(),))

#let icon_email(fill: accent_color, size: 12pt) = box(image(bytes(read("/assets/email.svg").replace("#000", fill.to-hex(),)), width: size, height: size))
#let icon_git(fill: accent_color, size: 12pt) = box(image(bytes(read("/assets/github.svg").replace("#000", fill.to-hex(),)), width: size, height: size))
#let icon_www(fill: accent_color, size: 12pt) = box(image(bytes(read("/assets/www.svg").replace("#000", fill.to-hex(),)), width: size, height: size))
#let icon_linkedin(fill: white, size: 12pt) = box(image(bytes(read("/assets/linkedin.svg").replace("#000", fill.to-hex(),)), width: size, height: size))
#let icon_facebook(fill: accent_color, size: 12pt) = box(image(bytes(read("/assets/facebook.svg").replace("#000", fill.to-hex(),)), width: size, height: size))
#let icon_twitter(fill: accent_color, size: 12pt) = box(image(bytes(read("/assets/twitter.svg").replace("#000", fill.to-hex(),)), width: size, height: size))
#let icon_instagram(fill: accent_color, size: 12pt) = box(image(bytes(read("/assets/instagram.svg").replace("#000", fill.to-hex(),)), width: size, height: size))
#let icon_bluesky(fill: accent_color, size: 12pt) =  box(image(bytes(read("/assets/bluesky.svg").replace("#000", fill.to-hex(),)), width: size, height: size))
#let icon_tiktok(fill: accent_color, size: 12pt) =  box(image(bytes(read("/assets/tiktok.svg").replace("#000", fill.to-hex(),)), width: size, height: size))
#let icon_youtube(fill: accent_color, size: 12pt) =  box(image(bytes(read("/assets/youtube.svg").replace("#000", fill.to-hex(),)), width: size, height: size))

#let tile_filosofia(fill: main_color) = bytes(read("/assets/tiles/filosofia.svg").replace("#000", fill.to-hex(),))
#let tile_sociedad(fill: main_color) = bytes(read("/assets/tiles/sociedad.svg").replace("#000", fill.to-hex(),))
#let tile_teoria(fill: main_color) = bytes(read("/assets/tiles/teoria.svg").replace("#000", fill.to-hex(),))
#let tile_tecnica(fill: main_color) = bytes(read("/assets/tiles/tecnica.svg").replace("#000", fill.to-hex(),))
#let tile_colibri(fill: main_color) = bytes(read("/assets/tiles/colibri.svg").replace("#000", fill.to-hex(),))

#let icon_videocamera(fill: accent_color, size: 12pt) =  box(image(bytes(read("/assets/videocamera.svg").replace("#000", fill.to-hex(),)), width: size, height: size))


/* Se usan para desplegar el formato de la presentación. */
#let chip(color: third_color.lighten(30%), content) = {
  box(
    width: auto,
    inset: 0.35em,
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
          fill: third_color.lighten(60%),
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
      text(20pt)[#heading(level: 1, [#title])]
    }
    La mesa de registro y de café abren a las #start_time, disponibles durante toda la jornada. Receso de 15:00 a 16:00.
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

    // Set session colors
    let stroke_color = third_color
    let fill_color = accent_color
    // Import session presentations
    let presentations = csv("database/" + session.bloque + ".csv", row-type: dictionary)
    // Let's decide if this header needs a special color
    if presentations.first().formato == "Keynote" {
      stroke_color = alternative_color
      fill_color = alternative_color.darken(40%)
    }


    // Session header
    box(
      width: 100%,
      stroke: stroke_color,
      fill: stroke_color.lighten(80%),
      inset: 0.6em,
      text(size: 9pt)[
      #text(size:11pt, weight: "bold", fill: fill_color)[
        #if session.bloque.first() != "X" {
          [
          #heading(level: 2)[ #if session.streaming != "" [#icon_videocamera(fill: fill_color)] Sesión #session.bloque: #session.tematica]
          ]
          text(size: 11pt, fill: black, weight: "regular")[#if session.nombre != "" [#session.nombre]]
        } else {
          // Es una mesa, keynote, algo así, no ocupa decir "Bloque"
          show heading: set text(fill: fill_color)
          heading(level: 2)[ #if session.streaming != "" [#icon_videocamera(fill: fill_color)] #session.nombre]
        }

      ]
      #box(image("assets/door.svg",height: 0.8em,)) #session.sala #h(5pt)#box(image("assets/clock.svg",height: 0.8em,)) #session.inicia - #session.termina (#session.duracion min.)
      #if session.host != "" [#h(5pt) #box(image("assets/user.svg",height: 0.8em,)) #session.host]
      ]
    )


    // These are used to compute the timeframes between presentations
    let start_time_split = session.inicia.split(regex("[:]"))
    let start_time = datetime(hour: int(start_time_split.at(0)),minute: int(start_time_split.at(1)),second:0)
    let runtime = start_time

    // Does this session needs an intro?
    if int(session.delay) > 0 {
      box()[#grid(
          columns: (auto, 1fr),
          rows: (auto),
          gutter: 2pt,
          [#box(width: auto, inset: 0.4em, fill: fill_color.lighten(80%), text(fill: fill_color)[*#runtime.display("[hour]:[minute]")*])],
          [#box(width: auto, inset: 0.4em, [*Introducción por el host*])]
      )]
      runtime = runtime + duration(minutes: int(session.delay))
    }

    // Layout presentations
    for presentation in presentations {
      box()[#grid(
        columns: (auto, 1fr),
        rows: (auto, auto),
        gutter: 4pt,
        //Timestamp
        [#box(width: auto, inset: 0.4em, fill: fill_color.lighten(80%), text(fill: fill_color)[*#runtime.display("[hour]:[minute]")*])],
        //Tags
        align(horizon)[#chip(color: stroke_color.lighten(30%), [#presentation.formato])],
        //Guarda
        [],
        //Nombre y autores
        [
          *#presentation.titulo*\
          #if presentation.autores != "" {
            text(size: 10pt)[#presentation.autores\ ]
          }
          #if presentation.afiliacion != "" {
            text(size:9pt, fill: fill_color)[#presentation.afiliacion]
          }
        ]
      )]
     // The unavoidable pass of time...
     let timespan = duration(minutes: int(presentation.timeframe))
     runtime = runtime + timespan + duration(minutes: 5)
    }
    pad(bottom:1pt)[]
  }
}


#let resumes(title, comment, path) = {
  set page(
    header: context{
      set text(size: 10pt)
      box(width: 26pt, height: 22pt)[
        #box(height: 100%)[#align(horizon)[#image(icon_icphilcomp)]]
      ]
      box(width: 1fr, height: 22pt)[
        #box(height: 100%)[#align(horizon)[#text(fill: accent_color, weight: "bold", "ICPHILCOMP25 ")]]
      ]
      box(width: 22pt, height: 22pt)[
        #if counter(page).get().first() > 0 [
          #align(horizon+center)[#counter(page).display("1", both: false)]
        ]
      ]
    }
  )

  [
  = #title
  #comment
  ]
  let guests = csv(path, row-type: dictionary)
  for guest in guests {
    grid(
      columns: (7.5em, 1fr),
      rows: (auto, auto),
      gutter: 14pt,
      // PHOTO
      [
        #image("./database/photos/proccesed/" + guest.normalname + ".jpg")
        // SNS
        #if guest.website != "" [
          #link(guest.website)[
            #chip(color: accent_color,[#grid(columns:(auto,auto,), column-gutter: 4pt, [#icon_www(fill:white, size: 7pt)], align(horizon)[#text(size: 7pt, fill: white)[#guest.website.match(regex("^(?:https?:\\/\\/)?(?:www\\.)?(?:[^\\/]+\\.)?([^\\/]+\\.[a-z]{2,})(?:\\/.*)?$")).captures.first()]])])
          ]
        ]
        #if guest.linkedin != "" [
          #link("https://linkedin.com/in/" + guest.linkedin)[
            #chip(color: blue,[#grid(columns:(auto,auto,), column-gutter: 4pt, [#icon_linkedin(fill:white, size: 7pt)], align(horizon)[#text(size: 7pt, fill: white)[#guest.linkedin]])])
          ]
        ]
        #if guest.twitter != "" [
          #link("https://x.com/" + guest.twitter)[
            #chip(color: black,[#grid(columns:(auto,auto,), column-gutter: 4pt, [#icon_twitter(fill:white, size: 7pt)], align(horizon)[#text(size: 7pt, fill: white)[#guest.twitter]])])
          ]
        ]
        #if guest.bluesky != "" [
          #link(guest.bluesky)[
            #chip(color: blue,[#grid(columns:(auto,auto,), column-gutter: 4pt, [#icon_bluesky(fill:white, size: 7pt)], align(horizon)[#text(size: 7pt, fill: white)[#guest.bluesky.match(regex("^(?:https?:\\/\\/bsky\\.app\\/profile\\/)?(.+)(?:\\.bsky\\.social)")).captures.first()]])])
          ]
        ]
        #if guest.facebook != "" [
          #link(guest.facebook)[
            #chip(color: rgb("#0866FF"),[#grid(columns:(auto,auto,), column-gutter: 4pt, [#icon_facebook(fill:white, size: 7pt)], align(horizon)[#text(size: 7pt, fill: white)[Facebook]])])
          ]
        ]
        #if guest.instagram != "" [
          #link("https://instagram.com/" + guest.instagram)[
            #chip(color: gradient.linear(purple, fuchsia, red, yellow, angle: 0deg),[#grid(columns:(auto,auto,), column-gutter: 4pt, [#icon_instagram(fill:white, size: 7pt)], align(horizon)[#text(size: 7pt, fill: white)[#guest.instagram]])])
          ]
        ]
        #if guest.git != "" [
          #link("https://www.github.com/" + guest.git)[
            #chip(color: black,[#grid(columns:(auto,auto,), column-gutter: 4pt, [#icon_git(fill:white, size: 7pt)], align(horizon)[#text(size: 7pt, fill: white)[#guest.git]])])
          ]
        ]
        #if guest.youtube != "" [
          #link("https://www.youtube.com/" + guest.youtube)[
            #chip(color: red,[#grid(columns:(auto,auto,), column-gutter: 4pt, [#icon_youtube(fill:white, size: 7pt)], align(horizon)[#text(size: 7pt, fill: white)[#guest.youtube]])])
          ]
        ]
        #if guest.tiktok != "" [
          #link("https://www.tiktok.com/" + guest.tiktok)[
            #chip(color: gradient.linear(teal, fuchsia, angle: 0deg),[#grid(columns:(auto,auto,), column-gutter: 4pt, [#icon_tiktok(fill:white, size: 7pt)], align(horizon)[#text(size: 7pt, fill: white)[#guest.tiktok]])])
          ]
        ]
      ],
      // RESUME
      grid.cell(
        colspan: 1,
        [
        == #guest.fullname #text(size: 10pt)[(#guest.pronouns)] <guest.fullname>
        #if guest.public_email != "" [
          #link("mailto:" + guest.public_email)[
            #chip(color: accent_color,[#grid(columns:(auto,auto,), column-gutter: 4pt, [#icon_email(fill:white, size: 7pt)], align(horizon)[#text(size: 7pt, fill: white)[#guest.public_email]])])
          ]
        ]
        #if guest.affiliation != "" [#text(size:8pt, fill: accent_color, weight:"bold")[#guest.affiliation\ ]]
        #text(size:8pt)[#guest.resume]
        ]),
    )
  }
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
    font: "Montserrat",
    weight: 500,
    lang: "en"
  )

  set strong(delta: 300)
  show strong: set text(weight: 400)

  // Colored headings
  show heading: set text(fill: accent_color)
  // Pretty separators
  show "|": bar => text(fill: accent_color)[#sym.diamond.filled.medium]
  // Show the external icon after all links
  // show link: content => box[#content #box(image(icon_external ,height: 0.7em))]

  let portada() = align(left + top)[
    #set page(
      margin: 30pt,
      background:
        rect(
          fill: main_color,
          width: 100%,
          height: 100%,
          image(width: auto, "assets/portada_dorso.svg")
        ),
      footer: [],
      header: []
    )
    #set text(
      fill: third_color
    )
    #align(left+horizon)[#grid(
      columns: (10em, 30em),
      rows: (1fr, 1fr, 1fr, 1fr, 1fr),
      row-gutter: 20pt,
      column-gutter: 6em,
      align(horizon)[#box(image(tile_filosofia() ,height: auto))],
      grid.cell(
        rowspan: 4,
        align(horizon)[
          #text(size: 32pt, fill: third_color, weight: "bold")[#titulo]\
          #image("assets/icphilcomp25_logo_light_en.svg", width: 90%)
        ]
      ),
      align(horizon)[#box(image(tile_sociedad(), height: auto))],

      align(horizon)[#box(image(tile_teoria(), height: auto))],

      align(horizon)[#box(image(tile_tecnica(), height: auto))],

      align(horizon)[#box(image(tile_colibri(), height: auto))],
      text(size: 10pt)[
        Revision \##edition\
        Última actualización: #read(".cut").

        El contenido de este programa está sujeto a cambios de horario y disponibilidad *en cualquier momento y sin previo aviso*.

        #link(updates_url)[#chip(color:third_color, text(fill: main_color)[Descarga la edición más reciente haciendo clic en este link])]
      ]
    )]
  ]

  let contraportada() = align(center + top)[
    #set page(
      background:
        rect(
          fill: main_color,
          width: 100%,
          height: 100%,
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
