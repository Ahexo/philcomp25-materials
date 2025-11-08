#import "graphics.typ"

// COLORS
#let main_color = graphics.main_color
#let accent_color = graphics.accent_color
#let third_color = graphics.third_color
#let alternative_color = graphics.alternative_color

// PAGE DECORATIONS
#let page_decoration_1(fill: accent_color) = bytes(read("/assets/page_decoration_1.svg").replace("#000", fill.to-hex(),))

// ICONOGRAPHY
#let icon_videocamera(fill: accent_color, size: 12pt) =  box(image(bytes(read("/assets/videocamera.svg").replace("#000", fill.to-hex(),)), width: size, height: size))
#let icon_external(fill: accent_color, size: 12pt) = box(image(bytes(read("/assets/external.svg").replace("#000", fill.to-hex(),)), width: size, height: size))
#let icon_icphilcomp = bytes(read("/assets/icphilcomp.svg").replace("#000", accent_color.to-hex(),))

// SOCIAL ICONS
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

// VISUAL RESOURCES
#let tile_filosofia(fill: main_color) = bytes(read("/assets/tiles/filosofia.svg").replace("#000", fill.to-hex(),))
#let tile_sociedad(fill: main_color) = bytes(read("/assets/tiles/sociedad.svg").replace("#000", fill.to-hex(),))
#let tile_teoria(fill: main_color) = bytes(read("/assets/tiles/teoria.svg").replace("#000", fill.to-hex(),))
#let tile_tecnica(fill: main_color) = bytes(read("/assets/tiles/tecnica.svg").replace("#000", fill.to-hex(),))
#let tile_colibri(fill: main_color) = bytes(read("/assets/tiles/colibri.svg").replace("#000", fill.to-hex(),))
#let logo_philcomp(fill: accent_color) = bytes(read("/assets/philcomp_logo_en.svg").replace("#000", accent_color.to-hex(),))


// GLOBAL AUXILIARS
/* I found myself using these plenty, perhaps I should make them into a library. */
#let str_to_time(str_time) = {
  let digits = str_time.split(":")
  let hora = datetime(hour: int(digits.at(0)), minute: int(digits.at(1)), second: 0)
  hora
}

