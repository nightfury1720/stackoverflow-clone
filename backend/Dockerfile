FROM elixir:1.15-alpine

# Install build dependencies
RUN apk add --no-cache build-base git postgresql-client

# Set working directory
WORKDIR /app

# Install hex and rebar
RUN mix local.hex --force && \
    mix local.rebar --force

# Copy mix files
COPY mix.exs mix.lock ./

# Install dependencies
RUN mix deps.get

# Copy application code
COPY . .

# Compile the project
RUN mix compile

# Expose port
EXPOSE 4000

# Start the application
CMD ["mix", "phx.server"]

