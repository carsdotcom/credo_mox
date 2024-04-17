defmodule UnverifiedMoxTest do
  use ExUnit.Case
  doctest UnverifiedMox

  test "greets the world" do
    assert UnverifiedMox.hello() == :world
  end
end
