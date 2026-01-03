let () =
  Dotenv.export ();
  let secret = Learning_app.Env.server_secret () in
  Dream.run @@ Dream.logger @@ Dream.set_secret secret @@ Dream.cookie_sessions
  @@ Learning_app.App.handler
