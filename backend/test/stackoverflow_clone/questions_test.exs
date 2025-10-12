defmodule StackoverflowClone.QuestionsTest do
  use ExUnit.Case, async: true
  alias StackoverflowClone.{Questions, Repo}
  alias StackoverflowClone.Questions.Question

  setup do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(Repo)
  end

  describe "list_recent_questions/0" do
    test "returns empty list when no questions exist" do
      assert Questions.list_recent_questions() == []
    end

    test "returns questions ordered by searched_at desc" do
      # Create questions with different timestamps
      {:ok, q1} = create_question(123, "First Question", ~U[2024-01-01 10:00:00Z])
      {:ok, q2} = create_question(456, "Second Question", ~U[2024-01-02 10:00:00Z])
      {:ok, q3} = create_question(789, "Third Question", ~U[2024-01-03 10:00:00Z])

      recent = Questions.list_recent_questions()

      assert length(recent) == 3
      assert Enum.at(recent, 0).question_id == 789
      assert Enum.at(recent, 1).question_id == 456
      assert Enum.at(recent, 2).question_id == 123
    end

    test "limits results to 5 questions" do
      # Create 7 questions
      for i <- 1..7 do
        timestamp = DateTime.add(~U[2024-01-01 10:00:00Z], i, :day)
        create_question(i, "Question #{i}", timestamp)
      end

      recent = Questions.list_recent_questions()

      assert length(recent) == 5
    end
  end

  describe "get_question_by_id/1" do
    test "returns nil when question doesn't exist" do
      assert Questions.get_question_by_id(999999) == nil
    end

    test "returns question when it exists" do
      {:ok, created} = create_question(123, "Test Question")

      found = Questions.get_question_by_id(123)

      assert found.question_id == 123
      assert found.title == "Test Question"
    end
  end

  describe "upsert_question/1" do
    test "creates a new question when it doesn't exist" do
      attrs = %{
        question_id: 123,
        title: "New Question",
        body: "Question body",
        tags: ["elixir", "phoenix"],
        score: 42,
        view_count: 1000,
        answer_count: 5,
        owner_name: "Test User",
        owner_reputation: 500,
        link: "https://stackoverflow.com/questions/123",
        answers: %{"items" => []},
        reranked_answers: %{"items" => []},
        searched_at: DateTime.utc_now()
      }

      {:ok, question} = Questions.upsert_question(attrs)

      assert question.question_id == 123
      assert question.title == "New Question"
      assert question.tags == ["elixir", "phoenix"]
      assert question.score == 42
    end

    test "updates existing question when it already exists" do
      {:ok, original} = create_question(123, "Original Title")
      original_inserted_at = original.inserted_at

      # Wait a moment to ensure different timestamp
      Process.sleep(10)

      attrs = %{
        question_id: 123,
        title: "Updated Title",
        searched_at: DateTime.utc_now()
      }

      {:ok, updated} = Questions.upsert_question(attrs)

      assert updated.id == original.id
      assert updated.question_id == 123
      assert updated.title == "Updated Title"
      assert DateTime.compare(updated.searched_at, original.searched_at) == :gt
    end

    test "requires question_id and title" do
      attrs = %{body: "No question_id or title"}

      {:error, changeset} = Questions.upsert_question(attrs)

      assert changeset.errors[:question_id] != nil
      assert changeset.errors[:title] != nil
    end
  end

  describe "cleanup_old_questions/0" do
    test "keeps only the 5 most recent questions" do
      # Create 8 questions
      for i <- 1..8 do
        timestamp = DateTime.add(~U[2024-01-01 10:00:00Z], i, :day)
        create_question(i, "Question #{i}", timestamp)
      end

      assert length(Repo.all(Question)) == 8

      Questions.cleanup_old_questions()

      remaining = Repo.all(Question)
      assert length(remaining) == 5

      # Verify the 5 most recent are kept
      ids = Enum.map(remaining, & &1.question_id) |> Enum.sort()
      assert ids == [4, 5, 6, 7, 8]
    end

    test "does nothing when there are fewer than 5 questions" do
      create_question(1, "Question 1")
      create_question(2, "Question 2")

      assert length(Repo.all(Question)) == 2

      Questions.cleanup_old_questions()

      assert length(Repo.all(Question)) == 2
    end
  end

  # Helper function to create test questions
  defp create_question(question_id, title, searched_at \\ DateTime.utc_now()) do
    %Question{}
    |> Question.changeset(%{
      question_id: question_id,
      title: title,
      body: "Test body for question #{question_id}",
      tags: ["test"],
      score: 10,
      view_count: 100,
      answer_count: 2,
      searched_at: searched_at
    })
    |> Repo.insert()
  end
end
