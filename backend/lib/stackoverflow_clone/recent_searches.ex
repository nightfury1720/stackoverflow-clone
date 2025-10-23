defmodule StackoverflowClone.RecentSearches do
  @moduledoc """
  Context for managing recent search queries.
  """

  import Ecto.Query
  alias StackoverflowClone.Repo
  alias StackoverflowClone.RecentSearches.RecentSearch

  @doc """
  Returns the 10 most recent search queries.
  """
  def list_recent_searches do
    RecentSearch
    |> order_by([r], desc: r.searched_at)
    |> limit(10)
    |> Repo.all()
  end

  @doc """
  Creates a new recent search entry.
  """
  def create_recent_search(attrs) do
    %RecentSearch{}
    |> RecentSearch.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Ensures only the 10 most recent searches are kept.
  """
  def cleanup_old_searches do
    recent_ids =
      RecentSearch
      |> select([r], r.id)
      |> order_by([r], desc: r.searched_at)
      |> limit(10)
      |> Repo.all()

    RecentSearch
    |> where([r], r.id not in ^recent_ids)
    |> Repo.delete_all()
  end
end
