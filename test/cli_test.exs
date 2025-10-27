defmodule Issues.CLI.Test do
  use ExUnit.Case
  doctest Issues.CLI

  import Issues.CLI

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
