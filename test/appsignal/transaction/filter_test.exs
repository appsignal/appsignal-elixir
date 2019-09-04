defmodule Appsignal.Transaction.FilterTest do
  use ExUnit.Case
  alias Appsignal.Config
  alias Appsignal.Utils.MapFilter

  import AppsignalTest.Utils

  defmodule TestStruct do
    defstruct name: "Alice", password: "secret"
  end

  describe "get_filter_parameters/0" do
    test "returns parameter filters from the appsignal config" do
      with_config(%{filter_parameters: ["password"]}, fn ->
        Config.initialize()

        assert MapFilter.get_filter_parameters() == ["password"]
      end)
    end

    test "returns parameter filters from the phoenix config" do
      Application.put_env(:phoenix, :filter_parameters, ~w(password))
      Config.initialize()
      assert MapFilter.get_filter_parameters() == ["password"]

      Application.delete_env(:phoenix, :filter_parameters)
    end

    test "merges AppSignal's parameter filters with Phoenix' parameter filters" do
      Application.put_env(:phoenix, :filter_parameters, ~w(password))

      with_config(%{filter_parameters: ["token"]}, fn ->
        Config.initialize()

        assert MapFilter.get_filter_parameters() == ["token", "password"]
      end)

      Application.delete_env(:phoenix, :filter_parameters)
    end
  end

  describe "get_filter_session_data/0" do
    test "returns an empty list when no filters are set" do
      assert MapFilter.get_filter_session_data() == []
    end

    test "returns session data filters from the appsignal config" do
      with_config(%{filter_session_data: ["token"]}, fn ->
        Config.initialize()

        assert MapFilter.get_filter_session_data() == ["token"]
      end)
    end
  end

  describe "filter_parameters/1" do
    test "uses parameter filters from the appsignal config" do
      with_config(%{filter_parameters: ["password"]}, fn ->
        Config.initialize()
        values = %{"name" => "Alice", "password" => "secret"}

        assert MapFilter.filter_parameters(values) ==
                 %{"name" => "Alice", "password" => "[FILTERED]"}
      end)
    end

    test "uses parameter filters from the phoenix config" do
      Application.put_env(:phoenix, :filter_parameters, ~w(password))
      Config.initialize()
      values = %{"name" => "Alice", "password" => "secret"}

      assert MapFilter.filter_parameters(values) ==
               %{"name" => "Alice", "password" => "[FILTERED]"}

      Application.delete_env(:phoenix, :filter_parameters)
    end

    test "appsignal's parameter filters merge with Phoenix' parameter filters" do
      Application.put_env(:phoenix, :filter_parameters, ~w(password))

      values = %{
        "name" => "Alice",
        "email" => "alice@example.com",
        "password" => "secret",
        "token" => "secret"
      }

      with_config(%{filter_parameters: ["token"]}, fn ->
        Config.initialize()

        assert MapFilter.filter_parameters(values) ==
                 %{
                   "name" => "Alice",
                   "email" => "alice@example.com",
                   "password" => "[FILTERED]",
                   "token" => "[FILTERED]"
                 }
      end)

      Application.put_env(:phoenix, :filter_parameters, {:keep, ~w(name email)})

      with_config(%{filter_parameters: ["email"]}, fn ->
        Config.initialize()

        assert MapFilter.filter_parameters(values) ==
                 %{
                   "name" => "Alice",
                   "email" => "[FILTERED]",
                   "password" => "[FILTERED]",
                   "token" => "[FILTERED]"
                 }
      end)

      Application.put_env(:phoenix, :filter_parameters, ~w(email))

      with_config(%{filter_parameters: {:keep, ~w(name email)}}, fn ->
        Config.initialize()

        assert MapFilter.filter_parameters(values) ==
                 %{
                   "name" => "Alice",
                   "email" => "[FILTERED]",
                   "password" => "[FILTERED]",
                   "token" => "[FILTERED]"
                 }
      end)

      Application.delete_env(:phoenix, :filter_parameters)
    end

    test "uses filter parameters from the OS environment" do
      with_env(%{"APPSIGNAL_FILTER_PARAMETERS" => "password,email"}, fn ->
        Config.initialize()

        values = %{
          "name" => "Alice",
          "email" => "alice@example.com",
          "password" => "secret"
        }

        assert MapFilter.filter_parameters(values) == %{
                 "name" => "Alice",
                 "email" => "[FILTERED]",
                 "password" => "[FILTERED]"
               }
      end)
    end

    test "filters out all parameters when filter_parameters is not a list" do
      with_config(%{filter_parameters: "name"}, fn ->
        Config.initialize()

        values = %{
          "name" => "Alice",
          "email" => "alice@example.com",
          "password" => "secret"
        }

        assert ExUnit.CaptureLog.capture_log(fn ->
                 assert MapFilter.filter_parameters(values) ==
                          %{
                            "name" => "[FILTERED]",
                            "email" => "[FILTERED]",
                            "password" => "[FILTERED]"
                          }
               end) =~ "An error occured while merging parameter filters."
      end)
    end

    test "filters out all parameters when filter_parameters is a :keep-tuple with a value that's not a list" do
      with_config(%{filter_parameters: {:keep, "name"}}, fn ->
        Config.initialize()

        values = %{
          "name" => "Alice",
          "email" => "alice@example.com",
          "password" => "secret"
        }

        assert ExUnit.CaptureLog.capture_log(fn ->
                 assert MapFilter.filter_parameters(values) ==
                          %{
                            "name" => "[FILTERED]",
                            "email" => "[FILTERED]",
                            "password" => "[FILTERED]"
                          }
               end) =~ "An error occured while merging parameter filters."
      end)
    end
  end

  describe "filter_session_data/1" do
    test "uses session data filters from the appsignal config" do
      with_config(%{filter_session_data: ["password"]}, fn ->
        Config.initialize()

        values = %{
          "name" => "Alice",
          "password" => "secret"
        }

        assert MapFilter.filter_session_data(values) == %{
                 "name" => "Alice",
                 "password" => "[FILTERED]"
               }
      end)
    end
  end

  describe "filter_values/2 with discard strategy" do
    test "in top level map" do
      values = %{
        "name" => "Alice",
        "password" => "secret"
      }

      assert MapFilter.filter_values(values, ["password"]) == %{
               "name" => "Alice",
               "password" => "[FILTERED]"
             }
    end

    test "when a map has secret key" do
      values = %{"map" => %{"password" => "secret"}}

      assert MapFilter.filter_values(values, ["password"]) ==
               %{"map" => %{"password" => "[FILTERED]"}}
    end

    test "when a list has a map with secret" do
      values = %{"list" => [%{"password" => "secret"}]}

      assert MapFilter.filter_values(values, ["password"]) ==
               %{"list" => [%{"password" => "[FILTERED]"}]}
    end

    test "when a list has a struct with secret" do
      values = %{"list" => [%TestStruct{password: "secret"}]}

      assert MapFilter.filter_values(values, ["password"]) ==
               %{"list" => [%{password: "[FILTERED]", name: "Alice"}]}
    end

    test "filters atom keys" do
      values = %{:name => "Alice", "password" => "secret"}

      assert MapFilter.filter_values(values, ["password"]) ==
               %{:name => "Alice", "password" => "[FILTERED]"}

      assert MapFilter.filter_values(%{"name" => "Alice", password: "secret"}, [
               "password"
             ]) == %{"name" => "Alice", password: "[FILTERED]"}
    end
  end

  describe "filter_values/2 with keep strategy" do
    test "discards values not specified in params" do
      values = %{"name" => "Alice", "password" => "secret", "user" => %TestStruct{}}

      assert MapFilter.filter_values(values, {:keep, []}) ==
               %{
                 "name" => "[FILTERED]",
                 "password" => "[FILTERED]",
                 "user" => %{name: "[FILTERED]", password: "[FILTERED]"}
               }
    end

    test "keeps values that are specified in params" do
      values = %{
        "name" => "Alice",
        "password" => "secret",
        "user" => %TestStruct{name: "Alice", password: "secret"}
      }

      assert MapFilter.filter_values(values, {:keep, ["name", "user"]}) ==
               %{
                 "name" => "Alice",
                 "password" => "[FILTERED]",
                 "user" => %{name: "Alice", password: "secret"}
               }
    end

    test "keeps all values under keys that are kept" do
      values = %{"user" => %{"name" => "Alice", "email" => "alice@example.com"}}

      assert MapFilter.filter_values(values, {:keep, ["name"]}) ==
               %{"user" => %{"name" => "Alice", "email" => "[FILTERED]"}}
    end

    test "only filters leaf values" do
      values = %{"user" => %{"name" => "Alice", "email" => "alice@example.com"}, "ids" => [1, 2]}

      assert MapFilter.filter_values(values, {:keep, []}) ==
               %{
                 "user" => %{"name" => "[FILTERED]", "email" => "[FILTERED]"},
                 "ids" => ["[FILTERED]", "[FILTERED]"]
               }
    end
  end
end
