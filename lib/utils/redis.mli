type redis_error =
  | Http_error of string
  | Json_parse_error of string
  | Redis_error of string
  | Unexpected_response of string

val setex : string -> int -> string -> (unit, redis_error) result Lwt.t
val get : string -> (string option, redis_error) result Lwt.t
val delete : string -> (int, redis_error) result Lwt.t
