import Config

config :stackoverflow_clone, StackoverflowClone.Repo,
  username: "postgres",
  password: "postgres",
  hostname: "localhost",
  database: "stackoverflow_clone_test#{System.get_env("MIX_TEST_PARTITION")}",
  pool: Ecto.Adapters.SQL.Sandbox,
  pool_size: 10

config :stackoverflow_clone, StackoverflowCloneWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "test_secret",
  server: false

config :logger, level: :warning
config :phoenix, :plug_init_mode, :runtime

