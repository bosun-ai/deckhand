# Make sure it matches the Ruby version in .ruby-version and Gemfile
ARG RUBY_VERSION=3.2.0
FROM ruby:$RUBY_VERSION

# Install libvips for Active Storage preview support
RUN apt-get update -qq && \
  apt-get install -y build-essential libvips && \
  apt-get clean && \
  rm -rf /var/lib/apt/lists/* /usr/share/doc /usr/share/man

RUN set -uex; \
  apt-get update; \
  apt-get install -y ca-certificates curl gnupg; \
  mkdir -p /etc/apt/keyrings; \
  curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key \
  | gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg; \
  NODE_MAJOR=18; \
  echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_$NODE_MAJOR.x nodistro main" \
  > /etc/apt/sources.list.d/nodesource.list; \
  apt-get update; \
  apt-get install nodejs -y; \
  npm install -g yarn

# Rails app lives here
WORKDIR /app

# Set production environment
ARG RAILS_ENV=production
ENV RAILS_LOG_TO_STDOUT="1" \
  RAILS_ENV=${RAILS_ENV} \
  BUNDLE_JOBS=${nproc} \
  BUNDLE_RETRY=3 \
  RAILS_SERVE_STATIC_FILES="true"
  BUNDLE_PATH=/bundle

# Copy package.json and package-lock.json for node dependencies
COPY package.json package-lock.json ./
RUN npm install

# Install application gems
COPY Gemfile Gemfile.lock ./
RUN bundle install

# Copy application code
COPY . .

# Precompile bootsnap code for faster boot times
RUN if [ "$RAILS_ENV" = "production" ]; then \
  bundle exec bootsnap precompile --gemfile app/ lib/ && \
  SECRET_KEY_BASE_DUMMY=1 SECRET_KEY_BASE=bla bundle exec rails assets:precompile; fi

# Entrypoint prepares the database.
ENTRYPOINT ["/app/bin/docker-entrypoint"]

# Start the server by default, this can be overwritten at runtime
EXPOSE 3000
CMD ["./bin/rails", "server"]
