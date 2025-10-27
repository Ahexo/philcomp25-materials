// Recibe un bloque como entrada y genera un carrusel de insta con las presentaciones correspondientes.
// Incluye una portada con los datos: Tipo, nominalización, titulo, hora, fecha, sala y moderador.

#import "graphics.typ"

#let main_color = rgb("#382a4c")
#let accent_color = rgb("#bc69d3")
#let alternative_color = rgb("#ff7f2a")

#let sin_transmision_label = "Esta sesión es exclusiva para nuestros asistentes presenciales"
#let con_transmision_label = "Esta sesión contará con transmisión de video en vivo por nuestros medios oficiales"

#set page(
  width: 810pt,
  height: 1012.5pt
)

#set text(
  font: "Montserrat",
  size: 16pt,
)

#let socialgrid = [
  #grid(
    columns: 2,
    rows: 3,
    row-gutter: 0.6em,
    column-gutter: 0.5em,
    align(right+horizon)[#graphics.icon_instagram(fill: main_color, size: 1em) #graphics.icon_facebook(fill: main_color, size: 1em)],align(left+horizon)[#text(weight: "bold", fill: main_color, "@philcomp.unam")],
    align(right+horizon)[#graphics.icon_youtube(fill: main_color, size: 1em)],align(left+horizon)[#text(weight: "bold", fill: main_color, "@philcompmx")],
    align(right+horizon)[#graphics.icon_www(fill: main_color, size: 1em)],align(left+horizon)[#text(weight: "bold", fill: main_color, "philcomp.org")],
  )
]

#let matchcard(
  titulo: "Título de la ponencia",
  formato: "SIN FORMATO",
  fecha: "fecha",
  lugar: "lugar",
  transmision: false,
) = [

  #let transmision_label = sin_transmision_label
  #let transmision_icon = graphics.icon_videocamera(fill: main_color, size: 2em)
  #if transmision { transmision_label = con_transmision_label }

  #set page(
    margin: (
      top: 60pt,
      bottom: 60pt,
      left: 60pt,
      right: 60pt
    ),
    background:
      rect(
          fill: main_color,
          width: 120%,
          height: 120%,
          image(width: auto, graphics.bg_teoria(fill: accent_color))
        )
  )
  // Recuadro
  #box(width: 100%, height: 100%, fill: main_color)[
    // Header
    #box(width: 100%, height: 12%, fill: accent_color)[
      // Recuardo con el tapetito temático
      #box(width:18%, height: 100%, fill: main_color)[]
      // Logo en el header
      #box(width:1fr, height: 100%, inset: 18pt)[
        #align(center+horizon)[#image(width: 80%, graphics.logo(fill: main_color))]
      ]
    ]
    // Body
    #box(width: 100%, height: 73%, inset: 24pt,
      [
        #v(1fr)
        #text(size: 20pt, weight: "bold", fill: accent_color, upper(formato))\
        #v(1pt)
        #text(size: 36pt, weight: "bold", fill: accent_color, titulo)\
        #v(1pt)
        #graphics.icon_clock(size: 16pt, fill: accent_color) #h(5pt)
        #text(size: 22pt, weight: "bold", fill: accent_color, fecha)
        #h(22pt)
        #graphics.icon_door(size: 16pt, fill: accent_color) #h(5pt)
        #text(size: 22pt, weight: "bold", fill: accent_color, lugar)
      ]
    )
    // Footer
    #rect(width: 100%, height: 12%, inset: 20pt, fill: accent_color)[
      #grid(
        columns: (0.12fr, 1fr, 0.5fr),
        gutter: 4pt,
        // Icono de la transmisión
        [#transmision_icon],
        // Label de la transmisión (o no)
        [#text(size: 18pt, weight: "bold", fill: main_color, transmision_label)],
        [#socialgrid]
      )
    ]
  ]


]

#matchcard()
