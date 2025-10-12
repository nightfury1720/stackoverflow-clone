defmodule StackoverflowCloneWeb.QuestionControllerTest do
  use ExUnit.Case, async: true
  use Plug.Test
  alias StackoverflowCloneWeb.Router
  alias StackoverflowClone.Repo

  setup do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(Repo)
  end

  @opts Router.init([])

  describe "POST /api/questions/search" do
    test "returns error when question parameter is missing" do
      conn =
        conn(:post, "/api/questions/search", %{})
        |> put_req_header("content-type", "application/json")
        |> Router.call(@opts)

      assert conn.status == 400
      assert %{"error" => error_msg} = Jason.decode!(conn.resp_body)
      assert error_msg =~ "question"
    end

    test "returns error when question parameter is empty" do
      conn =
        conn(:post, "/api/questions/search", %{"question" => ""})
        |> put_req_header("content-type", "application/json")
        |> Router.call(@opts)

      assert conn.status == 400
      assert %{"error" => _} = Jason.decode!(conn.resp_body)
    end

    test "returns error when question parameter is not a string" do
      conn =
        conn(:post, "/api/questions/search", %{"question" => 123})
        |> put_req_header("content-type", "application/json")
        |> Router.call(@opts)

      assert conn.status == 400
    end

    @tag :skip  # Skip to avoid hitting external APIs
    test "returns question and answers for valid search" do
      conn =
        conn(:post, "/api/questions/search", %{"question" => "reverse string python"})
        |> put_req_header("content-type", "application/json")
        |> Router.call(@opts)

      assert conn.status == 200
      response = Jason.decode!(conn.resp_body)

      assert Map.has_key?(response, "question")
      assert Map.has_key?(response, "answers")
      assert Map.has_key?(response, "reranked_answers")

      question = response["question"]
      assert Map.has_key?(question, "id")
      assert Map.has_key?(question, "title")
      assert is_list(response["answers"])
    end
  end

  describe "GET /api/questions/recent" do
    test "returns empty list when no questions exist" do
      conn =
        conn(:get, "/api/questions/recent")
        |> Router.call(@opts)

      assert conn.status == 200
      assert %{"questions" => []} = Jason.decode!(conn.resp_body)
    end

    test "returns list of recent questions" do
      # Create test questions directly in DB
      create_test_question(123, "Test Question 1")
      create_test_question(456, "Test Question 2")

      conn =
        conn(:get, "/api/questions/recent")
        |> Router.call(@opts)

      assert conn.status == 200
      response = Jason.decode!(conn.resp_body)

      assert %{"questions" => questions} = response
      assert length(questions) == 2

      first_question = List.first(questions)
      assert Map.has_key?(first_question, "id")
      assert Map.has_key?(first_question, "title")
      assert Map.has_key?(first_question, "tags")
      assert Map.has_key?(first_question, "searched_at")
    end
  end

  # Helper function to create test questions
  defp create_test_question(question_id, title) do
    %StackoverflowClone.Questions.Question{}
    |> StackoverflowClone.Questions.Question.changeset(%{
      question_id: question_id,
      title: title,
      body: "Test body",
      tags: ["test"],
      score: 10,
      view_count: 100,
      answer_count: 2,
      searched_at: DateTime.utc_now()
    })
    |> Repo.insert!()
  end
end


