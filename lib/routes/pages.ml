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

let render_layout ~title ~(body : string) =
  let safe_title = Dream.html_escape title in
  render_template ~template:"layouts/base.html"
    ~vars:[ ("title", safe_title); ("body", body) ]

let render_home () =
  let body = render_template ~template:"pages/home.html" ~vars:[] in
  render_layout ~title:"Public page" ~body

let render_protected () =
  let body = render_template ~template:"pages/protected.html" ~vars:[] in
  render_layout ~title:"Protected page" ~body

let render_login req =
  let csrf_tag = Dream.csrf_tag req in
  let body =
    render_template ~template:"pages/login.html"
      ~vars:[ ("csrf_tag", csrf_tag) ]
  in
  render_layout ~title:"Login" ~body

let routes : Dream.route list =
  [
    Dream.get "/" (fun _ -> Dream.html (render_home ()));
    Dream.get "/protected" (fun _ -> Dream.html (render_protected ()));
    Dream.get "/login" (fun req -> Dream.html (render_login req));
  ]
