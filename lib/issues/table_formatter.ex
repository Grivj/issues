defmodule Issues.TableFormatter do
  @moduledoc """
  Formats a list of issues into a table.
  """

  @spec format_issues(list(map)) :: :ok
  def format_issues(issues) when is_list(issues) do
    if Enum.empty?(issues) do
      IO.puts("No issues found.")
    else
      issues
      |> print_table_header()
      |> print_table_separator()
      |> print_issues()
    end
  end

  @spec print_table_header(list(map)) :: list(map)
  defp print_table_header(issues) do
    IO.puts("")

    IO.puts(
      "#{String.pad_trailing("Number", 8)} | #{String.pad_trailing("Title", 50)} | #{String.pad_trailing("Created", 12)} | #{String.pad_trailing("Author", 15)}"
    )

    issues
  end

  @spec print_table_separator(list(map)) :: list(map)
  defp print_table_separator(issues) do
    IO.puts(
      "#{String.duplicate("-", 8)} | #{String.duplicate("-", 50)} | #{String.duplicate("-", 12)} | #{String.duplicate("-", 15)}"
    )

    issues
  end

  @spec print_issues(list(map)) :: :ok
  defp print_issues(issues) do
    issues
    |> Enum.each(&print_issue/1)

    IO.puts("")
    IO.puts("Total: #{length(issues)} issues")
  end

  @spec print_issue(map) :: :ok
  defp print_issue(issue) do
    number = issue["number"] |> to_string() |> String.pad_trailing(8)
    title = truncate_string(issue["title"], 50)
    created = format_date(issue["created_at"])
    author = truncate_string(issue["user"]["login"], 15)

    IO.puts("#{number} | #{title} | #{created} | #{author}")
  end

  @spec truncate_string(String.t(), pos_integer()) :: String.t()
  defp truncate_string(string, max_length) when is_binary(string) do
    if String.length(string) > max_length do
      string
      |> String.slice(0, max_length - 3)
      |> Kernel.<>("...")
      |> String.pad_trailing(max_length)
    else
      String.pad_trailing(string, max_length)
    end
  end

  @spec format_date(String.t()) :: String.t()
  defp format_date(date_string) when is_binary(date_string) do
    case DateTime.from_iso8601(date_string) do
      {:ok, datetime, _} ->
        datetime
        |> DateTime.to_date()
        |> Date.to_string()
        |> String.pad_trailing(12)

      {:error, _} ->
        "Invalid Date"
        |> String.pad_trailing(12)
    end
  end
end
