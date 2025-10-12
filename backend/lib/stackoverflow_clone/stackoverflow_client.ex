defmodule StackoverflowClone.StackoverflowClient do
  @moduledoc """
  Client for interacting with the Stack Overflow API.
  """

  @base_url "https://api.stackexchange.com/2.3"

  @doc """
  Searches for questions on Stack Overflow using full-text search.
  Uses the /search/excerpts endpoint which searches titles, bodies, and excerpts.
  """
  def search_questions(query, opts \\ []) do
    require Logger

    params = %{
      order: "desc",
      sort: "relevance",
      q: query,
      site: "stackoverflow",
      filter: "!-*jbN-o8P3E5"
    }
    |> Map.merge(Enum.into(opts, %{}))

    Logger.info("Searching Stack Overflow with query: #{query}")

    case HTTPoison.get("#{@base_url}/search/excerpts", [], params: params) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        case Jason.decode(body) do
          {:ok, %{"items" => [_|_] = items}} ->
            Logger.info("Found #{length(items)} results for query: #{query}")
            {:ok, items}
          {:ok, response} ->
            Logger.warning("No results found for query: #{query}. Response: #{inspect(response)}")
            {:error, :no_results}
          {:error, reason} = error ->
            Logger.error("Failed to decode response for query: #{query}. Reason: #{inspect(reason)}")
            error
        end

      {:ok, %HTTPoison.Response{status_code: status_code, body: body}} ->
        Logger.error("Stack Overflow API returned status #{status_code} for query: #{query}. Body: #{body}")
        {:error, "API returned status #{status_code}"}

      {:error, %HTTPoison.Error{reason: reason}} ->
        Logger.error("HTTP request failed for query: #{query}. Reason: #{inspect(reason)}")
        {:error, reason}
    end
  end

  @doc """
  Gets answers for a specific question.
  """
  def get_answers(question_id) do
    params = %{
      order: "desc",
      sort: "votes",
      site: "stackoverflow",
      filter: "!-*jbN-o8P3E5"
    }

    url = "#{@base_url}/questions/#{question_id}/answers"

    case HTTPoison.get(url, [], params: params) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        case Jason.decode(body) do
          {:ok, %{"items" => items}} ->
            {:ok, items}
          {:error, _} = error ->
            error
        end

      {:ok, %HTTPoison.Response{status_code: status_code}} ->
        {:error, "API returned status #{status_code}"}

      {:error, %HTTPoison.Error{reason: reason}} ->
        {:error, reason}
    end
  end

  @doc """
  Gets a question with its answers.
  """
  def get_question_with_answers(question_id) do
    params = %{
      order: "desc",
      sort: "votes",
      site: "stackoverflow",
      filter: "!-*jbN-o8P3E5"
    }

    url = "#{@base_url}/questions/#{question_id}"

    with {:ok, %HTTPoison.Response{status_code: 200, body: body}} <- HTTPoison.get(url, [], params: params),
         {:ok, %{"items" => [question]}} <- Jason.decode(body),
         {:ok, answers} <- get_answers(question_id) do
      {:ok, Map.put(question, "answers", answers)}
    else
      {:ok, %HTTPoison.Response{status_code: status_code}} ->
        {:error, "API returned status #{status_code}"}
      {:error, reason} ->
        {:error, reason}
      _ ->
        {:error, :not_found}
    end
  end

  @doc """
  Searches and gets the first question with answers.
  """
  def search_and_get_question(query) do
    case search_questions(query, page: 1, pagesize: 1) do
      {:ok, [question | _]} ->
        question_id = question["question_id"]
        case get_answers(question_id) do
          {:ok, answers} ->
            {:ok, Map.put(question, "answers", answers)}
          _error ->
            # Return question even if we can't get answers
            {:ok, Map.put(question, "answers", [])}
        end

      {:error, _} = error ->
        error
    end
  end
end
