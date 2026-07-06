# Repository Guidelines

## Project Structure & Module Organization
This is a Rails 7.1 application with Vite and Tailwind.

- `app/`: main application code (`controllers`, `models`, `views`, `jobs`, `mailers`, `helpers`), plus agent logic under `app/agents/` and frontend code in `app/javascript/`.
- `test/`: Minitest suite organized by type (`models`, `controllers`, `integration`, `system`, etc.).
- `config/`: Rails, environment, and initializer configuration.
- `lib/`: reusable Ruby modules and rake tasks (`lib/tasks/*.rake`).
- `db/`: migrations and schema.
- `public/`, `app/assets/`: static and compiled assets.

## Build, Test, and Development Commands
- `bin/setup`: install gems, prepare DB, clear logs/tmp.
- `bin/dev`: start local stack via `Procfile.dev` (Puma + Tailwind watcher + Vite dev server).
- `bin/rails db:prepare`: create/migrate database.
- `bin/rails test`: run all tests.
- `bin/rails test test/integration/<file>_test.rb`: run a focused test file.
- `bundle exec rubocop`: run Ruby lint/style checks.
- `bundle exec brakeman`: run Rails security scan.

## Coding Style & Naming Conventions
- Follow existing Rails conventions: `snake_case` filenames/methods, `CamelCase` classes/modules.
- RuboCop is configured in `.rubocop.yml`; run it before opening a PR.
- Use 2-space indentation in Ruby files; keep methods focused and small when practical.
- Keep Stimulus controllers in `app/javascript/controllers/*_controller.js`.

## Testing Guidelines
- Framework: Minitest (`test/test_helper.rb`) with Capybara for system tests.
- Name tests as `*_test.rb` and mirror app paths when possible (e.g., `app/models/user.rb` → `test/models/user_test.rb`).
- Prefer targeted test runs first, then full suite (`bin/rails test`).
- Add regression tests for bug fixes and integration/system coverage for user-visible behavior.

## Commit & Pull Request Guidelines
- Commit messages in this repo are short, imperative, and lowercase (e.g., `fix events endpoint`); optional issue refs like `(#24)` are used.
- Keep commits focused on one logical change.
- PRs should include: purpose, key changes, test evidence (commands run), and screenshots/GIFs for UI changes.
- Link related issues/tasks and call out migrations or config/env changes explicitly.

## Security & Configuration Tips
- Do not commit secrets. Use `.env` for local development (`OPENAI_ACCESS_TOKEN`, `GITHUB_APP_KEY`, etc., per `README.md`).
- If dependencies change, run both Ruby and JS installers (`bundle install`, `npm install`) and verify `bin/dev` boots cleanly.
