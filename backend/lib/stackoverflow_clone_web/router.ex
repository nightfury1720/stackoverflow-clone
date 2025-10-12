defmodule StackoverflowCloneWeb.Router do
  use Phoenix.Router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api", StackoverflowCloneWeb do
    pipe_through :api

    post "/questions/search", QuestionController, :search
    post "/questions/search-similar", QuestionController, :search_similar
    get "/questions/recent", QuestionController, :recent
  end
end
