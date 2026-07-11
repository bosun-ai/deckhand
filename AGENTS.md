# Repository Guidelines

## Project Structure & Module Organization
- Rails app code lives in `app/` (`controllers/`, `models/`, `views/`, `jobs/`, and `agents/` for autonomous workflows).
- Shared Ruby logic is in `lib/` (notably `lib/autonomous_agent` and `lib/deckhand`).
- Frontend TypeScript and Stimulus controllers are in `app/javascript/` with Vite entrypoints in `app/javascript/entrypoints/`.
- Tests use Minitest and are organized under `test/` by type (`test/models`, `test/controllers`, `test/system`, `test/agents`, etc.).
- Configuration and environment setup are in `config/`, database schema/migrations in `db/`, and static assets in `public/`.

## Build, Test, and Development Commands
- `bundle install && npm install` — install Ruby and Node dependencies.
- `bin/setup` — bootstrap local development dependencies and database.
- `bin/dev` — start the local dev stack (Rails server + Tailwind/Vite processes via `Procfile.dev`).
- `bin/rails db:prepare` — create/migrate database for current environment.
- `bin/rake test` — run the full Minitest suite (matches CI test command).
- `bundle exec rubocop --parallel` — run Ruby lint checks.
- `bundle exec brakeman` and `bundle exec bundle-audit --update` — run security checks used in CI.

## Coding Style & Naming Conventions
- Follow idiomatic Rails conventions and keep methods/classes focused.
- Use 2-space indentation for Ruby; prefer descriptive snake_case names for files, methods, and variables.
- Use CamelCase for Ruby classes/modules and PascalCase class names in TypeScript where applicable.
- Keep Stimulus controllers in `app/javascript/controllers/*_controller.ts`.
- Enforce style with RuboCop (`.rubocop.yml` enables new cops) and format Ruby with `rufo` when needed.

## Testing Guidelines
- Framework: Minitest (`rails/test_help`) with fixtures in `test/fixtures` and Mocha available for stubs/mocks.
- Name test files with `_test.rb` and mirror source structure (example: `app/models/codebase.rb` → `test/models/codebase_test.rb`).
- Add focused tests for bug fixes and new behavior, then run at least the related file(s) before full suite.
- Run a specific test with `bin/rails test test/models/codebase_test.rb`.

## Commit & Pull Request Guidelines
- Prefer short, imperative commit messages (examples in history: `move to root`, `fix dumb ... bug`).
- Keep commits scoped to one change; include context in the body when behavior or data flow changes.
- PRs should include: objective, key implementation notes, test evidence (`bin/rake test` output), and linked issue(s).
- Include screenshots/GIFs for UI changes (`app/views`, Tailwind/Stimulus updates).
- Ensure CI expectations pass locally: tests, RuboCop, Brakeman, and bundle-audit.
