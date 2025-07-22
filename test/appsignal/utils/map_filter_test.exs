defmodule Appsignal.Utils.MapFilterTest do
  alias Appsignal.Utils.MapFilter
  use ExUnit.Case

  # Phoenix Logger helpers for compiling filter patterns
  # Copyright (c) 2014 Chris McCord - Licensed under MIT
  def compile_filter({:compiled, _key, _value} = filter), do: filter
  def compile_filter({:discard, params}), do: compile_discard(params)
  def compile_filter({:keep, params}), do: {:keep, params}
  def compile_filter(params), do: compile_discard(params)

  defp compile_discard([]) do
    {:compiled, [], []}
  end

  defp compile_discard(params) when is_list(params) or is_binary(params) do
    key_match = :binary.compile_pattern(params)
    value_match = params |> List.wrap() |> Enum.map(&(&1 <> "=")) |> :binary.compile_pattern()
    {:compiled, key_match, value_match}
  end

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

    test "reads compiled filter config from Phoenix config" do
      compiled_filter = compile_filter(["password", "secret"])
      Application.put_env(:phoenix, :filter_parameters, compiled_filter)
      values = %{"foo" => "bar", "password" => "should_not_show", "token" => "secret=value"}

      assert MapFilter.filter(values) ==
               %{"foo" => "bar", "password" => "[FILTERED]", "token" => "[FILTERED]"}

      Application.delete_env(:phoenix, :filter_parameters)
    end
  end

  describe "filter/2 with discard strategy (Phoenix < 1.18)" do
    test "in top level map" do
      values = %{"foo" => "bar", "password" => "should_not_show"}

      assert MapFilter.filter(values, ["password"]) ==
               %{"foo" => "bar", "password" => "[FILTERED]"}
    end

    test "with :discard option" do
      values = %{"foo" => "bar", "password" => "should_not_show"}

      assert MapFilter.filter(values, {:discard, ["password"]}) ==
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

  describe "filter/2 with compiled strategy (Phoenix >= 1.18)" do
    test "filters keys that contain key substring" do
      values = %{"foo" => "bar", "password" => "secret", "user_password" => "secret"}
      compiled_filter = compile_filter(["password"])

      assert MapFilter.filter(values, compiled_filter) ==
               %{"foo" => "bar", "password" => "[FILTERED]", "user_password" => "[FILTERED]"}
    end

    test "filters values that contain value substring" do
      values = %{"foo" => "bar", "token" => "secret=abc123", "key" => "secret=def456"}
      compiled_filter = compile_filter(["secret"])

      assert MapFilter.filter(values, compiled_filter) ==
               %{"foo" => "bar", "token" => "[FILTERED]", "key" => "[FILTERED]"}
    end

    test "filters both keys and values when they match" do
      values = %{"password" => "secret", "token" => "secret=value", "foo" => "bar"}
      compiled_filter = compile_filter(["password", "secret"])

      assert MapFilter.filter(values, compiled_filter) ==
               %{"password" => "[FILTERED]", "token" => "[FILTERED]", "foo" => "bar"}
    end

    test "filters nested maps" do
      values = %{"foo" => "bar", "user" => %{"password" => "secret", "name" => "John"}}
      compiled_filter = compile_filter(["password", "secret"])

      assert MapFilter.filter(values, compiled_filter) ==
               %{"foo" => "bar", "user" => %{"password" => "[FILTERED]", "name" => "John"}}
    end

    test "does not filter bare values in lists (only filters map keys/values)" do
      values = %{"foo" => "bar", "tokens" => ["secret=value", "password=123"]}
      compiled_filter = compile_filter(["secret", "password"])

      # Phoenix compiled filters only work on map keys/values, not bare strings in lists
      assert MapFilter.filter(values, compiled_filter) ==
               %{"foo" => "bar", "tokens" => ["secret=value", "password=123"]}
    end

    test "filters nested lists with maps" do
      values = %{"users" => [%{"password" => "secret", "name" => "John"}]}
      compiled_filter = compile_filter(["password", "secret"])

      assert MapFilter.filter(values, compiled_filter) ==
               %{"users" => [%{"password" => "[FILTERED]", "name" => "John"}]}
    end

    test "does not filter structs" do
      values = %{"foo" => "bar", "file" => %Plug.Upload{}}
      compiled_filter = compile_filter(["password", "secret"])

      assert MapFilter.filter(values, compiled_filter) ==
               %{"foo" => "bar", "file" => %Plug.Upload{}}
    end

    test "handles atomic keys" do
      values = %{:foo => "bar", "password" => "secret"}

      # We can't actually filter by atomic key, so we just test if it doesn't raise an error overal
      compiled_filter = compile_filter(["password", "secret"])

      assert MapFilter.filter(values, compiled_filter) ==
               %{:foo => "bar", "password" => "[FILTERED]"}
    end

    test "handles non-binary values" do
      values = %{"foo" => 123, "password" => "secret", "count" => 456}
      compiled_filter = compile_filter(["password", "secret"])

      assert MapFilter.filter(values, compiled_filter) ==
               %{"foo" => 123, "password" => "[FILTERED]", "count" => 456}
    end

    test "filters when key and value both match different patterns" do
      values = %{"secret_key" => "user=password"}
      compiled_filter = compile_filter(["secret", "password"])

      assert MapFilter.filter(values, compiled_filter) ==
               %{"secret_key" => "[FILTERED]"}
    end

    test "handles empty patterns like Phoenix" do
      values = %{"foo" => "bar", "password" => "secret"}
      compiled_filter = compile_filter([])

      assert MapFilter.filter(values, compiled_filter) ==
               %{"foo" => "bar", "password" => "secret"}
    end
  end

  describe "filter/2 with keep strategy" do
    test "discards values not specified in params" do
      values = %{"foo" => "bar", "password" => "abc123", "file" => %Plug.Upload{}}

      assert MapFilter.filter(values, {:keep, []}) ==
               %{"foo" => "[FILTERED]", "password" => "[FILTERED]", "file" => "[FILTERED]"}

      assert MapFilter.filter(values, compile_filter({:keep, []})) ==
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
