let render () =
  {|
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
|}
