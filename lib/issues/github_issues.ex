defmodule Issues.GithubIssues do
  @moduledoc """
  Handle the Github API requests
  """

  @user_agent [{"User-agent", "Elixir issues"}]

  @spec fetch(String.t(), String.t()) :: {:ok, list(map)} | {:error, String.t()}
  def fetch(user, project) do
    "https://api.github.com/repos/#{user}/#{project}/issues"
    |> HTTPoison.get(@user_agent)
    |> handle_response
  end

  def handle_response({:ok, response}), do: {:ok, response.body |> Jason.decode!()}
  def handle_response({:error, error}), do: {:error, inspect(error)}
end
