let ( let* ) = Lwt.bind

let http_get url headers =
  let* (resp, body) =
    Cohttp_lwt_unix.Client.get ~headers (Uri.of_string url)
  in
  let code = resp
             |> Cohttp.Response.status
             |> Cohttp.Code.code_of_status in
  if Cohttp.Code.is_success code
  then
    let* b = Cohttp_lwt.Body.to_string body in
    Lwt.return (Ok (code, b))
  else
    Lwt.return (Error (
      code, Cohttp.Code.reason_phrase_of_code code
    ))


