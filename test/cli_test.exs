defmodule Issues.CLI.Test do
  use ExUnit.Case
  doctest Issues.CLI

  import Issues.CLI
  import ExUnit.CaptureIO
  import Mox

  describe "parse_args/1" do
    test ":help is returned if help is given (as -h or --help)" do
      assert parse_args(["-h", "anything"]) == :help
      assert parse_args(["--help", "anything"]) == :help
    end

    test "three values are returned if three values given" do
      assert parse_args(["user", "project", "10"]) == {"user", "project", 10}
    end

    test "two values are returned if two values given (default count is used)" do
      assert parse_args(["user", "project"]) == {"user", "project", 4}
    end
  end

  describe "process/2" do
    test "handles successful GitHub API response" do
      issues = [%{"created_at" => "2023-01-01T00:00:00Z", "title" => "Test Issue"}]

      expect(Issues.MockHttpClient, :get, fn _url, _headers ->
        {:ok,
         %HTTPoison.Response{
           status_code: 200,
           body: Poison.encode!(issues)
         }}
      end)

      output =
        capture_io(fn ->
          process({"user", "project", 5}, Issues.MockHttpClient)
        end)

      # The output should contain the formatted table
      assert output =~ "Number"
      assert output =~ "Title"
      assert output =~ "Test Issue"
      assert output =~ "Total: 1 issues"
    end

    test "handles GitHub API error response" do
      expect(Issues.MockHttpClient, :get, fn _url, _headers ->
        {:ok,
         %HTTPoison.Response{
           status_code: 404,
           body: Poison.encode!(%{"message" => "Not Found"})
         }}
      end)

      output =
        capture_io(fn ->
          process({"nonexistent", "repository", 1}, Issues.MockHttpClient)
        end)

      assert output =~ "Error fetching issues: Not Found"
    end
  end
end
