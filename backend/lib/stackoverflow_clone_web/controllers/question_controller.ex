defmodule StackoverflowCloneWeb.QuestionController do
  use Phoenix.Controller

  alias StackoverflowClone.RecentSearches
  alias StackoverflowClone.StackoverflowClient
  alias StackoverflowClone.LLMClient

  require Logger

  def search(conn, %{"question" => question_text}) when is_binary(question_text) and byte_size(question_text) > 0 do
    Logger.info("Searching for question: #{question_text}")

    case StackoverflowClient.search_and_get_question(question_text) do
      {:ok, question_data} ->
        answers = question_data["answers"] || []

        # Rerank answers using LLM
        {:ok, reranked_answers} = LLMClient.rerank_answers(question_data, answers)

        # Store the search query in recent searches
        case RecentSearches.create_recent_search(%{
          search_query: question_text,
          searched_at: DateTime.utc_now()
        }) do
          {:ok, _search} ->
            RecentSearches.cleanup_old_searches()
            Logger.info("Search query stored successfully")

          {:error, changeset} ->
            Logger.error("Failed to store search query: #{inspect(changeset)}")
        end

        # Return response
        response = %{
          question: %{
            id: question_data["question_id"],
            title: question_data["title"],
            body: question_data["body"],
            tags: question_data["tags"] || [],
            score: question_data["score"],
            view_count: question_data["view_count"],
            answer_count: question_data["answer_count"],
            link: question_data["link"],
            owner: question_data["owner"] || %{}
          },
          answers: answers,
          reranked_answers: reranked_answers
        }

        json(conn, response)

      {:error, :no_results} ->
        conn
        |> put_status(:not_found)
        |> json(%{error: "No questions found matching your query"})

      {:error, reason} ->
        Logger.error("Error searching questions: #{inspect(reason)}")

        conn
        |> put_status(:internal_server_error)
        |> json(%{error: "Failed to search questions: #{inspect(reason)}"})
    end
  end

  def search(conn, _params) do
    conn
    |> put_status(:bad_request)
    |> json(%{error: "Missing or invalid 'question' parameter"})
  end

  def search_similar(conn, %{"question" => question_text}) when is_binary(question_text) and byte_size(question_text) > 0 do
    Logger.info("Searching for similar questions: #{question_text}")

    case StackoverflowClient.search_similar_questions(question_text, 10) do
      {:ok, questions} ->
        # Format questions for response
        formatted_questions =
          Enum.map(questions, fn question ->
            %{
              id: question["question_id"],
              title: question["title"],
              body: question["body"],
              tags: question["tags"] || [],
              score: question["score"],
              view_count: question["view_count"],
              answer_count: question["answer_count"],
              link: question["link"],
              owner: question["owner"] || %{},
              answers: question["answers"] || [],
              is_answered: question["is_answered"] || false,
              accepted_answer_id: question["accepted_answer_id"],
              creation_date: question["creation_date"]
            }
          end)

        # Sort by relevance (Stack Overflow's default)
        sorted_questions = formatted_questions

        # Rerank using LLM for accuracy
        {:ok, reranked_questions} = LLMClient.rerank_search_results(question_text, formatted_questions)

        # Store the search query in recent searches
        case RecentSearches.create_recent_search(%{
          search_query: question_text,
          searched_at: DateTime.utc_now()
        }) do
          {:ok, _search} ->
            RecentSearches.cleanup_old_searches()
            Logger.info("Search query stored successfully from search_similar")

          {:error, changeset} ->
            Logger.error("Failed to store search query from search_similar: #{inspect(changeset)}")
        end

        json(conn, %{
          questions: sorted_questions,
          reranked_questions: reranked_questions
        })

      {:error, :no_results} ->
        conn
        |> put_status(:not_found)
        |> json(%{error: "No similar questions found"})

      {:error, reason} ->
        Logger.error("Error searching similar questions: #{inspect(reason)}")

        conn
        |> put_status(:internal_server_error)
        |> json(%{error: "Failed to search similar questions: #{inspect(reason)}"})
    end
  end

  def search_similar(conn, _params) do
    conn
    |> put_status(:bad_request)
    |> json(%{error: "Missing or invalid 'question' parameter"})
  end

  def recent(conn, _params) do
    searches = RecentSearches.list_recent_searches()

    formatted_searches =
      Enum.map(searches, fn s ->
        %{
          id: s.id,
          search_query: s.search_query,
          searched_at: s.searched_at
        }
      end)

    json(conn, %{questions: formatted_searches})
  end
end
