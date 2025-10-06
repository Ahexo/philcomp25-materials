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
  normalname: "alejandro_axel_rodriguez_sanchez",
  pronouns: "she/her",
  affiliation: "Philosophy Of Computing Research Group, UNAM",
  staff: false) = [

  #set page(
    background: image(graphics.bg_gafete())
  )

  #let role = if staff == true {"Staff"} else {"Speaker"}


  #align(center+horizon)[
    #text(size:20pt, fill: white, weight: "bold")[#role]
    #v(1fr)

    #graphics.maybe_image(
      "database/photos/proccesed/" + normalname + ".jpg",
      width: 3cm,
      height: 3cm,
      alt: "photo")
    //#rect(width: 3cm, height: 3cm, fill: graphics.accent_color)

    #text(size: 14pt, fill: graphics.accent_color, weight: "bold")[#name ]
    #text(size: 8pt, fill: graphics.accent_color, weight: "bold")[#pronouns]\
    #text(size: 10pt, weight: "medium")[#affiliation]
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
    staff: if persona.staff != "" {true} else {false}
  )
]
