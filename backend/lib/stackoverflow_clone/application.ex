defmodule StackoverflowClone.Application do
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      StackoverflowClone.Repo,
      {Phoenix.PubSub, name: StackoverflowClone.PubSub},
      StackoverflowCloneWeb.Endpoint
    ]

    opts = [strategy: :one_for_one, name: StackoverflowClone.Supervisor]
    Supervisor.start_link(children, opts)
  end

  @impl true
  def config_change(changed, _new, removed) do
    StackoverflowCloneWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end

