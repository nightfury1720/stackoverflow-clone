defmodule StackoverflowClone.StackoverflowClientTest do
  use ExUnit.Case, async: false
  alias StackoverflowClone.StackoverflowClient

  @moduletag :external_api

  describe "search_questions/1" do
    @tag :skip  # Skip by default to avoid hitting real API during tests
    test "searches for questions successfully" do
      {:ok, results} = StackoverflowClient.search_questions("python string reverse")

      assert is_list(results)
      assert length(results) > 0

      first_question = List.first(results)
      assert Map.has_key?(first_question, "question_id")
      assert Map.has_key?(first_question, "title")
    end

    test "returns error when no results found" do
      # Use a very unique string unlikely to have results
      result = StackoverflowClient.search_questions("xyzabc123notarealquestion9999")

      assert result == {:error, :no_results}
    end
  end

  describe "get_answers/1" do
    @tag :skip  # Skip by default to avoid hitting real API
    test "gets answers for a valid question ID" do
      # Using a known Stack Overflow question ID
      question_id = 927358  # "How do I undo the most recent local commits in Git?"

      {:ok, answers} = StackoverflowClient.get_answers(question_id)

      assert is_list(answers)
      assert length(answers) > 0

      first_answer = List.first(answers)
      assert Map.has_key?(first_answer, "answer_id")
      assert Map.has_key?(first_answer, "score")
    end

    @tag :skip
    test "returns empty list for question with no answers" do
      # Use a very high question ID unlikely to exist
      result = StackoverflowClient.get_answers(999999999)

      # Could be error or empty list depending on API behavior
      assert match?({:ok, []}, result) or match?({:error, _}, result)
    end
  end

  describe "search_and_get_question/1" do
    @tag :skip  # Skip by default to avoid hitting real API
    test "searches and gets question with answers" do
      {:ok, question} = StackoverflowClient.search_and_get_question("reverse string python")

      assert Map.has_key?(question, "question_id")
      assert Map.has_key?(question, "title")
      assert Map.has_key?(question, "answers")
      assert is_list(question["answers"])
    end

    test "returns error for non-existent question" do
      result = StackoverflowClient.search_and_get_question("xyzabc123notarealquestion9999")

      assert match?({:error, _}, result)
    end
  end
end


