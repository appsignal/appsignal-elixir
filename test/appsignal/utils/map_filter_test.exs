defmodule Appsignal.Utils.MapFilterTest do
  alias Appsignal.Utils.MapFilter
  use ExUnit.Case

  describe "filter/1, without filters" do
    test "returns the map as-is" do
      assert %{id: 4, name: "David"} = MapFilter.filter(%{id: 4, name: "David"})
    end
  end

  describe "filter/1, with a blocklist" do
    test "returns the map as-is, and leaves filtering to the agent" do
      Application.put_env(:phoenix, :filter_parameters, ~w(name))
      assert %{id: 4, name: "David"} = MapFilter.filter(%{id: 4, name: "David"})
      Application.delete_env(:phoenix, :filter_parameters)
    end
  end

  describe "filter/1, with a keeplist" do
    test "returns the map as-is, and leaves filtering to the agent" do
      Application.put_env(:phoenix, :filter_parameters, {:keep, [:name]})
      assert %{name: "David"} = MapFilter.filter(%{id: 4, name: "David"})
      Application.delete_env(:phoenix, :filter_parameters)
    end
  end
end
