defmodule StackoverflowCloneWeb.QuestionController do
  use Phoenix.Controller

  alias StackoverflowClone.Questions
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

        # Prepare data for caching
        question_attrs = %{
          question_id: question_data["question_id"],
          title: question_data["title"],
          body: question_data["body"],
          tags: question_data["tags"] || [],
          score: question_data["score"],
          view_count: question_data["view_count"],
          answer_count: question_data["answer_count"],
          owner_name: get_in(question_data, ["owner", "display_name"]),
          owner_reputation: get_in(question_data, ["owner", "reputation"]),
          link: question_data["link"],
          answers: %{"items" => answers},
          reranked_answers: %{"items" => reranked_answers},
          searched_at: DateTime.utc_now()
        }

        # Cache the question
        case Questions.upsert_question(question_attrs) do
          {:ok, _question} ->
            Questions.cleanup_old_questions()
            Logger.info("Question cached successfully")

          {:error, changeset} ->
            Logger.error("Failed to cache question: #{inspect(changeset)}")
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
    questions = Questions.list_recent_questions()

    formatted_questions =
      Enum.map(questions, fn q ->
        %{
          id: q.question_id,
          title: q.title,
          body: q.body,
          tags: q.tags,
          score: q.score,
          answer_count: q.answer_count,
          view_count: q.view_count,
          link: q.link,
          searched_at: q.searched_at,
          owner: %{
            display_name: q.owner_name,
            reputation: q.owner_reputation
          },
          answers: get_in(q.answers, ["items"]) || [],
          reranked_answers: get_in(q.reranked_answers, ["items"]) || []
        }
      end)

    json(conn, %{questions: formatted_questions})
  end
end
