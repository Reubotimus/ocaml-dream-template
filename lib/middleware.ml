let session_field : Utils.Session.session_info Dream.field = Dream.new_field ()

let session req = Dream.field req session_field

let requires_auth handler req =
  let ( let* ) = Lwt.bind in
  let* session_result = Utils.Session.get_session req in
  match session_result with
  | Error _ ->
      let redirect =
        Dream.target req |> Uri.pct_encode |> fun path -> "/login?redirect=" ^ path
      in
      Dream.redirect req redirect
  | Ok None ->
      let redirect =
        Dream.target req |> Uri.pct_encode |> fun path -> "/login?redirect=" ^ path
      in
      Dream.redirect req redirect
  | Ok (Some session_info) ->
      Dream.set_field req session_field session_info;
      handler req