/* Se usan para desplegar el formato de la presentación y tags varios. */
#let chip(color: third_color.lighten(30%), content) = {
  box(
    width: auto,
    inset: 0.35em,
    fill: color,
    radius: 5pt,
    text(fill: black, size: 8pt,[#content]))
}

/* Es una tabla que por defecto va de las 9 a las 19 y despliega las salas y
 * sesiones en orden cronológico */
#let timetable(path) = {
  let sessions = csv(path, row-type: dictionary)

  // Vamos a asumir que todas las jornadas inician a las 9 y acaban a las 19.
  let start = datetime(hour:9, minute:0, second:0)
  let finish = datetime(hour:19, minute:0, second:0)

  // También asumimos que todos los intervalos son de media hora.
  let cursor = start
  let step = duration(minutes:30)

  // Una funcioncita para convertir datetimes a strings de la forma HH:MM
  let disp(timestamp) = timestamp.display("[hour padding:none]:[minute]")

  let dispp(content) = {
    if type(content) == dictionary {
      table.cell(
        rowspan: content.steps,
        fill: accent_color.lighten(20%),
        stroke: accent_color,
        text(fill: white)[
          #context {
                let existe = query(label(content.bloque)).len()
                if existe > 0 [#link(label(content.bloque))[#icon_external(size:10pt, fill: white.lighten(90%))]\ ]
              }
          #if content.bloque.first() != "X" [
            *Sesión #content.bloque*\
            #text(size: 8pt, content.nombre)
          ] else [
            *#content.nombre*
          ]
        ]
      )
    }
    else {content}
  }

  // Generar una lista de horarios con steps de media hora entre el inicio y el final
  // (No se si exista una mejor forma de hacer esto en typst, al parecer dedup hace algo cercano)
  let timestamps = (disp(start),)
  while cursor < finish {
    cursor = cursor + step
    let frame = cursor
    timestamps.push(disp(frame))
  }

  // Ahora vamos a determinar las columnas, para esto hay que agrupar las salas
  let columnas = ()
  // Busquemos salas únicas y las metemos en la lista de columnas
  for session in sessions {
    if not columnas.contains(session.sala) {columnas.push(session.sala)}
  }

  // Asumiendo que un step son 30 minutos, calculamos cuantas casillas de media hora va a ocupar un bloque.
  let halfsteps(duracion) = {int(int(duracion)/30)}

  /* Esta función verifica si una sala a hora determinada está ocupada.
  Si no lo está, devuelve un elemento vacío.
  Si sí lo está, pero no es header, devuelve una guarda.
  Si sí lo está, y es un header (es decir, la primera hora de una sesión),
    devuelve un contenido para poblar el timetable apropiadamente.
    En particular nos interesa que este sepa cuantas medias horas abarca,
    el nombre de la sesión y el ID de la sesión, es decir:
    (session.bloque, session.halfsteps, session.nombre)
  */
  let isheader(room, timestamp) = {
    let resultado = ""
    for session in sessions {
    // Si el timestamp es exactito el header, nos lo quedamos
      if session.sala == room and timestamp == session.inicia {
        resultado = (bloque: session.bloque, steps: halfsteps(session.duracion), name: session.nombre, end: session.termina, nombre: session.nombre)
      } else if session.sala == room and str_to_time(timestamp) >= str_to_time(session.inicia) and str_to_time(timestamp) < str_to_time(session.termina) {
        resultado = none
      }
    }
    resultado
  }

  /* Nuestro array de arrays, este lo vamos a aplanar despues (flatten)
  para obtener los contenidos que untar (spread) en la tabla.*/
  let series = ()

  for timestamp in timestamps {
    let frame = (align(center+horizon)[#timestamp],)
    for room in columnas {
      let contenido = isheader(room, timestamp)
      frame.push(contenido)
    }
    series.push(frame)
  }

  // aplanamos nuestra serie
  series = series.flatten()
  // Solo queremos quedarnos con los diccionarios y los strings
  let legible(elem) = if elem != none {true} else {false}
  series = series.filter(legible)

  set text(size: 10pt, weight:"medium")
  set table.vline(start: 1)
  table(
    fill: (x, y) =>
    if x == 0 or y == 0 {
      third_color.lighten(40%)
    },
    //rows: (1fr, (1fr,) * timestamps.len()).flatten(),
    columns: (0.4fr, ((1fr,) * columnas.len())).flatten(),
    align: bottom,
    stroke: none,
    [],
    table.hline(stroke: accent_color),
    ..columnas,
    ..series.map(dispp),
  )
}

/* La sección completa destinada a una sola jornada de la conferencia. */
#let schedule(day, globaldate, path, start_time: "9:00", show_timetable: false) = {
  // Primero, ponemos una página de portada.
  [
    #set page(
      background:
        rect(
          fill: third_color.lighten(60%),
          width: 110%,
          height: 110%,
          image(page_decoration_1())
        ),
    )
    #set text(fill: accent_color)
    #v(1fr)
    #text(20pt)[#heading(level: 1, [Day #day: #globaldate.display("[weekday repr:long], [month repr:long] [day padding:space]")\ ])
    #grid(
      columns: (1fr, 1fr),
      text(size:10pt)[Registration and coffee table start at #start_time and keeps available throughout the day. Recess from 15:00 to 16:00.],
      text(size:10pt)[La mesa de registro y de café abren a las #start_time, disponibles durante toda la jornada. Receso de 15:00 a 16:00.]
    )
    #v(1fr)
    #if show_timetable == true [#timetable(path)]
  ]]

  // Ahora si, vamos con el contenido del horario.
  set page(
    header: context{
      set text(size: 10pt)
      box(width: 26pt, height: 22pt)[
        #box(height: 100%)[#align(horizon)[#image(icon_icphilcomp)]]
      ]
      box(width: 1fr, height: 22pt)[
        #box(height: 100%)[#align(horizon)[#text(fill: accent_color, weight: "bold", "ICPHILCOMP25 ") #globaldate.display("[weekday repr:long], [month repr:long] [day padding:space]")]]
      ]
      box(width: 22pt, height: 22pt)[
        #if counter(page).get().first() > 0 [
          #align(horizon+center)[#counter(page).display("1", both: false)]
        ]
      ]
    },
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
    pad(top:4pt)[#box(
      width: 100%,
      stroke: stroke_color,
      fill: stroke_color.lighten(75%),
      inset: 0.6em,
      text(size: 9pt)[
      #grid(
        rows: (auto,auto),
        columns: (1fr),
        row-gutter: 16pt,
        [
          #text(size:11pt, weight: "bold", fill: fill_color)[
          #if session.bloque.first() != "X" {
            [#heading(level: 2)[ #if session.streaming != "" [#icon_videocamera(fill: fill_color)] Session #session.bloque: #session.tematica]]
            if session.nombre != "" [#text(size: 12pt, fill: black, weight: "medium")[#session.nombre]\ ]
            if session.nombre_en != "" [#text(size: 10pt, fill: black, weight: "medium")[#emph[#session.nombre_en]]]
          } else {
            // Es una mesa, keynote, algo así, no ocupa decir "Bloque"
            show heading: set text(fill: fill_color)
            heading(level: 2)[#if session.streaming != "" [#icon_videocamera(fill: fill_color)] #session.nombre]
            if session.nombre_en != "" [#text(size: 10pt, fill: black, weight: "medium")[#emph[#session.nombre_en]]]
          }
          #label(session.bloque)
          #v(1pt)
          ]
        ],
        box(fill:stroke_color.lighten(10%), outset:7pt)[
          #box(image("assets/door.svg",height: 0.8em,))
          #session.sala #h(1fr) #box(image("assets/clock.svg",height: 0.8em,))
          #session.inicia - #session.termina (#session.duracion min.) #if session.host != "" [#h(1fr)
          #label(session.host)
          #box(image("assets/user.svg",height: 0.8em,)) #session.host]
        ]
      )
      ]
    )]

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
      //Presentation header
      box()[#grid(
        columns: (auto, 1fr),
        rows: (auto, auto),
        gutter: 6pt,
        //Timestamp
        [#box(width: auto, inset: 0.4em, fill: fill_color.lighten(80%), text(fill: fill_color)[*#runtime.display("[hour]:[minute]")*])],
        //Tags
        align(horizon)[
          #chip(color: stroke_color.lighten(30%),[#presentation.lang])
          #chip(color: stroke_color.lighten(30%),[#presentation.formato])
        ],
        //Guarda
        grid.cell(
        colspan: 2,
        [
          *#presentation.titulo*
          #context {
                  let existe = query(label(presentation.id)).len()
                  if existe > 0 [#link(label(presentation.id))[#icon_external(size:8pt, fill: fill_color)]]
                }
        ])
      )]
        //Authors (out of the header box so they can split over pages)
        if presentation.autores != "" {
          let autores = csv("database/" + presentation.id + ".csv", row-type: dictionary)
          for autor in autores {
            box()[#grid(
              fill:white,
              columns: (1fr),
              rows: (auto, auto),
              row-gutter: 4pt,
              inset: 1pt,
              text(size: 10pt)[
              #autor.fullname
              #label(session.bloque + autor.fullname)
              // Si tenemos el perfil del autor, hay que poner un hipervínculo hacia allá
              #context {
                let existe = query(label(autor.normalname)).len()
                if existe > 0 [#link(label(autor.normalname))[#icon_external(size:8pt, fill: fill_color)]]
              }],
              text(size: 8pt, fill: fill_color)[#autor.affiliation]
            )
            ]
          }
        }

     // The unavoidable pass of time...
     let timespan = duration(minutes: int(presentation.timeframe))
     runtime = runtime + timespan + duration(minutes: 5)
    }
  }
}

