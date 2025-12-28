let render () =
  Layout.Base.render ~title:"Protected page"
    ~body:
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
