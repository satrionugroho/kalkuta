defmodule ViennaTest do
  use ExUnit.Case
  doctest Vienna

  test "greets the world" do
    assert Vienna.hello() == :world
  end
end
