defmodule Issues.HttpClient do
  @moduledoc """
  Behavior for HTTP clients used by the Issues application.
  """

  @callback get(String.t(), list()) ::
              {:ok, HTTPoison.Response.t()} | {:error, HTTPoison.Error.t()}
end