/* Sección de semblanzas */
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
  #text(size: 10pt)[#comment]
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
        == #guest.fullname #text(size: 10pt)[(#guest.pronouns)]
        #label(guest.normalname)
        #if guest.public_email != "" [
          #link("mailto:" + guest.public_email)[
            #chip(color: accent_color,[#grid(columns:(auto,auto,), column-gutter: 4pt, [#icon_email(fill:white, size: 7pt)], align(horizon)[#text(size: 7pt, fill: white)[#guest.public_email]])])
          ]\
        ]
        #if guest.affiliation != "" [#text(size:8pt, fill: accent_color, weight:"bold")[#guest.affiliation\ ]]
        #text(size:8pt)[#guest.resume]
        ]),
    )
  }
}

#let separator(title: "separator", subtitle:"") = {
  [
    #set page(
      background:
        rect(
          fill: third_color.lighten(60%),
          width: 110%,
          height: 110%,
          image(page_decoration_1())
        ),
    )
    #set text(fill: accent_color)
    #v(1fr)
    #text(20pt)[#heading(level: 1, [#title])]
    #text(16pt)[#subtitle]
    #v(1fr)
  ]
}

#let informacion() = {
    set page(
      background:
        rect(
          width: 100%,
          height: 100%,

        ),
      footer: [],
      header: []
    )
    [
      #heading(level:1)[#text(size: 20pt)[Venue map]]
      #text(size: 24pt, fill: accent_color)[Conjunto Amoxcalli: Ground Floor]
      Investigación Científica Avenue, Ciudad Universitaria, Coyoacán, 04510 Mexico City.#footnote([Auditorio ABC (Alberto Barajas Celis), where Keynote 2 will be held, is located outside the Amoxcalli Complex but still in the School of Sciences. Ask our staff for guidance to get there if needed.\ #link("https://maps.app.goo.gl/Rnebsf6tMo8VHweg7")[#chip("Click this button to get Google Maps instructions")]])\
      #link("https://maps.app.goo.gl/8kRRCaDXFAXTXfvTA")[#chip(color: accent_color, [#text(size: 12pt, fill: white)[Google Maps #icon_external(fill: white, size: 10pt)]])]
      #image(width: auto, "assets/mapa.svg")
    ]
    v(1fr)
    [
      = Pictograms
      #grid(
        columns: (1em, auto),
        gutter: 6pt,
        [#icon_external()],align(horizon)[Click hyperlinks to go to speaker profiles, abstracts, sessions, and so on when available.],
        [#icon_videocamera()],align(horizon)[This session will be recorded and/or livestreamed. *This may change at any time.*]
      )
    ]
    v(1fr)

}

