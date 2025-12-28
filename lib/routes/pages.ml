let layout ~title ~body =
  Printf.sprintf
    {|
<!doctype html>
<html lang="en">
  <head>
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <link rel="stylesheet" href="/static/app.css" />
    <title>%s</title>
  </head>
  <body class="min-h-screen bg-slate-50 text-slate-900">
    <div class="mx-auto flex min-h-screen max-w-3xl flex-col gap-8 px-6 py-12">
      %s
    </div>
  </body>
</html>
|}
    title body

let nav =
  {|
<nav class="flex flex-wrap items-center justify-between gap-4 rounded-2xl border border-slate-200 bg-white px-5 py-4 shadow-sm">
  <div class="text-sm font-semibold uppercase tracking-widest text-slate-500">Learning App</div>
  <div class="flex flex-wrap items-center gap-3 text-sm font-medium text-slate-700">
    <a class="rounded-lg px-3 py-2 transition hover:bg-slate-100" href="/">Home</a>
    <a class="rounded-lg px-3 py-2 transition hover:bg-slate-100" href="/protected">Protected</a>
    <a class="rounded-lg px-3 py-2 transition hover:bg-slate-100" href="/login">Login</a>
  </div>
</nav>
|}

let public_page =
  {|
<section class="rounded-3xl border border-slate-200 bg-white p-8 shadow-sm">
  <div class="text-sm font-semibold uppercase tracking-widest text-emerald-500">Public</div>
  <h1 class="mt-3 text-3xl font-bold tracking-tight text-slate-900">Welcome to the open page</h1>
  <p class="mt-4 text-base leading-7 text-slate-600">
    This page is accessible without signing in. Use it to explore the app structure
    and link out to the protected area when authentication is wired up.
  </p>
  <div class="mt-6 flex flex-wrap gap-3 text-sm font-medium">
    <a class="rounded-xl bg-emerald-500 px-4 py-2 text-white shadow-sm hover:bg-emerald-600" href="/login">
      Head to login
    </a>
    <a class="rounded-xl border border-slate-200 px-4 py-2 text-slate-700 hover:bg-slate-100" href="/protected">
      Peek at protected page
    </a>
  </div>
</section>
|}

let protected_page =
  {|
<section class="rounded-3xl border border-slate-200 bg-white p-8 shadow-sm">
  <div class="text-sm font-semibold uppercase tracking-widest text-amber-500">Protected</div>
  <h1 class="mt-3 text-3xl font-bold tracking-tight text-slate-900">Members-only area</h1>
  <p class="mt-4 text-base leading-7 text-slate-600">
    This page is marked as protected, but authentication is not implemented yet.
    Once auth is in place, unauthenticated visitors should be redirected to login.
  </p>
  <div class="mt-6 flex flex-wrap gap-3 text-sm font-medium">
    <a class="rounded-xl bg-slate-900 px-4 py-2 text-white shadow-sm hover:bg-slate-800" href="/login">
      Go to login
    </a>
    <a class="rounded-xl border border-slate-200 px-4 py-2 text-slate-700 hover:bg-slate-100" href="/">
      Back home
    </a>
  </div>
</section>
|}

let login_page =
  {|
<section class="rounded-3xl border border-slate-200 bg-white p-8 shadow-sm">
  <div class="text-sm font-semibold uppercase tracking-widest text-sky-500">Login</div>
  <h1 class="mt-3 text-3xl font-bold tracking-tight text-slate-900">Sign in to continue</h1>
  <p class="mt-4 text-base leading-7 text-slate-600">
    Authentication is not wired up yet. This form is for layout only.
  </p>
  <form class="mt-6 grid gap-4">
    <label class="grid gap-2 text-sm font-medium text-slate-700">
      Email
      <input
        class="rounded-xl border border-slate-200 px-4 py-3 text-slate-900 shadow-sm focus:border-slate-400 focus:outline-none"
        placeholder="you@example.com"
        type="email"
      />
    </label>
    <label class="grid gap-2 text-sm font-medium text-slate-700">
      Password
      <input
        class="rounded-xl border border-slate-200 px-4 py-3 text-slate-900 shadow-sm focus:border-slate-400 focus:outline-none"
        placeholder="••••••••"
        type="password"
      />
    </label>
    <button
      class="rounded-xl bg-slate-900 px-4 py-3 text-sm font-semibold text-white shadow-sm hover:bg-slate-800"
      type="button"
    >
      Sign in (disabled)
    </button>
  </form>
  <p class="mt-6 text-sm text-slate-500">
    Need access? When auth exists, you will sign in here and return to
    <a class="font-semibold text-slate-700 hover:text-slate-900" href="/protected">protected</a>.
  </p>
</section>
|}

let routes : Dream.route list =
  [
    Dream.get "/" (fun _ ->
        Dream.html (layout ~title:"Public page" ~body:(nav ^ public_page)));
    Dream.get "/protected" (fun _ ->
        Dream.html (layout ~title:"Protected page" ~body:(nav ^ protected_page)));
    Dream.get "/login" (fun _ ->
        Dream.html (layout ~title:"Login" ~body:(nav ^ login_page)));
  ]
