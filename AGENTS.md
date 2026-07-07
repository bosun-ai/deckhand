# Repository Guidelines

## Project Structure & Module Organization
- **Source Code**: Ruby backend in `app/`, JavaScript/TypeScript in `app/javascript/`.
- **Tests**: Rails tests in `test/` (system, integration, models, etc.).
- **Assets**: Frontend assets in `app/assets/` and `app/javascript/`.
- **Configuration**: Rails config in `config/`, environment vars in `.env`.
- **Dependencies**: Ruby gems in `Gemfile`, Node packages in `package.json`.

## Build, Test, and Development Commands
- **Run locally**: `./bin/dev` (starts Puma, Tailwind, and Vite).
- **Run tests**: `bundle exec rails test` (Rails test suite).
- **Lint Ruby**: `bundle exec rubocop` (uses `.rubocop.yml` config).
- **Install dependencies**: `bundle` (Ruby), `npm install` (Node).
- **Build assets**: `npm run build` (Vite).

## Coding Style & Naming Conventions
- **Ruby**: Follows `rubocop` rules (see `.rubocop.yml`). Snake case for variables (`snake_case`), no frozen string literals.
- **JavaScript/TypeScript**: Uses Tailwind CSS and Stimulus.js. Follows Vite conventions.
- **Indentation**: 2 spaces for Ruby, 2 spaces for JavaScript/TypeScript.

## Testing Guidelines
- **Framework**: Rails default test framework (Minitest).
- **System tests**: Use Capybara and Selenium (configured in `test/system/`).
- **Test helpers**: `test/test_helper.rb` for shared setup.
- **Run tests**: `bundle exec rails test` or `bundle exec rails test:system`.

## Commit & Pull Request Guidelines
- **Commit messages**: Use imperative mood (e.g., "Add user authentication"). Reference issues if applicable.
- **Pull requests**: Include a clear description, link to relevant issues, and ensure tests pass.

## Agent-Specific Instructions
- **Scope**: This is a Ruby on Rails 7.1 application with a JavaScript frontend (Vite, Stimulus, Turbo).
- **Key dependencies**: Redis, OpenAI, Octokit, and ActiveGraph for knowledge management.
- **Focus**: Autonomous task execution, repository analysis, and knowledge graph construction.
