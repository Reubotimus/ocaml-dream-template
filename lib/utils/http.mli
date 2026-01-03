val http_post :
  string ->
  ?body:Cohttp_lwt.Body.t ->
  Cohttp.Header.t ->
  (int * string, int * string) result Lwt.t

val http_get :
  string -> Cohttp.Header.t -> (int * string, int * string) result Lwt.t

val parse_json : string -> (Yojson.Safe.t -> 'a) -> ('a, string) result
