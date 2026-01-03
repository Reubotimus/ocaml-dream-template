let ( let* ) = Lwt.bind

let headers () =
  Cohttp.Header.of_list
    [ ("apikey", Env.supabase_key ()); ("content-type", "application/json") ]

type supabase_error =
  | Http_error of string
  | Unauthorised of string
  | Response_parse_error of string
  | Unexpected_error of string

type supabase_login_response = { user_id : string }

let supabase_login_response_of_string string =
  let safe = Yojson.Safe.from_string string in
  match
    safe |> Yojson.Safe.Util.member "user" |> Yojson.Safe.Util.member "id"
  with
  | `Null -> None
  | v -> Some { user_id = Yojson.Safe.Util.to_string v }

let supabase_login email password =
  let url =
    Printf.sprintf "%s/auth/v1/token?grant_type=password" (Env.supabase_url ())
  in
  let body_string =
    Format.sprintf {|{"email":%s, "password":%s}|}
      (Yojson.Safe.to_string (`String email))
      (Yojson.Safe.to_string (`String password))
  in
  let body = Cohttp_lwt.Body.of_string body_string in
  let* resp = Http.http_post url ~body (headers ()) in
  match resp with
  | Error (401, message) | Error (400, message) | Error (403, message) ->
      Lwt_result.fail (Unauthorised message)
  | Error (_, message) -> Lwt_result.fail (Http_error message)
  | Ok (200, body) -> (
      let parse_result = supabase_login_response_of_string body in
      match parse_result with
      | Some json_object -> Lwt_result.return json_object
      | None ->
          Lwt_result.fail
            (Response_parse_error "Failed to parse supabase login response"))
  | Ok _ ->
      Lwt_result.fail
        (Unexpected_error
           "Success code but not 200. This was not defined behaviour of this \
            api")

let logout access_token =
  let logout_headers =
    Cohttp.Header.of_list
      [
        ("Authorization", Format.sprintf "Bearer %s" access_token);
        ("apikey", Env.supabase_key ());
        ("content-type", "application/json");
      ]
  in
  let url = Printf.sprintf "%s/auth/v1/logout" (Env.supabase_url ()) in
  let* resp = Http.http_post url logout_headers in
  match resp with
  | Error (401, message) -> Lwt_result.fail (Unauthorised message)
  | Error (403, message) -> Lwt_result.fail (Unauthorised message)
  | Error (_, message) -> Lwt_result.fail (Http_error message)
  | Ok (_, _) -> Lwt_result.return ()
