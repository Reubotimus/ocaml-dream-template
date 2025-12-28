let page ~title ~(body : string) =
  Printf.sprintf
    {|
<!doctype html>
<html lang="en">
  <head>
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <title>%s</title>
    <script src="https://unpkg.com/htmx.org@1.9.12"></script>
  </head>
  <body>
    <nav>
      <a href="/tasks">Tasks</a>
    </nav>
    <main>
      %s
    </main>
  </body>
</html>
|}
    title body
