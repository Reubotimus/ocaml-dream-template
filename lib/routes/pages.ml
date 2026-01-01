let routes : Dream.route list =
  [
    Dream.get "/" (fun _ -> Dream.html (Views.Pages.Home.render ()));
    Dream.get "/protected" (fun _ ->
        Dream.html (Views.Pages.Protected.render ()));
    Dream.get "/login" (fun _ -> Dream.html (Views.Pages.Login.render ()));
  ]


