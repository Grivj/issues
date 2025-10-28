defmodule Issues.GithubIssues do
  @moduledoc """
  Handle the Github API requests
  """

  @user_agent [{"User-agent", "Elixir issues"}]

  @spec fetch(String.t(), String.t(), pos_integer) :: {:ok, list(map)} | {:error, String.t()}
  def fetch(user, project, count) do
    fetch(user, project, count, Issues.HttpClientImpl)
  end

  @spec fetch(String.t(), String.t(), pos_integer, module()) ::
          {:ok, list(map)} | {:error, String.t()}
  def fetch(user, project, count, http_client) do
    "https://api.github.com/repos/#{user}/#{project}/issues?per_page=#{count}"
    |> http_client.get(@user_agent)
    |> handle_response
  end

  @spec handle_response({:ok, HTTPoison.Response.t()} | {:error, HTTPoison.Error.t()}) ::
          {:ok, list(map)} | {:error, String.t()}
  def handle_response({:ok, %{status_code: 200} = response}) do
    {:ok, response.body |> Poison.decode!()}
  end

  def handle_response({:ok, %{status_code: status_code, body: body}}) do
    case Poison.decode(body) do
      {:ok, decoded_body} ->
        error_message = decoded_body["message"] || "HTTP #{status_code}"
        {:error, error_message}

      {:error, _} ->
        {:error, "HTTP #{status_code}: #{body}"}
    end
  end

  def handle_response({:error, error}), do: {:error, inspect(error)}

  @spec sort_into_descending_order(list(map)) :: list(map)
  def sort_into_descending_order(issues) do
    issues
    |> Enum.sort(fn issue1, issue2 ->
      issue1["created_at"] > issue2["created_at"]
    end)
  end
end
