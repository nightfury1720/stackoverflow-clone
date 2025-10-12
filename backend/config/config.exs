import Config

config :stackoverflow_clone,
  ecto_repos: [StackoverflowClone.Repo],
  generators: [timestamp_type: :utc_datetime]

config :stackoverflow_clone, StackoverflowCloneWeb.Endpoint,
  url: [host: "localhost"],
  adapter: Phoenix.Endpoint.Cowboy2Adapter,
  render_errors: [
    formats: [json: StackoverflowCloneWeb.ErrorJSON],
    layout: false
  ],
  pubsub_server: StackoverflowClone.PubSub,
  live_view: [signing_salt: "secret"]

config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

config :phoenix, :json_library, Jason

import_config "#{config_env()}.exs"

