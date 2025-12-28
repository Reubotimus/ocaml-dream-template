let handler =
  Dream.router
    (List.concat
       [
         Routes.Health.routes;
         Routes.Pages.routes;
         [ Dream.get "/static/**" (Dream.static "static") ];
       ])
