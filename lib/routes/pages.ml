open Lwt
let default_ttl_seconds = 60 * 60 (* 1 hour *)

let json status (yo : Yojson.Safe.t) =
  Dream.response
    ~status
    ~headers:[ ("Content-Type", "application/json") ]
    (Yojson.Safe.to_string yo)

let ok fields =
  json `OK (`Assoc (("ok", `Bool true) :: fields))

let err ?(status = `Bad_Gateway) msg =
  json status (`Assoc [ ("ok", `Bool false); ("error", `String msg) ])

let set_route req =
  let session = Dream.param req "session" in
  let value = Dream.param req "value" in
  Utils.Redis.setex session default_ttl_seconds value >>= function
  | Ok () ->
      ok
        [ ("action", `String "setex")
        ; ("session", `String session)
        ; ("ttl_seconds", `Int default_ttl_seconds)
        ; ("value", `String value)
        ]
      |> Lwt.return
  | Error _ -> Lwt.return (err "error")

let get_route req =
  let session = Dream.param req "session" in
  Utils.Redis.get session >>= function
  | Ok value ->
      ok
        [ ("action", `String "get")
        ; ("session", `String session)
        ; ("value", `String value)
        ]
      |> Lwt.return
  | Error _ -> Lwt.return (err "error")

let del_route req =
  let session = Dream.param req "session" in
  Utils.Redis.delete session >>= function
  | Ok deleted ->
      ok
        [ ("action", `String "del")
        ; ("session", `String session)
        ; ("deleted", `Int deleted)
        ]
      |> Lwt.return
  | Error _ -> Lwt.return (err "error")
let routes : Dream.route list =
  [
    Dream.get "/" (fun _ -> Dream.html (Views.Pages.Home.render ()));
    Dream.get "/protected" (fun _ ->
        Dream.html (Views.Pages.Protected.render ()));
    Dream.get "/login" (fun _ -> Dream.html (Views.Pages.Login.render ()));
   Dream.get "/set/:session/:value" set_route
       ; Dream.get "/get/:session" get_route
       ; Dream.get "/del/:session" del_route 
  ]


