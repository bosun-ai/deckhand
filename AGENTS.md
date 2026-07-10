# Repository Guidelines

## Project Structure & Module Organization
- **Source Code**: Ruby backend code is in `app/`, while frontend assets are in `app/assets` and `public/`.
- **Tests**: Test files are located in `test/`.
- **Configuration**: Configuration files are in `config/`, including database, routes, and environment settings.
- **Dependencies**: Ruby dependencies are managed via `Gemfile` and `Gemfile.lock`. JavaScript dependencies are managed via `package.json`.
- **Scripts**: Utility scripts and binaries are in `bin/` and `lib/tasks/`.

## Build, Test, and Development Commands
- **Run Locally**: Use `./bin/dev` to start the development server.
- **Build Assets**: Run `bin/rails tailwindcss:watch` for CSS and `bin/vite dev` for JavaScript.
- **Test**: Execute tests with `bin/rails test` or `bundle exec rake test`.
- **Lint**: Use `bundle exec rubocop` to lint Ruby code.
- **Dependencies**: Install Ruby dependencies with `bundle` and JavaScript dependencies with `npm install`.

## Coding Style & Naming Conventions
- **Ruby**: Follow the rules defined in `.rubocop.yml`. Use snake_case for variables and methods.
- **JavaScript/TypeScript**: Use camelCase for variables and functions. Follow the conventions in `vite.config.ts`.
- **Indentation**: Use 2 spaces for indentation in Ruby and JavaScript.
- **Formatting**: Use `rufo` for Ruby code formatting.

## Testing Guidelines
- **Framework**: Use Rails' built-in testing framework (`Minitest`) along with `Capybara` for system tests.
- **Mocking**: Use `Mocha` for mocking in tests.
- **Run Tests**: Execute tests with `bin/rails test` or `bundle exec rake test`.

## Commit & Pull Request Guidelines
- **Commit Messages**: Write clear, concise commit messages. Use the imperative mood (e.g., "Add feature" instead of "Added feature").
- **Pull Requests**: Include a descriptive title and summary. Link to relevant issues and provide screenshots if applicable.

## Docker & Development Environment
- **Docker**: Use `docker-compose up` to start the full development environment, including Redis and PostgreSQL.
- **Environment Variables**: Configure `.env` with required values (e.g., `OPENAI_ACCESS_TOKEN`, `GITHUB_APP_IDENTIFIER`, `REDIS_URL`).
