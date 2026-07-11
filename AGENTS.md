# Repository Guidelines

## Project Structure & Module Organization
This is a Rails 7.1 app with Vite-powered frontend assets.

- `app/` contains Rails MVC code plus domain agents (`app/agents/`) and JS entrypoints/controllers (`app/javascript/`).
- `config/`, `db/`, and `lib/` hold environment config, schema/migrations, and shared Ruby code.
- `test/` uses Minitest and is split by type (`controllers/`, `models/`, `integration/`, `system/`, `agents/`, `libs/`).
- `public/`, `storage/`, and `app/assets/` contain static and generated assets.

## Build, Test, and Development Commands
Use project binstubs so versions and environment stay consistent.

- `bin/setup` — install gems, prepare DB, clear temp/logs.
- `npm install` — install frontend dependencies used by Vite/Tailwind.
- `bin/dev` — start local dev stack via `Procfile.dev` (Rails, Tailwind watch, Vite).
- `bin/rails db:prepare` — create/migrate DB for current environment.
- `bin/rails test` or `bin/rake test` — run full test suite.
- `bundle exec rubocop --parallel` — Ruby style/lint checks.
- `bundle exec brakeman` and `bundle exec bundle-audit --update` — security checks.

## Coding Style & Naming Conventions
- Follow existing Rails conventions: classes/modules in `CamelCase`, files/methods in `snake_case`.
- Prefer small, focused service/agent classes under `app/agents` and `lib`.
- RuboCop is the primary style authority (`.rubocop.yml`); run it before opening a PR.
- JS in `app/javascript` should follow Stimulus/Vite patterns already present in `controllers/` and `entrypoints/`.

## Testing Guidelines
- Framework: Minitest (`test/test_helper.rb`) with fixtures and parallel test workers enabled.
- Name tests with `_test.rb` and mirror source structure where practical.
- Add regression tests for bug fixes and integration/system tests for user-visible flows.
- Run targeted tests first (example: `bin/rails test test/models/codebase_test.rb`), then full suite.

## Commit & Pull Request Guidelines
- Keep commits small, imperative, and focused (history favors short action-oriented messages).
- In PRs, include: what changed, why, and how it was validated.
- Link related issues, note migrations/config changes, and add screenshots for UI updates.
- Ensure CI-relevant checks pass locally (tests, RuboCop, and security scans) before review.

## Security & Configuration Tips
- Keep secrets in `.env`; never commit credentials or private keys.
- Required local env values are documented in `README.md` (OpenAI, GitHub App, Redis).
- Verify `REDIS_URL` and database settings before running background/agent-heavy workflows.
