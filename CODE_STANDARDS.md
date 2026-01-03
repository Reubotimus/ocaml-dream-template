# High-Quality OCaml Backend Code

**Best Practices and Antipatterns (Opinionated)**

---

## Readability is the Primary Goal

* Write code a teammate can understand in 30 seconds.
* Prefer explicit `let` bindings over clever composition.
* Keep functions small. If a function needs scrolling, split it.
* Avoid “smart” one-liners when two lines are clearer.
* Use consistent naming:

  * `snake_case` for values and functions
  * `PascalCase` for modules and variant constructors
* Use `ocamlformat` and commit to it. Don’t bikeshed formatting.
* Never put `;;` in source files. That’s REPL-only.

---

## Module Structure Is How You Scale

* Every non-trivial module gets an `.mli`.
* Default to information hiding:

  * Expose abstract types (`type t`) unless callers truly need the representation.
  * Expose constructors only when pattern matching is part of the public API.
* Make modules single-purpose. A `Utils` module is usually a smell.
* Keep dependency direction one-way. If you hit cycles, your boundaries are wrong:

  * Move shared types into a separate module.
  * Introduce an interface and dependency injection (module parameter or record of functions).
* Be conservative with `open`:

  * Local `open` inside a function is fine.
  * Global `open` of large modules is usually a mistake.
  * Prefer explicit module prefixes so readers can tell where names come from.

---

## Error Handling: Stop Using Exceptions for Expected Outcomes

* Exceptions are for programmer errors and truly unexpected states.
* For anything that can reasonably fail in production, use explicit error values:

  * `('a, error) result`
  * `'a option` only when “missing” is the entire story; otherwise use `result` with a real error.
* Treat partial functions as banned in application code:

  * Don’t call `List.hd`, `List.nth`, `Option.get`, `Hashtbl.find` (exception-throwing versions).
  * Pattern-match or use safe variants.
* Centralize error conversion at boundaries:

  * Parse and validate input at the edge (HTTP, env vars, JSON).
  * Convert low-level library exceptions into your error type once.
* In Dream handlers:

  * Make the happy path linear.
  * Handle errors in one place and map them to HTTP responses.

---

## Dream / Lwt Discipline for Backend Code

* No blocking operations in request handlers. Ever.

  * If a library call blocks, isolate it (thread pool, worker process, or domain).
* Don’t create nested event loops:

  * Never call `Lwt_main.run` anywhere except the program entrypoint (and often not even there).
* Treat fire-and-forget as dangerous:

  * If you use `Lwt.async`, you must log failures.
  * Background failures should be visible and actionable.
* Use middleware (Dream filters) aggressively for cross-cutting concerns:

  * Auth, logging, request IDs, error mapping, CSRF, limits.
  * Don’t duplicate these checks in each route.
* Keep handlers thin:

  * Handler = translate HTTP → call domain function → translate result → response.
  * Domain logic lives elsewhere and is testable without HTTP.

---

## Data Modeling: Make Illegal States Unrepresentable

* Define types that encode your business rules:

  * Use variants for states and modes instead of strings or ints.
  * Use new types or modules for IDs so they can’t be mixed up.
* Pattern matching is your control flow:

  * Avoid catch-all `_` when you really mean “handle all cases”.
  * Exhaustiveness warnings are a feature, not noise.
* Prefer total functions:

  * If a function can’t handle some input, change the type or return an explicit error.

---

## Mutability: Allowed, but Only Behind Walls

* Default to immutable values and pure functions.
* If you need mutation (caches, counters, pools), encapsulate it in a module with a small API.
* Avoid mutable globals.

  * If unavoidable, initialize once and treat as read-only.
* Be explicit about concurrency safety for shared state.

---

## Performance: Be Boring First, Then Measure

* Don’t pre-optimize. Measure real hotspots.
* Avoid allocation-heavy pipelines in hot paths:

  * Minimize intermediate lists and strings.
  * Use `Buffer` for large string construction.
  * Prefer single-pass folds over `map → filter → map` when it matters.
* Pick correct algorithms and data structures before micro-optimizing.
* Keep CPU-heavy work off the async scheduler:

  * Offload to workers and treat them like services.
* Keep request paths simple:

  * Avoid repeated parsing.
  * Cache derived values inside request scope if reused.

---

## Testing and Correctness Practices That Pay Off

* Heavily unit-test pure domain logic.
* Integration-test critical Dream routes (auth, writes, payments).
* Turn warnings into errors in Dune for application code.

  * Treat non-exhaustive matches and unused values as build failures.

---

## Common OCaml Antipatterns to Actively Avoid

* God modules and giant files.
* Catch-all exception handlers that swallow detail.
* Exceptions used for normal control flow.
* Partial functions called on “trusted” input.
* Massive `open` usage that hides name origins.
* Request handlers that mix parsing, logic, DB, and rendering.
* Hand-built SQL or JSON when safe libraries exist.
* Overusing PPX until behavior is opaque.
* “Utils” dumping grounds instead of focused modules.

---

## A Simple, High-Quality Dream Project Shape

* `lib/`

  * `domain/` – pure types and business logic
  * `infra/` – database, external APIs, config
  * `web/` – routes, middleware, HTTP translation
* `bin/`

  * `main.ml` – wiring: config, infra init, routes, run

**Dependency direction**

* `web → domain + infra`
* `infra → domain` (sometimes)
* `domain → nothing`
