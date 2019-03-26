defmodule LearnEctoTest do
  use ExUnit.Case
  doctest LearnEcto

  test "greets the world" do
    assert LearnEcto.hello() == :world
  end
end
