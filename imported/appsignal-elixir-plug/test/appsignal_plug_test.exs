defmodule AppsignalPlugTest do
  use ExUnit.Case
  doctest AppsignalPlug

  test "greets the world" do
    assert AppsignalPlug.hello() == :world
  end
end
