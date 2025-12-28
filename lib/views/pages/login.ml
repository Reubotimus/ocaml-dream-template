let render () =
  let login_form = Fragments.Auth.Login_form.render () in
  Layout.Base.render ~title:"Login"
    ~body:
      (Printf.sprintf
         {|
<section class="rounded-3xl border border-slate-200 bg-white p-8 shadow-sm">
  <div class="text-sm font-semibold uppercase tracking-widest text-sky-500">Login</div>
  <h1 class="mt-3 text-3xl font-bold tracking-tight text-slate-900">Sign in to continue</h1>
  <p class="mt-4 text-base leading-7 text-slate-600">
    Authentication is not wired up yet. This form is for layout only.
  </p>
  %s
  <p class="mt-6 text-sm text-slate-500">
    Need access? When auth exists, you will sign in here and return to
    <a class="font-semibold text-slate-700 hover:text-slate-900" href="/protected">protected</a>.
  </p>
</section>
|}
         login_form)
