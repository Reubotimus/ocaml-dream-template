# Middleware

## requires_auth

`requires_auth` uses `Utils.Session.get_session` to look up the session in Redis.
If session lookup fails or returns `None`, it redirects to `/login`.
On success it stores the session on the request via `Dream.set_field`.

The session can be read inside a handler with:

```ocaml
let session = Middleware.session req
```

## Example usage

```ocaml
Dream.get "/protected" (Middleware.requires_auth (fun req ->
  let _session = Middleware.session req in
  Dream.html "protected"
))
```
