defmodule StackoverflowClone.RecentSearches.RecentSearch do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :id, autogenerate: true}
  schema "recent_searches" do
    field :search_query, :string
    field :searched_at, :utc_datetime

    timestamps(type: :utc_datetime)
  end

  def changeset(recent_search, attrs) do
    recent_search
    |> cast(attrs, [:search_query, :searched_at])
    |> validate_required([:search_query, :searched_at])
  end
end
