type supabase_error =
  | Http_error of string
  | Unauthorised of string
  | Response_parse_error of string
  | Unexpected_error of string

type supabase_login_response = { user_id : string }

val supabase_login :
  string -> string -> (supabase_login_response, supabase_error) result Lwt.t

val logout : string -> (unit, supabase_error) result Lwt.t
