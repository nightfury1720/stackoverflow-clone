defmodule StackoverflowClone.LLMClient do
  @moduledoc """
  Client for interacting with LLM APIs (OpenAI or Ollama) to rerank answers.
  """

  require Logger

  @doc """
  Reranks answers based on relevance and quality using LLM.
  """
  def rerank_answers(question, answers) when is_list(answers) and length(answers) > 0 do
    case get_llm_provider() do
      {:openai, api_key} ->
        rerank_with_openai(question, answers, api_key)

      {:ollama, host, model} ->
        rerank_with_ollama(question, answers, host, model)

      :none ->
        Logger.warning("No LLM provider configured, returning original order")
        {:ok, answers}
    end
  end

  def rerank_answers(_question, answers), do: {:ok, answers}

  defp get_llm_provider do
    cond do
      api_key = System.get_env("OPENAI_API_KEY") ->
        {:openai, api_key}

      ollama_host = System.get_env("OLLAMA_HOST") ->
        model = System.get_env("OLLAMA_MODEL") || "llama2"
        {:ollama, ollama_host, model}

      true ->
        :none
    end
  end

  defp rerank_with_openai(question, answers, api_key) do
    prompt = build_reranking_prompt(question, answers)

    body = Jason.encode!(%{
      model: "gpt-3.5-turbo",
      messages: [
        %{
          role: "system",
          content: "You are an expert at evaluating Stack Overflow answers. Your task is to rerank answers based on relevance, accuracy, clarity, and code quality."
        },
        %{
          role: "user",
          content: prompt
        }
      ],
      temperature: 0.3
    })

    headers = [
      {"Authorization", "Bearer #{api_key}"},
      {"Content-Type", "application/json"}
    ]

    case HTTPoison.post("https://api.openai.com/v1/chat/completions", body, headers, recv_timeout: 30_000) do
      {:ok, %HTTPoison.Response{status_code: 200, body: response_body}} ->
        case Jason.decode(response_body) do
          {:ok, %{"choices" => [%{"message" => %{"content" => content}} | _]}} ->
            parse_reranked_indices(content, answers)

          _ ->
            Logger.error("Failed to parse OpenAI response")
            {:ok, answers}
        end

      {:ok, %HTTPoison.Response{status_code: status_code, body: error_body}} ->
        Logger.error("OpenAI API error: #{status_code} - #{error_body}")
        {:ok, answers}

      {:error, error} ->
        Logger.error("OpenAI API request failed: #{inspect(error)}")
        {:ok, answers}
    end
  end

  defp rerank_with_ollama(question, answers, host, model) do
    prompt = build_reranking_prompt(question, answers)

    body = Jason.encode!(%{
      model: model,
      prompt: "You are an expert at evaluating Stack Overflow answers. #{prompt}\n\nRespond with only a comma-separated list of answer indices in the new order.",
      stream: false,
      options: %{
        temperature: 0.3
      }
    })

    headers = [{"Content-Type", "application/json"}]

    case HTTPoison.post("#{host}/api/generate", body, headers, recv_timeout: 60_000) do
      {:ok, %HTTPoison.Response{status_code: 200, body: response_body}} ->
        case Jason.decode(response_body) do
          {:ok, %{"response" => content}} ->
            parse_reranked_indices(content, answers)

          _ ->
            Logger.error("Failed to parse Ollama response")
            {:ok, answers}
        end

      {:ok, %HTTPoison.Response{status_code: status_code}} ->
        Logger.error("Ollama API error: #{status_code}")
        {:ok, answers}

      {:error, error} ->
        Logger.error("Ollama API request failed: #{inspect(error)}")
        {:ok, answers}
    end
  end

  defp build_reranking_prompt(question, answers) do
    question_text = question["title"] || question[:title] || ""
    question_body = question["body"] || question[:body] || ""

    answers_text =
      answers
      |> Enum.with_index()
      |> Enum.map(fn {answer, idx} ->
        body = answer["body"] || answer[:body] || ""
        score = answer["score"] || answer[:score] || 0
        is_accepted = answer["is_accepted"] || answer[:is_accepted] || false

        """
        Answer #{idx}:
        Score: #{score}
        Is Accepted: #{is_accepted}
        Body: #{String.slice(body, 0..500)}...
        """
      end)
      |> Enum.join("\n\n")

    """
    Question: #{question_text}
    #{if question_body != "", do: "Details: #{String.slice(question_body, 0..300)}...", else: ""}

    Answers to rank:
    #{answers_text}

    Please rerank these answers based on:
    1. Relevance to the question
    2. Accuracy and correctness
    3. Clarity and completeness
    4. Code quality (if applicable)

    Return only a comma-separated list of answer indices (0-#{length(answers) - 1}) in the new order, from best to worst.
    For example: 2,0,1,3
    """
  end

  defp parse_reranked_indices(content, answers) do
    # Try to extract indices from the response
    indices =
      content
      |> String.replace(~r/[^\d,]/, "")
      |> String.split(",", trim: true)
      |> Enum.map(&String.to_integer/1)
      |> Enum.filter(&(&1 < length(answers)))

    if length(indices) > 0 do
      reranked =
        indices
        |> Enum.map(fn idx -> Enum.at(answers, idx) end)
        |> Enum.filter(&(&1 != nil))

      # Add any missing answers at the end
      remaining =
        answers
        |> Enum.with_index()
        |> Enum.reject(fn {_answer, idx} -> idx in indices end)
        |> Enum.map(fn {answer, _idx} -> answer end)

      {:ok, reranked ++ remaining}
    else
      Logger.warning("Could not parse reranked indices, returning original order")
      {:ok, answers}
    end
  end
end

