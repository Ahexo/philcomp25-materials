#import "graphics.typ"

#set page(
  width: 9cm,
  height: 12cm,
  margin: (top: 1.2cm, bottom: 0.5cm, left: 1cm, right: 1cm),
)

#set text(
  font: "Montserrat",
)

#let gafete(
  name: "Jane Doe",
  normalname: "jane_doe",
  pronouns: "she/her",
  affiliation: "Philosophy Of Computing Research Group, UNAM",
  role: "SPEAKER",
  num: 0,
  staff: 0) = [

  #align(center+horizon)[
    #let color = graphics.accent_color
    #let bg = graphics.bg_gafete(fill: color)
    #if staff == "1"{
      color = graphics.alternative_color
      bg = graphics.bg_gafete_staff(fill: color)
    }

    #set page(
      background: image(bg)
    )

    #show heading: set text(size: 14pt, fill: color, weight: "bold")
    #text(size:20pt, fill: white, weight: "bold")[#role #h(1fr) #text(size: 12pt, fill: white, weight: "bold")[#pronouns] #h(1fr) #text(size: 10pt, fill: white, weight: "semibold")[ #num]]
    #v(1fr)
    #graphics.maybe_image(
      "database/photos/proccesed/" + normalname + ".jpg",
      width: 2.8cm,
      height: 2.8cm,
      fallback: rect(width: 9em, height: 9em, stroke: 0pt, image(graphics.guest(fill: color))))
    #heading(level:1, name)
    #text(size: 9pt, weight: "medium")[#affiliation]
    #v(1fr)
    #image(graphics.logo(fill: white))
  ]
]

#let people = csv("database/gafetes.csv", row-type: dictionary)

#for persona in people [
  #gafete(
    name: persona.fullname,
    normalname: persona.normalname,
    pronouns: persona.pronouns,
    affiliation: persona.affiliation,
    role: persona.role,
    staff: persona.staff,
    num: persona.number
  )
]
