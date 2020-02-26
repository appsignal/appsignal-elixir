defmodule Appsignal.PlugTest do
  use ExUnit.Case
  doctest Appsignal.Plug

  test "greets the world" do
    assert Appsignal.Plug.hello() == :world
  end
end