#let abstracts(path, title: "Abstracts", subtitle: "") = {
  [#separator(title: title, subtitle: subtitle)]
  let abstracts = csv(path, row-type: dictionary)
  for abstract in abstracts {
    let autors = csv("database/" + abstract.id + ".csv", row-type: dictionary)
    [
      #set page(header: [
        #context{
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
      ])
      #grid(
        columns: (1fr),
        rows: (auto, auto),
        row-gutter: 8pt,
        text(fill:accent_color, size: 8pt, weight: "semibold")[#abstract.topic],
        [
          #heading(level: 2, text(size: 16pt)[
          #abstract.titulo
          #context {
                let existe = query(label(abstract.bloque)).len()
                if existe > 0 [#link(label(abstract.bloque))[#icon_external(size:12pt, fill: accent_color)]]
              }
          ])#label(abstract.id)
        ]
      )
      #v(1fr)
      #for autor in autors {
        text(size: 12pt)[
        *#autor.fullname*
        #context {
                let existe = query(label(autor.normalname)).len()
                if existe > 0 [#link(label(autor.normalname))[#icon_external(size:8pt, fill: accent_color)]]
              }\
        ]
        text(size: 9pt)[#autor.affiliation\ ]
      }
      #v(8pt)
      #if abstract.keywords != "" [#text(size: 10pt)[Keywords: #emph[#abstract.keywords]]]
      #v(8pt)
      #text(size: 11pt)[#abstract.abstract]
    ]
    pagebreak()
  }
}

