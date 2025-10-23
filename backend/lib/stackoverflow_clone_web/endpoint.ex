defmodule StackoverflowCloneWeb.Endpoint do
  use Phoenix.Endpoint, otp_app: :stackoverflow_clone

  @session_options [
    store: :cookie,
    key: "_stackoverflow_clone_key",
    signing_salt: "secret",
    same_site: "Lax"
  ]

  socket "/live", Phoenix.LiveView.Socket, websocket: [connect_info: [session: @session_options]]

  plug Plug.Static,
    at: "/",
    from: :stackoverflow_clone,
    gzip: false

  if code_reloading? do
    plug Phoenix.CodeReloader
  end

  plug Plug.RequestId
  plug Plug.Telemetry, event_prefix: [:phoenix, :endpoint]

  plug Plug.Parsers,
    parsers: [:urlencoded, :multipart, :json],
    pass: ["*/*"],
    json_decoder: Phoenix.json_library()

  plug Plug.MethodOverride
  plug Plug.Head
  plug Plug.Session, @session_options

  plug CORSPlug,
    origin: ["http://localhost:5173", "http://localhost:3000", "http://localhost:8000", "http://127.0.0.1:8000"],
    credentials: true

  plug StackoverflowCloneWeb.Router
end
