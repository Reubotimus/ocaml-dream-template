let routes : Dream.route list =
  [
    Dream.get "/" (fun _ -> Dream.html (Views.Pages.Home.render ()));
  ]

