let ( let* ) = Lwt.bind

let string_of_redis_error = function
  | Utils.Redis.Http_error msg -> "http_error: " ^ msg
  | Utils.Redis.Json_parse_error msg -> "json_parse_error: " ^ msg
  | Utils.Redis.Redis_error msg -> "redis_error: " ^ msg
  | Utils.Redis.Unexpected_response msg -> "unexpected_response: " ^ msg

let routes : Dream.route list =
  [
    Dream.get "/redis/set/:key/:ttl/:value" (fun request ->
        let key = Dream.param request "key" in
        let ttl_str = Dream.param request "ttl" in
        let value = Dream.param request "value" in
        match int_of_string_opt ttl_str with
        | None ->
            Dream.respond ~status:`Bad_Request "ttl must be an int"
        | Some ttl ->
            let* result = Utils.Redis.setex key ttl value in
            (match result with
            | Ok () -> Dream.respond "ok"
            | Error err ->
                Dream.respond ~status:`Internal_Server_Error
                  (string_of_redis_error err)));
    Dream.get "/redis/get/:key" (fun request ->
        let key = Dream.param request "key" in
        let* result = Utils.Redis.get key in
        match result with
        | Ok (Some value) -> Dream.respond value
        | Ok None -> Dream.respond ~status:`Not_Found "missing"
        | Error err ->
            Dream.respond ~status:`Internal_Server_Error
              (string_of_redis_error err));
    Dream.get "/redis/del/:key" (fun request ->
        let key = Dream.param request "key" in
        let* result = Utils.Redis.delete key in
        match result with
        | Ok count -> Dream.respond (string_of_int count)
        | Error err ->
            Dream.respond ~status:`Internal_Server_Error
              (string_of_redis_error err));
  ]
