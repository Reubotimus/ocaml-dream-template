type session_info = { user_id : string }

type delete_outcome =
  [ `No_session | `Deleted | `Redis_error of Redis.redis_error ]

val set_session :
  Dream.request ->
  Dream.response ->
  string ->
  (unit, Redis.redis_error) result Lwt.t

val delete_session :
  Dream.request ->
  (delete_outcome -> Dream.response Lwt.t) ->
  Dream.response Lwt.t

val get_session :
  Dream.request -> (session_info option, Redis.redis_error) result Lwt.t
