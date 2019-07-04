defmodule Appsignal.Transaction.FilterTest do
  use ExUnit.Case
  alias Appsignal.Config
  alias Appsignal.Utils.MapFilter

  import AppsignalTest.Utils

  defmodule SomeStruct do
    defstruct foo: 1
  end

  describe "filter_parameters/1" do
    test "uses parameter filters from the appsignal config" do
      with_config(%{filter_parameters: ["password"]}, fn ->
        Config.initialize()
        values = %{"foo" => "bar", "password" => "should_not_show"}

        assert MapFilter.filter_parameters(values) ==
                 %{"foo" => "bar", "password" => "[FILTERED]"}
      end)
    end

    test "uses parameter filters from the phoenix config" do
      Application.put_env(:phoenix, :filter_parameters, ~w(secret1))
      Config.initialize()
      values = %{"foo" => "bar", "secret1" => "super_secret"}

      assert MapFilter.filter_parameters(values) ==
               %{"foo" => "bar", "secret1" => "[FILTERED]"}

      Application.delete_env(:phoenix, :filter_parameters)
    end

    test "appsignal's parameter filters merge with Phoenix' parameter filters" do
      Application.put_env(:phoenix, :filter_parameters, ~w(secret1))

      with_config(%{filter_parameters: ["secret2"]}, fn ->
        Config.initialize()

        values = %{"foo" => "bar", "secret1" => "super_secret", "secret2" => "more_secret"}

        assert MapFilter.filter_parameters(values) ==
                 %{"foo" => "bar", "secret1" => "[FILTERED]", "secret2" => "[FILTERED]"}
      end)

      Application.put_env(:phoenix, :filter_parameters, {:keep, ~w(secret1 secret2 foo)})

      with_config(%{filter_parameters: ["secret2"]}, fn ->
        Config.initialize()

        values = %{
          "foo" => "bar",
          "secret1" => "not_so_secret",
          "secret2" => "more_secret",
          "secret3" => "new_secret"
        }

        assert MapFilter.filter_parameters(values) ==
                 %{
                   "foo" => "bar",
                   "secret1" => "not_so_secret",
                   "secret2" => "[FILTERED]",
                   "secret3" => "[FILTERED]"
                 }
      end)

      Application.put_env(:phoenix, :filter_parameters, ~w(secret1))

      with_config(%{filter_parameters: {:keep, ~w(foo secret1)}}, fn ->
        Config.initialize()

        values = %{
          "foo" => "bar",
          "secret1" => "not_so_secret",
          "secret2" => "more_secret",
          "secret3" => "new_secret"
        }

        assert MapFilter.filter_parameters(values) ==
                 %{
                   "foo" => "bar",
                   "secret1" => "[FILTERED]",
                   "secret2" => "[FILTERED]",
                   "secret3" => "[FILTERED]"
                 }
      end)

      Application.delete_env(:phoenix, :filter_parameters)
    end

    test "uses filter parameters from the OS environment" do
      with_env(%{"APPSIGNAL_FILTER_PARAMETERS" => "secret3,secret4"}, fn ->
        Config.initialize()

        values = %{"foo" => "bar", "secret3" => "super_secret", "secret4" => "more_secret"}

        assert MapFilter.filter_parameters(values) ==
                 %{"foo" => "bar", "secret3" => "[FILTERED]", "secret4" => "[FILTERED]"}
      end)
    end

    test "filters out all parameters in case of a configuration error" do
      with_config(%{filter_parameters: "foo"}, fn ->
        Config.initialize()

        values = %{"foo" => "bar", "secret3" => "super_secret", "secret4" => "more_secret"}

        assert ExUnit.CaptureLog.capture_log(fn ->
                 assert MapFilter.filter_parameters(values) ==
                          %{
                            "foo" => "[FILTERED]",
                            "secret3" => "[FILTERED]",
                            "secret4" => "[FILTERED]"
                          }
               end) =~ "An error occured while merging parameter filters."
      end)
    end
  end

  describe "filter_session_data/1" do
    test "uses session data filters from the appsignal config" do
      with_config(%{filter_session_data: ["secret"]}, fn ->
        Config.initialize()
        values = %{"foo" => "bar", "secret" => "should_not_show"}

        assert MapFilter.filter_session_data(values) ==
                 %{"foo" => "bar", "secret" => "[FILTERED]"}
      end)
    end
  end

  describe "filter_values/2 with discard strategy" do
    test "in top level map" do
      values = %{"foo" => "bar", "password" => "should_not_show"}

      assert MapFilter.filter_values(values, ["password"]) ==
               %{"foo" => "bar", "password" => "[FILTERED]"}
    end

    test "when a map has secret key" do
      values = %{"foo" => "bar", "map" => %{"password" => "should_not_show"}}

      assert MapFilter.filter_values(values, ["password"]) ==
               %{"foo" => "bar", "map" => %{"password" => "[FILTERED]"}}
    end

    test "when a list has a map with secret" do
      values = %{"foo" => "bar", "list" => [%{"password" => "should_not_show"}]}

      assert MapFilter.filter_values(values, ["password"]) ==
               %{"foo" => "bar", "list" => [%{"password" => "[FILTERED]"}]}
    end

    test "does not filter structs" do
      values = %{"foo" => "bar", "file" => %SomeStruct{}}

      assert MapFilter.filter_values(values, ["password"]) ==
               %{"foo" => "bar", "file" => %SomeStruct{}}

      values = %{"foo" => "bar", "file" => %{__struct__: "s"}}

      assert MapFilter.filter_values(values, ["password"]) ==
               %{"foo" => "bar", "file" => %{:__struct__ => "s"}}
    end

    test "does not fail on atomic keys" do
      values = %{:foo => "bar", "password" => "should_not_show"}

      assert MapFilter.filter_values(values, ["password"]) ==
               %{:foo => "bar", "password" => "[FILTERED]"}

      assert MapFilter.filter_values(%{"foo" => "bar", password: "should_not_show"}, [
               "password"
             ]) == %{"foo" => "bar", password: "[FILTERED]"}
    end
  end

  describe "filter_values/2 with keep strategy" do
    test "discards values not specified in params" do
      values = %{"foo" => "bar", "password" => "abc123", "file" => %SomeStruct{}}

      assert MapFilter.filter_values(values, {:keep, []}) ==
               %{"foo" => "[FILTERED]", "password" => "[FILTERED]", "file" => "[FILTERED]"}
    end

    test "keeps values that are specified in params" do
      values = %{"foo" => "bar", "password" => "abc123", "file" => %SomeStruct{}}

      assert MapFilter.filter_values(values, {:keep, ["foo", "file"]}) ==
               %{"foo" => "bar", "password" => "[FILTERED]", "file" => %SomeStruct{}}
    end

    test "keeps all values under keys that are kept" do
      values = %{"foo" => %{"bar" => 1, "baz" => 2}}

      assert MapFilter.filter_values(values, {:keep, ["foo"]}) ==
               %{"foo" => %{"bar" => 1, "baz" => 2}}
    end

    test "only filters leaf values" do
      values = %{"foo" => %{"bar" => 1, "baz" => 2}, "ids" => [1, 2]}

      assert MapFilter.filter_values(values, {:keep, []}) ==
               %{
                 "foo" => %{"bar" => "[FILTERED]", "baz" => "[FILTERED]"},
                 "ids" => ["[FILTERED]", "[FILTERED]"]
               }
    end
  end
end
