val auth_link : bool -> string
val auth_action : bool -> string
val render_home : auth_link:string -> auth_action:string -> string
val render_protected : auth_link:string -> auth_action:string -> string
val render_login : Dream.request -> auth_link:string -> string
val preload : unit -> unit
val routes : Dream.route list
