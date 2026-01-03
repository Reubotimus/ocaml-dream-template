let () =
  Dotenv.export ();
  Learning_app.Env.require_all ();
  Learning_app.Routes.Pages.preload ();
  let secret = Learning_app.Env.server_secret () in
  Dream.run @@ Dream.logger @@ Dream.set_secret secret @@ Dream.cookie_sessions
  @@ Learning_app.App.handler