#let welcome() = [
  #set page(
      background:
        rect(
          width: 110%,
          height: 110%,
          image(page_decoration_1())
        ),
    )

  = Welcome to ICPHILCOMP'25
  _Bienvenidos a ICPHILCOMP'25_
  \
  #grid(
    columns: (1fr, 1fr),
    gutter: 24pt,
    text(size: 7pt, lang: "en")[
      75 years have passed since the publication of "Computing Machinery and Intelligence" in the journal Mind, published by the University of Oxford. This is the seminal text with which Alan Mathison Turing intellectually founded the discipline of Computer Science today known as Artificial Intelligence.

      Since then, the conversation about the emergence of computing machines within our ecology in all its environments has never been more relevant and pertinent: In an age defined by information, Artificial Intelligence, as well as the undeniable epistemic and ontological dispute between the computable and the incomputable, a debate looms over whether machines are intelligent or not, and to what extent they are actively reshaping our world and our experience of the universe.

      A critical discussion, free from the positivist biases customary in modern technocracy, with the goal of bringing humanistic and cutting-edge intellectual products to STEM students with a purely formal and technical background, was founded three years ago with the teaching of the first course in Philosophy of Computing by MSc. Enrique Francisco Soto-Astorga at the current School of Sciences of the National Autonomous University of Mexico, as part of the elective curriculum for the Computer Science Undergraduate program. This was subsequently catalyzed by the founding, within our institution, of the Philosophy of Computing Research Group; as well as by the holding of the First Symposium on Philosophy of Computing, which was a widely acclaimed event with excellent dissemination results, becoming a milestone in Latin America.

      In order to feed the continuity and expansion of this _locus_, in 2025 we are pleased to present to the world the first edition of the International Conference on Philosophy of Computing. This is the most extensive and rich program we have put together to date: 70 meticulously peer-reviewed oral presentations (49 in Spanish and 21 in English), three keynote addresses, four roundtables, and a couple of cultural activities. Together, these add up to approximately 66 hours of content. We are joined by speakers from a diverse range of corners of the globe: Argentina, Canada, China, Colombia, Denmark, Germany, Italy, the United Kingdom, the United States and Mexico. We hope their voices will be useful in establishing a more nuanced and humanistic understanding of computing and technology, laying the groundwork for future research in a field of study of undeniable relevance.
    ],
    text(size: 7pt, lang:"es")[
    75 años han transcurrido desde la publicación de "Computing Machinery and Intelligence" en la revista Mind, editada por la Universidad de Oxford. Se trata del texto seminal con el cual Alan Mathison Turing funda intelectualmente la disciplina de las Ciencias de la Computación hoy conocida como Inteligencia Artificial.

    Desde entonces, la conversación sobre la irrupción de las máquinas de cómputo dentro de nuestra ecología en todos sus ambientes nunca había sido más relevante y pertinente: En una era definida por la información, la Inteligencia Artificial, así como la innegable disputa epistémica y ontológica entre lo computable contra lo incomputable, se cierne un debate sobre si las máquinas son o no inteligentes, y en qué medida están remodelando activamente nuestro mundo y nuestra experiencia del universo.

    Una línea de discusión crítica y alejada de los sesgos positivistas que acostumbra la tecnocracia moderna, con el objetivo de traer productos intelectuales humanísticos y de frontera a estudiantes STEM con un perfil absolutamente formal y técnico, fué fundada hace tres años con la impartición del primer curso en Filosofía de la Computación por el MSc. Enrique Francisco Soto-Astorga en la presente Facultad de Ciencias de la Universidad Nacional Autónoma de México como parte de la oferta curricular optativa de la carrera en Ciencias de la Computación. Esta fué catalizada posteriormente por la fundación, dentro del seno de nuestra casa de estudios, del Grupo de Investigación en Filosofía de la Computación; así mismo con la celebración del Primer Simposio de Filosofía de la Computación, el cual se trató de un encuentro ampliamente aclamado y con excelentes resultados de difusión, volviéndose todo un hito a nivel Latinoamérica.

    En pos de continuar abonando a la continuidad y ampliación de este _locus_, este 2025 nos complace presentar ante el mundo la primera edición de la Conferencia Internacional en Filosofía de la Computación. Se trata de la cartelera más extensa y nutrida que hemos hilado hasta la fecha: 70 presentaciones orales revisadas meticulosamente por pares: 49 en Español y 21 en Inglés, 3 conferencias magistrales, 4 mesas redondas y un par de actividades culturales. En conjunto,  estas suman alrededor de 66 horas de contenidos. Nos acompañan ponentes de una variopinta de rincones del globo: Alemania, Argentina,  Canadá, Colombia, China, Dinamarca, Estados Unidos, Italia, Reino Unido y México. Es nuestra voluntad que sus voces encuentren utilidad en el establecimiento de una comprensión más matizada y humanística de la computación y de la tecnología, sentando las bases para próximas indagaciones en un campo de estudio de relevancia innegable.
    ]
  )
  #v(1fr)
  #align(center)[#image(logo_philcomp(), width: 20em)]
  #pagebreak()
]

