# Repository Guidelines

## Project Structure & Module Organization

- **Source Code**: Ruby on Rails application with source files in `app/` (controllers, models, views), `lib/` (custom modules), and `config/` (configuration).
- **Tests**: Located in `test/` with Rails-standard directories (`system/`, `integration/`, `models/`, etc.).
- **Frontend Assets**: Managed in `app/assets/` and `app/javascript/`, built with Vite and Tailwind CSS.
- **Dependencies**: Ruby gems in `Gemfile` and JavaScript packages in `package.json`.

## Build, Test, and Development Commands

- **Install Dependencies**: `bundle` (Ruby), `npm install` (JavaScript).
- **Run Locally**: `./bin/dev` (starts Rails server, Vite, and Tailwind).
- **Test**: `rails test` (runs all tests), `rails test test/models/` (run model tests).
- **Lint**: `rubocop` (check Ruby style), `rubocop -A` (auto-correct).
- **Docker Development**: `docker-compose up` (starts app, Redis, and PostgreSQL).

## Coding Style & Naming Conventions

- **Ruby**: Follows RuboCop rules (see `.rubocop.yml`). Use snake_case for variables and methods, and disable frozen string literals.
- **JavaScript**: Uses ESM modules with Vite. Follows modern JS conventions.
- **Naming**: Use descriptive, clear names. For Rails, follow conventions (e.g., `UserController`, `user_model.rb`).

## Testing Guidelines

- **Framework**: Rails' built-in Minitest with `mocha/minitest` for mocking.
- **Test Location**: Mirror `app/` structure in `test/` (e.g., `app/models/user.rb` → `test/models/user_test.rb`).
- **Run Tests**: `rails test` (all), `rails test test/integration/` (specific directory).
- **Parallel Testing**: Enabled by default (see `test_helper.rb`).

## Commit & Pull Request Guidelines

- **Commit Messages**: Use imperative mood (e.g., "Add user authentication"). Keep messages concise and descriptive.
- **Pull Requests**: Include a clear description, link to relevant issues, and ensure tests pass. Use Docker for consistent environments.
