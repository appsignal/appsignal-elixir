defmodule AppsignalSystemTest do
  use ExUnit.Case
  doctest AppsignalSystem

  test "greets the world" do
    assert AppsignalSystem.hello() == :world
  end
end
