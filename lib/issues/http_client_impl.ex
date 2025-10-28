defmodule Issues.HttpClientImpl do
  @moduledoc """
  Real HTTP client implementation using HTTPoison.
  """

  @behaviour Issues.HttpClient

  @impl Issues.HttpClient
  def get(url, headers) do
    HTTPoison.get(url, headers)
  end
end
