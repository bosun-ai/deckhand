# Repository Guidelines

## Project Structure & Module Organization

- **Source Code**: Ruby backend in `app/`, JavaScript/TypeScript in `app/javascript/`.
- **Tests**: Ruby tests in `test/`, organized by type (e.g., `test/controllers/`, `test/models/`).
- **Assets**: Static files in `public/`, CSS/JS in `app/assets/`.
- **Configuration**: Rails config in `config/`, environment files in `config/environments/`.

## Build, Test, and Development Commands

- **Run locally**: `./bin/dev` (starts Puma, Tailwind, and Vite).
- **Run tests**: `rails test` (Rails default test runner).
- **Lint Ruby**: `rubocop` (uses `.rubocop.yml` for configuration).
- **Build assets**: `rails assets:precompile` (for production).

## Coding Style & Naming Conventions

- **Ruby**: Follows RuboCop rules (see `.rubocop.yml`). Use snake_case for variables/methods, PascalCase for classes.
- **JavaScript/TypeScript**: Use camelCase for variables/functions, PascalCase for classes/components.
- **Indentation**: 2 spaces for Ruby, JavaScript, and TypeScript.

## Testing Guidelines

- **Framework**: Rails default test framework with `mocha` for mocking and `capybara` for system tests.
- **Test files**: Mirror the structure of `app/` (e.g., `test/models/user_test.rb` for `app/models/user.rb`).
- **Run tests**: `rails test` or `rails test:system` for system tests.

## Commit & Pull Request Guidelines

- **Commit messages**: Use imperative mood (e.g., "Add user authentication"). Keep messages concise and descriptive.
- **Pull requests**: Include a clear description, link to relevant issues, and ensure all tests pass.
