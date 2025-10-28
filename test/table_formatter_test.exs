defmodule Issues.TableFormatterTest do
  use ExUnit.Case
  doctest Issues.TableFormatter

  import Issues.TableFormatter
  import ExUnit.CaptureIO

  describe "format_issues/1" do
    test "formats empty list" do
      output =
        capture_io(fn ->
          format_issues([])
        end)

      assert output =~ "No issues found."
    end

    test "formats issues with proper table structure" do
      issues = [
        %{
          "number" => 123,
          "title" => "Test Issue Title",
          "created_at" => "2023-01-01T00:00:00Z",
          "user" => %{"login" => "testuser"}
        }
      ]

      output =
        capture_io(fn ->
          format_issues(issues)
        end)

      assert output =~ "Number"
      assert output =~ "Title"
      assert output =~ "Created"
      assert output =~ "Author"
      assert output =~ "123"
      assert output =~ "Test Issue Title"
      assert output =~ "testuser"
      assert output =~ "Total: 1 issues"
    end

    test "truncates long titles" do
      issues = [
        %{
          "number" => 123,
          "title" =>
            "This is a very long title that should be truncated because it exceeds the maximum length",
          "created_at" => "2023-01-01T00:00:00Z",
          "user" => %{"login" => "testuser"}
        }
      ]

      output =
        capture_io(fn ->
          format_issues(issues)
        end)

      assert output =~ "..."
    end

    test "handles multiple issues" do
      issues = [
        %{
          "number" => 1,
          "title" => "First Issue",
          "created_at" => "2023-01-01T00:00:00Z",
          "user" => %{"login" => "user1"}
        },
        %{
          "number" => 2,
          "title" => "Second Issue",
          "created_at" => "2023-01-02T00:00:00Z",
          "user" => %{"login" => "user2"}
        }
      ]

      output =
        capture_io(fn ->
          format_issues(issues)
        end)

      assert output =~ "Total: 2 issues"
      assert output =~ "First Issue"
      assert output =~ "Second Issue"
    end
  end

  describe "truncate_string/2" do
    test "truncates long strings" do
      issues = [
        %{
          "number" => 123,
          "title" => "A" |> String.duplicate(100),
          "created_at" => "2023-01-01T00:00:00Z",
          "user" => %{"login" => "testuser"}
        }
      ]

      output =
        capture_io(fn ->
          format_issues(issues)
        end)

      # Should be truncated to 50 characters + "..."
      assert output =~ "..."
    end
  end
end
