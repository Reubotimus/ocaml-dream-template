let base_dir = "templates"

let read_file path =
  let ic = open_in_bin path in
  Fun.protect
    ~finally:(fun () -> close_in_noerr ic)
    (fun () ->
      let len = in_channel_length ic in
      really_input_string ic len)

let cache : (string, string) Hashtbl.t = Hashtbl.create 16

let load template =
  match Hashtbl.find_opt cache template with
  | Some contents -> contents
  | None ->
      let path = Filename.concat base_dir template in
      let contents = read_file path in
      Hashtbl.add cache template contents;
      contents

let preload () =
  let templates =
    [
      "layouts/base.html";
      "pages/home.html";
      "pages/protected.html";
      "pages/login.html";
    ]
  in
  List.iter (fun template -> ignore (load template)) templates

let replace_all ~pattern ~with_ source =
  if pattern = "" then source
  else
    let source_len = String.length source in
    let pattern_len = String.length pattern in
    let buf = Buffer.create source_len in
    let rec loop i =
      if i > source_len - pattern_len then (
        if i < source_len then Buffer.add_substring buf source i (source_len - i))
      else if String.sub source i pattern_len = pattern then (
        Buffer.add_string buf with_;
        loop (i + pattern_len))
      else (
        Buffer.add_char buf source.[i];
        loop (i + 1))
    in
    loop 0;
    Buffer.contents buf

let render_template ~template ~vars =
  let contents = load template in
  List.fold_left
    (fun acc (key, value) ->
      let pattern = "{{" ^ key ^ "}}" in
      replace_all ~pattern ~with_:value acc)
    contents vars

let render_layout ~title ~auth_link ~(body : string) =
  let safe_title = Dream.html_escape title in
  render_template ~template:"layouts/base.html"
    ~vars:[ ("title", safe_title); ("body", body); ("auth_link", auth_link) ]

let logout_form ~form_class ~button_class ~label =
  Printf.sprintf
    "<form class=\"%s\" method=\"post\" action=\"/auth/logout\"><button \
     class=\"%s\" type=\"submit\">%s</button></form>"
    form_class button_class label

let auth_link logged_in =
  if logged_in then
    logout_form ~form_class:"inline"
      ~button_class:"rounded-lg px-3 py-2 transition hover:bg-slate-100"
      ~label:"Log out"
  else
    "<a class=\"rounded-lg px-3 py-2 transition hover:bg-slate-100\" \
     href=\"/login\">Login</a>"

let auth_action logged_in =
  if logged_in then
    logout_form ~form_class:"inline"
      ~button_class:
        "rounded-xl bg-slate-900 px-4 py-2 text-white shadow-sm \
         hover:bg-slate-800"
      ~label:"Log out"
  else
    "<a class=\"rounded-xl bg-emerald-500 px-4 py-2 text-white shadow-sm \
     hover:bg-emerald-600\" href=\"/login\">Visit the sign-in page</a>"

let render_home ~auth_link ~auth_action =
  let body =
    render_template ~template:"pages/home.html"
      ~vars:[ ("auth_action", auth_action) ]
  in
  render_layout ~title:"Public page" ~auth_link ~body

let render_protected ~auth_link ~auth_action =
  let body =
    render_template ~template:"pages/protected.html"
      ~vars:[ ("auth_action", auth_action) ]
  in
  render_layout ~title:"Protected page" ~auth_link ~body

let render_login req ~auth_link =
  let csrf_tag = Dream.csrf_tag req in
  let redirect =
    match Dream.query req "redirect" with
    | Some path when String.length path > 0 && path.[0] = '/' -> path
    | _ -> "/protected"
  in
  let safe_redirect = Dream.html_escape redirect in
  let body =
    render_template ~template:"pages/login.html"
      ~vars:[ ("csrf_tag", csrf_tag); ("redirect", safe_redirect) ]
  in
  render_layout ~title:"Login" ~auth_link ~body

let string_of_redis_error e =
  match e with
  | Utils.Redis.Http_error m -> Format.sprintf "Http_error: %s" m
  | Utils.Redis.Json_parse_error m -> Format.sprintf "Json_parse_error: %s" m
  | Utils.Redis.Redis_error m -> Format.sprintf "Redis_error: %s" m
  | Utils.Redis.Unexpected_response m ->
      Format.sprintf "Unexpected_response: %s" m

let logged_in_from_req req =
  let ( let* ) = Lwt.bind in
  let* session_result = Utils.Session.get_session req in
  match session_result with
  | Ok (Some _) -> Lwt.return true
  | Ok None -> Lwt.return false
  | Error err ->
      Dream.log "Unable to read session for auth link: %s"
        (string_of_redis_error err);
      Lwt.return false

let routes : Dream.route list =
  [
    Dream.get "/" (fun req ->
        let ( let* ) = Lwt.bind in
        let* logged_in = logged_in_from_req req in
        Dream.html
          (render_home ~auth_link:(auth_link logged_in)
             ~auth_action:(auth_action logged_in)));
    Dream.get "/protected"
      (Middleware.requires_auth (fun _ ->
           Dream.html
             (render_protected ~auth_link:(auth_link true)
                ~auth_action:(auth_action true))));
    Dream.get "/login" (fun req ->
        let ( let* ) = Lwt.bind in
        let* session_result = Utils.Session.get_session req in
        match session_result with
        | Ok (Some _) -> Dream.redirect req "/protected"
        | Ok None -> Dream.html (render_login req ~auth_link:(auth_link false))
        | Error err ->
            Dream.log "Unable to read session for login page: %s"
              (string_of_redis_error err);
            Dream.html (render_login req ~auth_link:(auth_link false)));
  ]
