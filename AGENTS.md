# Repository Guidelines

## Project Structure & Module Organization

- **Source code**: `app/` contains Rails MVC structure (controllers, models, views, agents, jobs)
- **Agents**: Custom AI agents live in `app/agents/` and `app/agents/tools/`
- **Tests**: `test/` directory with system, integration, unit, and agent tests
- **Frontend**: `app/assets/` and `app/javascript/` with TypeScript/Vite
- **Configuration**: `config/` for Rails settings, `vite.config.ts` for frontend
- **Dependencies**: Ruby gems in `Gemfile`, JS packages in `package.json`

## Build, Test, and Development Commands

- `bundle exec rails server` — Start Rails development server
- `bin/vite dev` — Start Vite frontend dev server
- `bundle exec rails tailwindcss:watch` — Watch Tailwind CSS changes
- `bundle exec rake test` — Run all tests
- `bundle exec rake test:system` — Run system tests
- `bundle exec rubocop` — Run Ruby linter
- `./bin/dev` — Start full development stack (Rails + Vite + Redis)

## Coding Style & Naming Conventions

- **Ruby**: Follow RuboCop rules (see `.rubocop.yml`). Use snake_case for variables/methods, PascalCase for classes
- **JavaScript/TypeScript**: Use camelCase for variables/functions, PascalCase for classes
- **Files**: Use snake_case for Ruby files, kebab-case for JS/TS files
- **Indentation**: 2 spaces for Ruby, 2 spaces for JavaScript/TypeScript
- **Linting**: RuboCop for Ruby, ESLint (if configured) for JS/TS

## Testing Guidelines

- **Framework**: Rails default test framework (Minitest)
- **Test types**: Unit tests in `test/`, system tests in `test/system/`, integration tests in `test/integration/`
- **Agent tests**: Agent-specific tests in `test/agents/`
- **Naming**: Test files end with `_test.rb` (e.g., `user_test.rb`)
- **Run tests**: `bundle exec rake test` or `bundle exec rake test TEST=path/to/test_file.rb`

## Commit & Pull Request Guidelines

- **Commit messages**: Use imperative mood, 50-72 char subject line, optional body for details
- **Pull requests**: Include clear description, link to relevant issues, and screenshots for UI changes
- **Branch naming**: Use descriptive names like `feature/add-agent-testing` or `fix/redis-connection`
