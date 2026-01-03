let get_env name =
  match Sys.getenv_opt name with
  | Some v when String.trim v <> "" -> String.trim v
  | _ -> failwith (Printf.sprintf "Unable to get env variable with key %s" name)

let redis_url () = get_env "UPSTASH_REDIS_REST_URL"
let redis_token () = get_env "UPSTASH_REDIS_REST_TOKEN"
let supabase_key () = get_env "SUPABASE_ANON_KEY"
let supabase_url () = get_env "SUPABASE_URL"
let server_secret () = get_env "SERVER_SECRET"

let require_all () =
  ignore (redis_url ());
  ignore (redis_token ());
  ignore (supabase_key ());
  ignore (supabase_url ());
  ignore (server_secret ())
