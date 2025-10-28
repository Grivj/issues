defmodule Issues.CLI do
  @default_count 4
  @moduledoc """
  Handle the command line parsing and the dispatch to
  the various functions that end up generating a
  table of the last _n_ issues in a github project
  """

  @type args :: {:help} | {String.t(), String.t(), pos_integer}

  @doc """
  `argv` can be -h or --help, which returns :help.
  Otherwise it is a github user name, project name, and (optionally)
  the number of entries to format.
  Return a tuple of `{ user, project, count }`, or `:help` if help was given.
  """

  @spec run(list(String.t())) :: :ok | {:error, String.t()}
  def run(argv) do
    parse_args(argv) |> process
  end

  @spec process(args) :: :ok
  def process({user, project, count}) do
    process({user, project, count}, Issues.HttpClientImpl)
  end

  @spec process(args, module()) :: :ok
  def process({user, project, count}, http_client) do
    case Issues.GithubIssues.fetch(user, project, count, http_client) do
      {:ok, issues} ->
        issues
        |> Issues.GithubIssues.sort_into_descending_order()
        |> IO.inspect()

        :ok

      {:error, error} ->
        IO.puts("Error fetching issues: #{error}")
    end
  end

  @spec parse_args(list(String.t())) :: args
  def parse_args(argv) do
    OptionParser.parse(argv, switches: [help: :boolean], aliases: [h: :help])
    |> elem(1)
    |> args_to_internal_representation()
  end

  def args_to_internal_representation([user, project, count]),
    do: {user, project, String.to_integer(count)}

  def args_to_internal_representation([user, project]), do: {user, project, @default_count}
  def args_to_internal_representation(_), do: :help
end
