defmodule StackoverflowClone.Questions.Question do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :id, autogenerate: true}
  schema "questions" do
    field :question_id, :integer
    field :title, :string
    field :body, :string
    field :tags, {:array, :string}
    field :score, :integer
    field :view_count, :integer
    field :answer_count, :integer
    field :owner_name, :string
    field :owner_reputation, :integer
    field :link, :string
    field :answers, :map
    field :reranked_answers, :map
    field :searched_at, :utc_datetime

    timestamps(type: :utc_datetime)
  end

  def changeset(question, attrs) do
    question
    |> cast(attrs, [
      :question_id,
      :title,
      :body,
      :tags,
      :score,
      :view_count,
      :answer_count,
      :owner_name,
      :owner_reputation,
      :link,
      :answers,
      :reranked_answers,
      :searched_at
    ])
    |> validate_required([:question_id, :title])
    |> unique_constraint(:question_id)
  end
end

