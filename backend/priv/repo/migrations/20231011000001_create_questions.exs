defmodule StackoverflowClone.Repo.Migrations.CreateQuestions do
  use Ecto.Migration

  def change do
    create table(:questions) do
      add :question_id, :integer, null: false
      add :title, :text, null: false
      add :body, :text
      add :tags, {:array, :string}, default: []
      add :score, :integer
      add :view_count, :integer
      add :answer_count, :integer
      add :owner_name, :string
      add :owner_reputation, :integer
      add :link, :string
      add :answers, :map
      add :reranked_answers, :map
      add :searched_at, :utc_datetime, null: false

      timestamps(type: :utc_datetime)
    end

    create unique_index(:questions, [:question_id])
    create index(:questions, [:searched_at])
  end
end

