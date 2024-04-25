defmodule Appsignal.Utils.MapFilterTest do
  alias Appsignal.Utils.MapFilter
  use ExUnit.Case

  describe "filter/1, without filters" do
    test "returns the map as-is" do
      assert %{id: 4, name: "David"} = MapFilter.filter(%{id: 4, name: "David"})
    end
  end

  describe "filter/1" do
    test "reads filter config from Phoenix config by default" do
      Application.put_env(:phoenix, :filter_parameters, ["password"])
      values = %{"foo" => "bar", "password" => "should_not_show"}

      assert MapFilter.filter(values) ==
               %{"foo" => "bar", "password" => "[FILTERED]"}

      Application.delete_env(:phoenix, :filter_parameters)
    end
  end

  describe "filter/2 with discard strategy" do
    test "in top level map" do
      values = %{"foo" => "bar", "password" => "should_not_show"}

      assert MapFilter.filter(values, ["password"]) ==
               %{"foo" => "bar", "password" => "[FILTERED]"}
    end

    test "discards keys with partial key match" do
      values = %{"password" => "should_not_show", "my_password" => "should_not_show"}

      assert MapFilter.filter(values, ["password"]) ==
               %{"password" => "[FILTERED]", "my_password" => "[FILTERED]"}
    end

    test "when a map has secret key" do
      values = %{"foo" => "bar", "map" => %{"password" => "should_not_show"}}

      assert MapFilter.filter(values, ["password"]) ==
               %{"foo" => "bar", "map" => %{"password" => "[FILTERED]"}}
    end

    test "when a list has a map with secret" do
      values = %{"foo" => "bar", "list" => [%{"password" => "should_not_show"}]}

      assert MapFilter.filter(values, ["password"]) ==
               %{"foo" => "bar", "list" => [%{"password" => "[FILTERED]"}]}
    end

    test "does not filter structs" do
      values = %{"foo" => "bar", "file" => %Plug.Upload{}}

      assert MapFilter.filter(values, ["password"]) ==
               %{"foo" => "bar", "file" => %Plug.Upload{}}

      values = %{"foo" => "bar", "file" => %{__struct__: "s"}}

      assert MapFilter.filter(values, ["password"]) ==
               %{"foo" => "bar", "file" => %{:__struct__ => "s"}}
    end

    test "does not fail on atomic keys" do
      values = %{:foo => "bar", "password" => "should_not_show"}

      assert MapFilter.filter(values, ["password"]) ==
               %{:foo => "bar", "password" => "[FILTERED]"}
    end
  end

  describe "filter/2 with keep strategy" do
    test "discards values not specified in params" do
      values = %{"foo" => "bar", "password" => "abc123", "file" => %Plug.Upload{}}

      assert MapFilter.filter(values, {:keep, []}) ==
               %{"foo" => "[FILTERED]", "password" => "[FILTERED]", "file" => "[FILTERED]"}
    end

    test "keeps values that are specified in params" do
      values = %{"foo" => "bar", "password" => "abc123", "file" => %Plug.Upload{}}

      assert MapFilter.filter(values, {:keep, ["foo", "file"]}) ==
               %{"foo" => "bar", "password" => "[FILTERED]", "file" => %Plug.Upload{}}
    end

    test "keeps all values under keys that are kept" do
      values = %{"foo" => %{"bar" => 1, "baz" => 2}}

      assert MapFilter.filter(values, {:keep, ["foo"]}) ==
               %{"foo" => %{"bar" => 1, "baz" => 2}}
    end

    test "only filters leaf values" do
      values = %{"foo" => %{"bar" => 1, "baz" => 2}, "ids" => [1, 2]}

      assert MapFilter.filter(values, {:keep, []}) ==
               %{
                 "foo" => %{"bar" => "[FILTERED]", "baz" => "[FILTERED]"},
                 "ids" => ["[FILTERED]", "[FILTERED]"]
               }
    end
  end
end
