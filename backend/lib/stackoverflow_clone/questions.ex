defmodule StackoverflowClone.Questions do
  @moduledoc """
  Context for managing questions and their caching.
  """

  import Ecto.Query
  alias StackoverflowClone.Repo
  alias StackoverflowClone.Questions.Question

  @doc """
  Returns the 5 most recent questions.
  """
  def list_recent_questions do
    Question
    |> order_by([q], desc: q.searched_at)
    |> limit(5)
    |> Repo.all()
  end

  @doc """
  Gets a single question by question_id.
  """
  def get_question_by_id(question_id) do
    Repo.get_by(Question, question_id: question_id)
  end

  @doc """
  Creates or updates a question.
  """
  def upsert_question(attrs) do
    case get_question_by_id(attrs[:question_id] || attrs["question_id"]) do
      nil ->
        %Question{}
        |> Question.changeset(attrs)
        |> Repo.insert()

      existing_question ->
        existing_question
        |> Question.changeset(Map.put(attrs, :searched_at, DateTime.utc_now()))
        |> Repo.update()
    end
  end

  @doc """
  Ensures only the 5 most recent questions are kept.
  """
  def cleanup_old_questions do
    recent_ids =
      Question
      |> select([q], q.id)
      |> order_by([q], desc: q.searched_at)
      |> limit(5)
      |> Repo.all()

    Question
    |> where([q], q.id not in ^recent_ids)
    |> Repo.delete_all()
  end
end

