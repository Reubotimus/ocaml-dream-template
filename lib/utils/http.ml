let ( let* ) = Lwt.bind

let http_post url ?body headers =
  let* resp, body =
    match body with
    | Some b -> Cohttp_lwt_unix.Client.post ~headers ~body:b (Uri.of_string url)
    | None -> Cohttp_lwt_unix.Client.post ~headers (Uri.of_string url)
  in
  let code = resp |> Cohttp.Response.status |> Cohttp.Code.code_of_status in
  if Cohttp.Code.is_success code then
    let* b = Cohttp_lwt.Body.to_string body in
    Lwt.return (Ok (code, b))
  else Lwt.return (Error (code, Cohttp.Code.reason_phrase_of_code code))

let http_get url headers =
  let* resp, body = Cohttp_lwt_unix.Client.get ~headers (Uri.of_string url) in
  let code = resp |> Cohttp.Response.status |> Cohttp.Code.code_of_status in
  if Cohttp.Code.is_success code then
    let* b = Cohttp_lwt.Body.to_string body in
    Lwt.return (Ok (code, b))
  else Lwt.return (Error (code, Cohttp.Code.reason_phrase_of_code code))

let parse_json json record_constructor =
  try
    let parsed = json |> Yojson.Safe.from_string |> record_constructor in
    Ok parsed
  with
  | Yojson.Json_error msg -> Error msg
  | Ppx_yojson_conv_lib.Yojson_conv.Of_yojson_error (msg, _) ->
      Error (Printexc.to_string msg)
