let ( let* ) = Lwt.bind

let login_feedback msg =
  Printf.sprintf "<p class=\"text-sm text-red-600\">%s</p>"
    (Dream.html_escape msg)

let string_of_supabase_error e =
  match e with
  | Utils.Supabase.Http_error m -> Format.sprintf "Http_error: %s" m
  | Unauthorised m -> Format.sprintf "Unauthorised: %s" m
  | Response_parse_error m -> Format.sprintf "Response_parse_error: %s" m
  | Unexpected_error m -> Format.sprintf "Unexpected_error: %s" m

let string_of_redis_error e =
  match e with
  | Utils.Redis.Http_error m -> Format.sprintf "Http_error: %s" m
  | Utils.Redis.Json_parse_error m -> Format.sprintf "Json_parse_error: %s" m
  | Utils.Redis.Redis_error m -> Format.sprintf "Redis_error: %s" m
  | Utils.Redis.Unexpected_response m ->
      Format.sprintf "Unexpected_response: %s" m

let redirect_from_fields fields =
  match List.assoc_opt "redirect" fields with
  | Some path when String.length path > 0 && path.[0] = '/' -> path
  | _ -> "/protected"

let%expect_test "redirect_from_fields /ok" =
  redirect_from_fields [ ("redirect", "/ok") ] |> print_endline;
  [%expect {|/ok|}]

let%expect_test "redirect_from_fields empty" =
  redirect_from_fields [ ("redirect", "") ] |> print_endline;
  [%expect {|/protected|}]

let%expect_test "redirect_from_fields external url" =
  redirect_from_fields [ ("redirect", "http://evil.com") ] |> print_endline;
  [%expect {|/protected|}]

let%expect_test "redirect_from_fields double slash" =
  redirect_from_fields [ ("redirect", "//evil.com") ] |> print_endline;
  [%expect {|//evil.com|}]

let handle_login req =
  match Htmx.is_htmx req with
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
            let redirect = redirect_from_fields fields in
            let* resp = Utils.Supabase.supabase_login email password in
            match resp with
            | Ok session_obj -> (
                let* dream_resp =
                  Dream.empty `No_Content ~headers:[ ("HX-Redirect", redirect) ]
                in
                let* set_session_resp =
                  Utils.Session.set_session req dream_resp
                    (Printf.sprintf {|{"user_id":"%s"}|} session_obj.user_id)
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

let handle_logout req =
  let resp_builder outcome =
    match outcome with
    | `No_session ->
        Dream.respond ~status:`Unauthorized
          (login_feedback "You are already logged out")
    | `Deleted -> Dream.redirect ~status:`See_Other req "/login"
    | `Redis_error err ->
        Dream.log "Failed to delete session during logout: %s"
          (string_of_redis_error err);
        Dream.respond ~status:`Bad_Gateway
          (login_feedback "Unable to log out right now")
  in
  Utils.Session.delete_session req resp_builder

let routes : Dream.route list =
  [
    Dream.get "/" (fun _ ->
        Dream.html
          (Pages.render_home ~auth_link:(Pages.auth_link false)
             ~auth_action:(Pages.auth_action false)));
    Dream.post "/auth/login" handle_login;
    Dream.post "/auth/logout" handle_logout;
  ]
