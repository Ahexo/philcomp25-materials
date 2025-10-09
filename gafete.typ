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

  #let role = if staff == true {"STAFF"} else {"SPEAKER"}


  #align(center+horizon)[
    #let color = graphics.accent_color
    #let bg = graphics.bg_gafete(fill: color)
    #if staff == true{
      color = graphics.accent_color
      bg = graphics.bg_gafete_staff(fill: color)
    }

    #set page(
      background: image(bg),
      foreground: {rotate(-45deg, text(size: 60pt, weight: "bold", fill: rgb("#0000003a"))[SAMPLE])}
    )

    #show heading: set text(size: 14pt, fill: color, weight: "bold")
    #text(size:20pt, fill: white, weight: "bold")[#role #h(1fr) #text(size: 12pt, fill: white, weight: "bold")[#pronouns]]
    #v(1fr)
    #graphics.maybe_image(
      "database/photos/proccesed/" + normalname + ".jpg",
      width: 2.8cm,
      height: 2.8cm)
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
    staff: if persona.staff != "" {true} else {false}
  )
]
