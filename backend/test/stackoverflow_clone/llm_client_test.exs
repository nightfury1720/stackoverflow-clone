defmodule StackoverflowClone.LLMClientTest do
  use ExUnit.Case, async: true
  alias StackoverflowClone.LLMClient

  describe "rerank_answers/2" do
    test "returns original answers when no LLM provider is configured" do
      # Temporarily unset environment variables
      original_openai = System.get_env("OPENAI_API_KEY")
      original_ollama = System.get_env("OLLAMA_HOST")

      System.delete_env("OPENAI_API_KEY")
      System.delete_env("OLLAMA_HOST")

      question = %{"title" => "Test Question", "body" => "Test body"}
      answers = [
        %{"answer_id" => 1, "body" => "Answer 1", "score" => 10},
        %{"answer_id" => 2, "body" => "Answer 2", "score" => 20}
      ]

      {:ok, result} = LLMClient.rerank_answers(question, answers)

      assert result == answers

      # Restore environment variables
      if original_openai, do: System.put_env("OPENAI_API_KEY", original_openai)
      if original_ollama, do: System.put_env("OLLAMA_HOST", original_ollama)
    end

    test "returns original answers when answers list is empty" do
      question = %{"title" => "Test Question"}
      answers = []

      {:ok, result} = LLMClient.rerank_answers(question, answers)

      assert result == []
    end

    test "handles single answer" do
      question = %{"title" => "Test Question"}
      answers = [%{"answer_id" => 1, "body" => "Only answer", "score" => 10}]

      {:ok, result} = LLMClient.rerank_answers(question, answers)

      assert length(result) == 1
      assert Enum.at(result, 0)["answer_id"] == 1
    end

    test "gracefully handles nil question data" do
      question = nil
      answers = [
        %{"answer_id" => 1, "body" => "Answer 1"},
        %{"answer_id" => 2, "body" => "Answer 2"}
      ]

      # Should not crash
      {:ok, _result} = LLMClient.rerank_answers(question, answers)
    end
  end
end
