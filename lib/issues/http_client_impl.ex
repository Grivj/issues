defmodule Issues.HttpClientImpl do
  @moduledoc """
  Real HTTP client implementation using HTTPoison.
  """

  require Logger

  @behaviour Issues.HttpClient

  @impl Issues.HttpClient
  def get(url, headers) do
    Logger.info("Fetching URL: #{url}")

    HTTPoison.get(url, headers)
  end
end