#let credits() = [
  #set page(
      background:
        rect(
          width: 110%,
          height: 110%,
          image(page_decoration_1())
        ),
    )
  = Credits
  _Créditos_

  #text(size: 7pt)[
    *Entidades co-organizadoras*\
    *(Co-organizing entities)*
      - Universidad Nacional Autónoma de México
      - Grupo de Investigación en Filosofía de la Computación
      - Facultad de Ciencias, UNAM
      - Licenciatura en Ciencias de la Computación, Facultad de Ciencias, UNAM
      - Secretaría de Educación, Ciencia, Tecnología e Innovación del Gobierno de la Ciudad de México
    *Comité Directivo*\
    *(Steering Committee)*
      - Enrique F. Soto-Astorga (Facultad de Ciencias, UNAM), _Presidente_.
      - Karla Ramírez-Pulido (Facultad de Ciencias, UNAM)
      - Lourdes del Carmen González Huesca (Facultad de Ciencias, UNAM)
      - Francisco Vergara Silva (Instituto de Biología de la UNAM)
    *Comité Organizador*\
    *(Organizing Committee)*
      - Enrique F. Soto-Astorga (Facultad de Ciencias, UNAM), _Presidente_.
      - Lucía Aumann Aso (DAUIC, Universidad Iberoamericana)
      - Alejandro Javier Solares-Rojas (ICC, Universidad de Buenos Aires)
      - Miguel Ángel Andrade Velázquez (Facultad de Ciencias, UNAM)
      - Leonardo Abigail Castro Sánchez (Facultad de Derecho, UNAM)
      - Alejandro Axel Rodríguez Sánchez (Facultad de Ciencias, UNAM)
      - Sergio Mejía Caballero (Facultad de Ciencias, UNAM)
      - Laura Itzel Rodríguez Dimayuga (Facultad de Ciencias, UNAM)
      - Sara Barrios Rangel (DCSH, UAM-Cuajimalpa)
    *Comité de Programa*\
    *(Program Committee)*
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
    *Edición, diseño y composición tipográfica*\
    *(Edition, design and typesetting)*
      - Alejandro Axel Rodríguez Sánchez (Facultad de Ciencias, UNAM). _Diseñador y editor_.
      - Lucía Aumann Aso (DAUIC, Universidad Iberoamericana), _Editora_.
      - Sara Barrios Rangel (DCSH, UAM-Cuajimalpa), _Editora_.
  ]
]

#let icphilcomp25(
  titulo: str,
  subtitulo: str,
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
  //show "|": bar => text(fill: accent_color)[#sym.diamond.filled.medium]
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
          #text(size: 20pt, fill: third_color, weight: "semibold")[#subtitulo]
          #image("assets/icphilcomp25_logo_light_en.svg", width: 90%)
        ]
      ),
      align(horizon)[#box(image(tile_sociedad(), height: auto))],

      align(horizon)[#box(image(tile_teoria(), height: auto))],

      align(horizon)[#box(image(tile_tecnica(), height: auto))],

      align(horizon)[#box(image(tile_colibri(), height: auto))],
      text(size: 10pt, weight: "semibold")[
        Ver. #edition - #read(".cut").

        El contenido de este programa está sujeto a cambios de horario y disponibilidad *en cualquier momento y sin previo aviso*.\

        Program contents are subject to schedule and availability changes *at any time and without prior notice*.

        #link(updates_url)[#chip(color:third_color, text(fill: main_color)[
        Descarga la edición más reciente haciendo clic en este botón\
        Download the latest edition by clicking this button
        ])]
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
      if partner.adaptive { logo = graphics.decode_logo(fill: third_color, partner.logo) }
      align(horizon+center)[#image(logo, width: 100%)]
    }))
    #v(0.1fr)
    #sym.copyright Grupo de Investigación en Filosofía de la Computación, México, 2025.
  ]
  portada()
  welcome()
  credits()
  informacion()
  doc
  contraportada()
}
