open Ppx_yojson_conv_lib.Yojson_conv.Primitives

let headers () =
  Cohttp.Header.of_list
    [
      ("Authorization", Printf.sprintf "Bearer %s" (Env.redis_token ()));
      ("content-type", "application/json");
    ]

let ( let* ) = Lwt.bind

type redis_string_response = {
  result : string option; [@yojson.default None]
  error : string option; [@yojson.default None]
}
[@@deriving yojson]

type redis_int_response = {
  result : int;
  error : string option; [@yojson.default None]
}
[@@deriving yojson]

type redis_error =
  | Http_error of string
  | Json_parse_error of string
  | Redis_error of string
  | Unexpected_response of string

let setex key ttl_seconds value =
  let url =
    Printf.sprintf "%s/setex/%s/%d/%s" (Env.redis_url ()) (Uri.pct_encode key)
      ttl_seconds (Uri.pct_encode value)
  in
  let* resp = Http.http_get url (headers ()) in
  match resp with
  | Error (_, msg) -> Lwt_result.fail (Http_error msg)
  | Ok (_, body) -> (
      match Http.parse_json body redis_string_response_of_yojson with
      | Ok { error = Some err_msg; _ } -> Lwt_result.fail (Redis_error err_msg)
      | Ok { result = Some "OK"; _ } -> Lwt_result.return ()
      | Ok _ ->
          Lwt_result.fail
            (Unexpected_response "Invalid upstash response, not ok but no error")
      | Error msg -> Lwt_result.fail (Json_parse_error msg))

let get key =
  let url =
    Printf.sprintf "%s/get/%s" (Env.redis_url ()) (Uri.pct_encode key)
  in
  let* resp = Http.http_get url (headers ()) in
  match resp with
  | Error (_, msg) -> Lwt_result.fail (Http_error msg)
  | Ok (_, body) -> (
      match Http.parse_json body redis_string_response_of_yojson with
      | Ok { error = Some err_msg; _ } -> Lwt_result.fail (Redis_error err_msg)
      | Ok { result; _ } -> Lwt_result.return result
      | Error msg -> Lwt_result.fail (Json_parse_error msg))

let delete key =
  let url =
    Printf.sprintf "%s/del/%s" (Env.redis_url ()) (Uri.pct_encode key)
  in
  let* resp = Http.http_get url (headers ()) in
  match resp with
  | Error (_, msg) -> Lwt_result.fail (Http_error msg)
  | Ok (_, body) -> (
      match Http.parse_json body redis_int_response_of_yojson with
      | Ok { error = Some err_msg; _ } -> Lwt_result.fail (Redis_error err_msg)
      | Ok { result; _ } -> Lwt_result.return result
      | Error msg -> Lwt_result.fail (Json_parse_error msg))
