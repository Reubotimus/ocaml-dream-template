val is_htmx : Dream.request -> bool
val html_fragment : string -> Dream.response Lwt.t
val html_page : string -> Dream.response Lwt.t
