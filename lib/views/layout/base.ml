let render ~title ~(body : string) =
  let safe_title = Dream.html_escape title in
  Printf.sprintf
    {|
<!doctype html>
<html lang="en">
  <head>
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <link rel="stylesheet" href="/static/app.css" />
    <title>%s</title>
    <script src="https://unpkg.com/htmx.org@1.9.12"></script>
  </head>
  <body class="min-h-screen bg-slate-50 text-slate-900">
    <div class="mx-auto flex min-h-screen max-w-3xl flex-col gap-8 px-6 py-12">
      <nav class="flex flex-wrap items-center justify-between gap-4 rounded-2xl border border-slate-200 bg-white px-5 py-4 shadow-sm">
        <div class="text-sm font-semibold uppercase tracking-widest text-slate-500">Learning App</div>
        <div class="flex flex-wrap items-center gap-3 text-sm font-medium text-slate-700">
          <a class="rounded-lg px-3 py-2 transition hover:bg-slate-100" href="/">Home</a>
          <a class="rounded-lg px-3 py-2 transition hover:bg-slate-100" href="/protected">Protected</a>
          <a class="rounded-lg px-3 py-2 transition hover:bg-slate-100" href="/login">Login</a>
        </div>
      </nav>
      <main>
        %s
      </main>
    </div>
  </body>
</html>
|}
    safe_title body
