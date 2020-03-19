defmodule Appsignal.PhoenixTest do
  use ExUnit.Case
  doctest Appsignal.Phoenix

  test "greets the world" do
    assert Appsignal.Phoenix.hello() == :world
  end
end
