defmodule StackoverflowClone.Repo.Migrations.CreateRecentSearches do
  use Ecto.Migration

  def change do
    create table(:recent_searches) do
      add :search_query, :string, null: false
      add :searched_at, :utc_datetime, null: false

      timestamps(type: :utc_datetime)
    end

    create index(:recent_searches, [:searched_at])
  end
end
