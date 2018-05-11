defmodule Appsignal.Transaction.FilterTest do
  use ExUnit.Case
  alias Appsignal.Config
  alias Appsignal.Utils.MapFilter

  import AppsignalTest.Utils

  describe "parameter filtering" do
    test "uses parameter filters from the appsignal config" do
      with_config(%{filter_parameters: ["password"]}, fn() ->
        Config.initialize()
        assert Enum.member?(MapFilter.get_filter_parameters(), "password")
      end)
    end

    test "uses parameter filters from the phoenix config" do
      Application.put_env(:phoenix, :filter_parameters, ~w(secret1))
      Config.initialize()
      assert Enum.member?(MapFilter.get_filter_parameters(), "secret1")
      Application.delete_env(:phoenix, :filter_parameters)
    end

    test "appsignal's parameter filters merge with Phoenix' parameter filters" do
      Application.put_env(:phoenix, :filter_parameters, ~w(secret1))
      with_config(%{filter_parameters: ["secret2"]}, fn() ->
        Config.initialize()
        filter_parameters = MapFilter.get_filter_parameters()
        assert Enum.member?(filter_parameters, "secret1")
        assert Enum.member?(filter_parameters, "secret2")
      end)
      Application.delete_env(:phoenix, :filter_parameters)
    end

    test "uses filter parameters from the OS environment" do
      with_env(%{"APPSIGNAL_FILTER_PARAMETERS" => "secret3,secret4"}, fn() ->
        Config.initialize()
        filter_parameters = MapFilter.get_filter_parameters()
        assert Enum.member?(filter_parameters, "secret3")
        assert Enum.member?(filter_parameters, "secret4")
      end)
    end

    test "filter_values" do
      assert MapFilter.filter_values(%{"foo" => "bar", "password" => "should_not_show"}, ["password"]) ==
        %{"foo" => "bar", "password" => "[FILTERED]"}
    end

    test "filter_values when a map has secret key" do
      assert MapFilter.filter_values(%{"foo" => "bar", "map" => %{"password" => "should_not_show"}}, ["password"]) ==
        %{"foo" => "bar", "map" => %{"password" => "[FILTERED]"}}
    end

    test "filter_values when a list has a map with secret" do
      assert MapFilter.filter_values(%{"foo" => "bar", "list" => [%{"password" => "should_not_show"}]}, ["password"]) ==
        %{"foo" => "bar", "list" => [%{"password" => "[FILTERED]"}]}
    end

    defmodule SomeStruct do
      defstruct foo: 1
    end

    test "filter_values does not filter structs" do
      assert MapFilter.filter_values(%{"foo" => "bar", "file" => %SomeStruct{}}, ["password"]) ==
        %{"foo" => "bar", "file" => %SomeStruct{}}

      assert MapFilter.filter_values(%{"foo" => "bar", "file" => %{__struct__: "s"}}, ["password"]) ==
        %{"foo" => "bar", "file" => %{:__struct__ => "s"}}
    end

    test "filter_values does not fail on atomic keys" do
      assert MapFilter.filter_values(%{:foo => "bar", "password" => "should_not_show"}, ["password"]) ==
        %{:foo => "bar", "password" => "[FILTERED]"}
    end
  end
end
