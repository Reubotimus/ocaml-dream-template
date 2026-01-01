let handler =
  Dream.router
    (List.concat
       [
         Routes.Health.routes;
         Routes.Pages.routes;
         Routes.Redis.routes;
         [ Dream.get "/static/**" (Dream.static "static") ];
       ])
