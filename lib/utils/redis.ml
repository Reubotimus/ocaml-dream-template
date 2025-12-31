open Ppx_yojson_conv_lib.Yojson_conv.Primitives


let get_env name =
        match Sys.getenv_opt name with
        | Some v when String.trim v <> "" -> String.trim v
        | _ -> failwith (Printf.sprintf "Unable to get env variable with key %s" name) 

let redis_url = lazy (get_env "UPSTASH_REDIS_REST_URL")
let redis_token = lazy (get_env "UPSTASH_REDIS_REST_TOKEN")

let headers () =
        Cohttp.Header.of_list [
                ("Authorization", Printf.sprintf "Bearer %s" (Lazy.force redis_token));
                ("content-type", "application/json")
        ]

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
    Lwt.return (Ok b)
  else
    Lwt.return (Error (
      Cohttp.Code.reason_phrase_of_code code
    ))

type redis_string_reponse = { result: string } [@@deriving yojson]
type redis_int_response = { result: int } [@@deriving yojson]


let parse_json json record_constructor =
        try 
                let parsed =
                       json |> Yojson.Safe.from_string |> record_constructor in
                Some parsed
        with Ppx_yojson_conv_lib.Yojson_conv.Of_yojson_error (exc, _) ->
                let _ =
                        print_endline (Printexc.to_string exc) in
                None

let setex session ttl_seconds user_id =
        let url = Printf.sprintf "%s/setex/sess:%s/%d/%s" (Lazy.force redis_url) session ttl_seconds user_id
        in let* resp = http_get url (headers ()) in 
                match resp with
                | Error _ -> Lwt_result.fail ()
                | Ok body -> 
                        match parse_json body redis_string_reponse_of_yojson with
                        | Some { result = "OK" } -> Lwt_result.return ()
                        | _ -> Lwt_result.fail ()

let get session =
        let url = Printf.sprintf "%s/get/sess:%s" (Lazy.force redis_url) session
        in let* resp = http_get url (headers ()) in 
                match resp with
                | Error _ -> Lwt_result.fail ()
                | Ok body -> 
                        match parse_json body redis_string_reponse_of_yojson with
                        | Some { result } -> Lwt_result.return result
                        | _ -> Lwt_result.fail ()

let delete session =
        let url = Printf.sprintf "%s/del/sess:%s" (Lazy.force redis_url) session
        in let* resp = http_get url (headers ()) in 
                match resp with
                | Error _ -> Lwt_result.fail ()
                | Ok body -> 
                        match parse_json body redis_int_response_of_yojson with
                        | Some { result } -> Lwt_result.return result
                        | _ -> Lwt_result.fail ()



