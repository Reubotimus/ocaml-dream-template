let ( let* ) = Lwt.bind

let is_htmx req =
  match Dream.header req "HX-Request" with Some "true" -> true | _ -> false

let login_feedback msg =
  Printf.sprintf "<p class=\"text-sm text-red-600\">%s</p>"
    (Dream.html_escape msg)

let string_of_supabase_error e =
  match e with
  | Utils.Auth.Http_error m -> Format.sprintf "Http_error: %s" m
  | Unauthorised m -> Format.sprintf "Unauthorised: %s" m
  | Response_parse_error m -> Format.sprintf "Response_parse_error: %s" m
  | Unexpected_error m -> Format.sprintf "Unexpected_error: %s" m

let session_of_supabase_response (res : Utils.Auth.supabase_login_response) :
    Utils.Session.session_info =
  { user_id = res.user_id }

let handle_login req =
  match is_htmx req with
  | false ->
      Dream.respond ~status:`Bad_Request
        (login_feedback "make request through htmx")
  | true -> (
      let* form = Dream.form req in
      match form with
      | `Expired _ | `Wrong_content_type ->
          Dream.respond ~status:`Bad_Request
            (login_feedback "unable to read body")
      | `Wrong_session _ ->
          Dream.respond ~status:`Forbidden (login_feedback "wrong session")
      | `Invalid_token _ ->
          Dream.respond ~status:`Bad_Request (login_feedback "invalid token")
      | `Missing_token _ ->
          Dream.respond ~status:`Forbidden (login_feedback "missing token")
      | `Many_tokens _ ->
          Dream.respond ~status:`Bad_Request (login_feedback "many tokens")
      | `Ok fields -> (
          let email =
            List.assoc_opt "email" fields |> Option.value ~default:""
          in
          let password =
            List.assoc_opt "password" fields |> Option.value ~default:""
          in
          if email = "" || password = "" then
            Dream.respond ~status:`Bad_Request
              (login_feedback "Email and password are required")
          else
            let* resp = Utils.Auth.supabase_login email password in
            match resp with
            | Ok session_obj -> (
                let* dream_resp =
                  Dream.empty `No_Content
                    ~headers:[ ("HX-Redirect", "/protected") ]
                in
                let* set_session_resp =
                  Utils.Session.set_session req dream_resp
                    (Printf.sprintf {|{"user_id":%s}|} session_obj.user_id)
                in
                match set_session_resp with
                | Ok _ -> Lwt.return dream_resp
                | Error _ ->
                    Dream.log "Something went wrong setting session for login";
                    Dream.respond ~status:`Internal_Server_Error
                      (login_feedback "Internal server error"))
            | Error (Unauthorised _) ->
                Dream.respond ~status:`Unauthorized
                  (login_feedback "Invalid credentials")
            | Error e ->
                Dream.log "Failed to log user into supabase: %s"
                  (string_of_supabase_error e);
                Dream.respond ~status:`Bad_Gateway
                  (login_feedback "Please try again or contact support")))

let routes : Dream.route list =
  [
    Dream.get "/" (fun _ -> Dream.html (Pages.render_home ()));
    Dream.post "/auth/login" handle_login;
  ]
