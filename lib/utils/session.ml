open Ppx_yojson_conv_lib.Yojson_conv.Primitives

let () = Mirage_crypto_rng_unix.use_default ()
let ( let* ) = Lwt.bind

type session_info = { user_id : string } [@@deriving yojson]

let session_token ?(bytes = 32) () =
  let raw = Mirage_crypto_rng.generate bytes in
  Base64.encode_string ~pad:false ~alphabet:Base64.uri_safe_alphabet raw

let rec create_unique_token () =
  let t = session_token () in
  let* resp = Redis.get t in
  match resp with
  | Error e -> Lwt_result.fail e
  | Ok (Some _) -> create_unique_token ()
  | Ok None -> Lwt_result.return t

let parse_session session_text =
  match Http.parse_json session_text session_info_of_yojson with
  | Ok obj -> Some obj
  | Error msg ->
      Dream.log "Unable to parse session %s" msg;
      None

let set_session req resp session_obj =
  let* token = create_unique_token () in
  match token with
  | Error e -> Lwt_result.fail e
  | Ok session -> (
      let* redis_response =
        Redis.setex
          (Printf.sprintf "sess:%s" session)
          (60 * 60 * 24)
          session_obj
      in
      match redis_response with
      | Error e -> Lwt_result.fail e
      | Ok _ -> Lwt_result.return (Dream.set_cookie resp req "session" session))

let is_error r = match r with Error _ -> true | Ok _ -> false

let delete_session req resp =
  match Dream.cookie req "session" with
  | None -> Lwt_result.return ()
  | Some session_info_string -> (
      match parse_session session_info_string with
      | None ->
          Lwt_result.fail (Redis.Unexpected_response "failed to parse_session")
      | Some obj ->
          let* redis_resp =
            Redis.delete (Printf.sprintf "sess:%s" obj.user_id)
          in
          if is_error redis_resp then
            Dream.log "Unable to delete session from redis";
          Dream.drop_cookie resp req "session";
          Lwt_result.return ())

let get_session req =
  match Dream.cookie req "session" with
  | None -> Lwt_result.return None
  | Some token -> (
      let* session_info = Redis.get (Printf.sprintf "sess:%s" token) in
      match session_info with
      | Error msg -> Lwt_result.fail msg
      | Ok session_info_option -> (
          match session_info_option with
          | None -> Lwt_result.return None
          | Some session_info_string -> (
              match parse_session session_info_string with
              | Some obj -> Lwt_result.return (Some obj)
              | None ->
                  Lwt_result.fail
                    (Redis.Unexpected_response "Failed to parse session"))))
