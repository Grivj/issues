defmodule Issues.GithubIssuesTest do
  use ExUnit.Case

  import Issues.GithubIssues
  import Mox

  describe "fetch/4" do
    test "returns {:ok, issues} for successful API call" do
      issues = [%{"id" => 1, "title" => "Test Issue", "created_at" => "2023-01-01T00:00:00Z"}]

      expect(Issues.MockHttpClient, :get, fn url, headers ->
        assert url =~ "elixir-lang/elixir"
        assert url =~ "per_page=1"
        assert headers == [{"User-agent", "Elixir issues"}]

        {:ok,
         %HTTPoison.Response{
           status_code: 200,
           body: Poison.encode!(issues)
         }}
      end)

      assert {:ok, ^issues} = fetch("elixir-lang", "elixir", 1, Issues.MockHttpClient)
    end

    test "returns {:error, message} for 404 response" do
      expect(Issues.MockHttpClient, :get, fn _url, _headers ->
        {:ok,
         %HTTPoison.Response{
           status_code: 404,
           body: Poison.encode!(%{"message" => "Not Found"})
         }}
      end)

      assert {:error, "Not Found"} = fetch("nonexistent", "repo", 1, Issues.MockHttpClient)
    end

    test "returns {:error, message} for network error" do
      expect(Issues.MockHttpClient, :get, fn _url, _headers ->
        {:error, %HTTPoison.Error{reason: :timeout}}
      end)

      result = fetch("elixir-lang", "elixir", 1, Issues.MockHttpClient)
      assert {:error, error_string} = result
      assert error_string =~ "HTTPoison.Error"
      assert error_string =~ "timeout"
    end
  end

  describe "handle_response/1" do
    test "returns {:ok, decoded_body} for successful HTTP 200 response" do
      response = %HTTPoison.Response{
        status_code: 200,
        body: ~s([{"id": 1, "title": "Test Issue"}])
      }

      assert handle_response({:ok, response}) == {:ok, [%{"id" => 1, "title" => "Test Issue"}]}
    end

    test "returns {:error, message} for HTTP 404 response with JSON body" do
      response = %HTTPoison.Response{
        status_code: 404,
        body: ~s({"message": "Not Found", "documentation_url": "https://docs.github.com/rest"})
      }

      assert handle_response({:ok, response}) == {:error, "Not Found"}
    end

    test "returns {:error, status_code} for HTTP error response without message" do
      response = %HTTPoison.Response{
        status_code: 403,
        body: ~s({"error": "Forbidden"})
      }

      assert handle_response({:ok, response}) == {:error, "HTTP 403"}
    end

    test "returns {:error, status_code: body} for HTTP error response with invalid JSON" do
      response = %HTTPoison.Response{
        status_code: 500,
        body: "Internal Server Error"
      }

      assert handle_response({:ok, response}) == {:error, "HTTP 500: Internal Server Error"}
    end

    test "returns {:error, error} for HTTPoison error" do
      error = %HTTPoison.Error{reason: :timeout}
      result = handle_response({:error, error})

      assert {:error, error_string} = result
      assert error_string =~ "HTTPoison.Error"
      assert error_string =~ "timeout"
    end
  end

  describe "sort_into_descending_order/1" do
    test "sorts issues by created_at in descending order" do
      issues = [
        %{"created_at" => "2023-01-01T00:00:00Z", "title" => "Older Issue"},
        %{"created_at" => "2023-01-03T00:00:00Z", "title" => "Newer Issue"},
        %{"created_at" => "2023-01-02T00:00:00Z", "title" => "Middle Issue"}
      ]

      result = sort_into_descending_order(issues)

      assert Enum.map(result, & &1["title"]) == ["Newer Issue", "Middle Issue", "Older Issue"]
    end

    test "handles empty list" do
      assert sort_into_descending_order([]) == []
    end

    test "handles single issue" do
      issues = [%{"created_at" => "2023-01-01T00:00:00Z", "title" => "Single Issue"}]
      result = sort_into_descending_order(issues)
      assert length(result) == 1
      assert hd(result)["title"] == "Single Issue"
    end
  end
end
