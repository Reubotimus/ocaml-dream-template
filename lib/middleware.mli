val session_field : Utils.Session.session_info Dream.field
val session : Dream.request -> Utils.Session.session_info option

val requires_auth :
  (Dream.request -> Dream.response Lwt.t) ->
  Dream.request ->
  Dream.response Lwt.t
