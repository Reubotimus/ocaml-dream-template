# Repository Guidelines

## Project Structure & Module Organization
- `bin/` holds the entrypoint (`main.ml`) and executable wiring.
- `lib/` contains the core Dream app, routes, views, and utilities:
  - `lib/routes/` for HTTP route definitions.
  - `lib/views/` for HTML layout and page rendering.
  - `lib/utils/` for shared helpers (auth, redis, http, session).
- `static/` hosts frontend assets (Tailwind input CSS, JS auth helpers).
- `test/` contains the OCaml test suite.

## Build, Test, and Development Commands
- `dune build` compiles the library and executable.
- `dune exec learning-app` runs the app locally.
- `dune runtest` runs the OCaml tests in `test/`.
- `opam exec -- dune fmt` formats OCaml sources with the project formatter.
- `npx tailwindcss -i static/input.css -o static/output.css` builds CSS from Tailwind (adjust output path as needed for your workflow).

## Coding Style & Naming Conventions
- OCaml: use 2-space indentation, no tabs, and keep modules aligned with file names (e.g., `lib/routes/auth.ml` defines `Routes.Auth`).
- Files and directories use `snake_case`; module names follow OCaml’s `CamelCase` convention.
- JavaScript in `static/js/` follows the existing file style; prefer the local indentation and naming patterns you see nearby.
- Keep functions small and pure where possible; route handlers should remain thin and delegate to `lib/utils/`.

## Testing Guidelines
- Tests live in `test/` and are run via `dune runtest`.
- Name test files after the library or feature under test (e.g., `test_learning_app.ml`).
- Add tests for new routes and utility behavior; keep network calls mocked or isolated.

## Commit & Pull Request Guidelines
- Commit messages in this repo are short, lowercase, and topic-focused (e.g., `added redis`, `supabase auth`). Follow that style unless the team agrees otherwise.
- Pull requests should include a concise description, steps to verify, and screenshots for UI changes affecting `lib/views/` or `static/`.

## Configuration & Secrets
- Runtime config is read from environment variables (`UPSTASH_REDIS_REST_URL`, `SUPABASE_URL`, `SERVER_SECRET`, etc.).
- Use a local `.env` file with `dotenv` when developing; never commit secrets.
