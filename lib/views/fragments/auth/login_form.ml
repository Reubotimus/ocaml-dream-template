let render req =
  Printf.sprintf
    {|
<form 
  hx-post="/auth/login"
  hx-target="#login-feedback"
  hx-swap="innerHTML"
  id="login-form" class="mt-6 grid gap-4">
  <label class="grid gap-2 text-sm font-medium text-slate-700">login
    Email
    <input
      id="login-email"
      class="rounded-xl border border-slate-200 px-4 py-3 text-slate-900 shadow-sm focus:border-slate-400 focus:outline-none"
      placeholder="you@example.com"
      type="email"
      name="email"
      autocomplete="username"
      required
    />
  </label>
  <label class="grid gap-2 text-sm font-medium text-slate-700">
    Password
    <input
      id="login-password"
      class="rounded-xl border border-slate-200 px-4 py-3 text-slate-900 shadow-sm focus:border-slate-400 focus:outline-none"
      placeholder="••••••••"
      type="password"
      name="password"
      autocomplete="current-password"
      required
    />
  </label>
  <div id="login-feedback"></div>
  %s
  <button
    id="login-submit"
    class="rounded-xl bg-slate-900 px-4 py-3 text-sm font-semibold text-white shadow-sm hover:bg-slate-800"
    type="submit"
  >
    Sign in
  </button>
</form>
|}
    (Dream.csrf_tag req)
