let is_htmx (req : Dream.request) : bool =
  match Dream.header req "HX-Request" with Some "true" -> true | _ -> false

let html_fragment s = Dream.html s
let html_page s = Dream.html s
