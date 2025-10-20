// COLORS
#let main_color = rgb("#291F3A")
#let accent_color = rgb("#773898")
#let third_color = rgb("#BC5FD3")
#let alternative_color = rgb("#ff7f2a")

// LOGOS
#let logo(fill: accent_color) = bytes(read("/assets/icphilcomp25_logo_black_en.svg").replace("#000", fill.to-hex(),))

// PAGE DECORATIONS
#let bg_gafete(fill: accent_color) = bytes(read("/assets/gafete_.svg").replace("#000", fill.to-hex(),))
#let bg_gafete_staff(fill: accent_color) = bytes(read("/assets/gafete_staff_.svg").replace("#000", fill.to-hex(),))

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
#let tile_filosofia(fill: main_color) = decode_logo("/assets/tiles/filosofia.svg")
//#let tile_filosofia(fill: main_color) = bytes(read("/assets/tiles/filosofia.svg").replace("#000", fill.to-hex(),))
#let tile_sociedad(fill: main_color) = bytes(read("/assets/tiles/sociedad.svg").replace("#000", fill.to-hex(),))
#let tile_teoria(fill: main_color) = bytes(read("/assets/tiles/teoria.svg").replace("#000", fill.to-hex(),))
#let tile_tecnica(fill: main_color) = bytes(read("/assets/tiles/tecnica.svg").replace("#000", fill.to-hex(),))
#let tile_colibri(fill: main_color) = bytes(read("/assets/tiles/colibri.svg").replace("#000", fill.to-hex(),))
#let guest(fill: main_color) = bytes(read("/assets/guest.svg").replace("#000", fill.to-hex(),))

// AUXILIARS
#let maybe_image(
  path,
  fallback: rect(width: 8em, height: 8em, fill: luma(235), stroke: 1pt)[
              #set align(center + horizon)],
  ..args) = context {
  let path-label = label(path)
   let first-time = query((context {}).func()).len() == 0
   if first-time or query(path-label).len() > 0 {
    [#image(path, ..args)#path-label]
  } else {
      fallback
  }
}

#let decode_logo(fill: accent_color, source) = bytes(read(source).replace("#000", fill.to-hex(),))
