defmodule Appsignal.Transaction.FilterTest do
  use ExUnit.Case
  alias Appsignal.Config
  alias Appsignal.Utils.ParamsFilter

  import AppsignalTest.Utils

  describe "parameter filtering" do
    test "uses parameter filters from the appsignal config" do
      with_config(%{filter_parameters: ["password"]}, fn() ->
        Config.initialize()
        assert ParamsFilter.get_filter_parameters() == ["password"]
      end)
    end

    test "uses parameter filters from the phoenix config" do
      with_config(%{filter_parameters: ["secret1"]}, fn() ->
        Config.initialize()
        assert ParamsFilter.get_filter_parameters() == ["secret1"]
      end)
    end

    test "appsignal's paramter filters override Phoenix' parameter filters" do
      with_config(:phoenix, %{filter_parameters: ["secret1"]}, fn() ->
        with_config(%{filter_parameters: ["secret2"]}, fn() ->
          Config.initialize()
          assert ParamsFilter.get_filter_parameters() == ["secret2"]
        end)
      end)
    end

    test "uses filter parameters from the OS environment" do
      with_env(%{"APPSIGNAL_FILTER_PARAMETERS" => "foo,bar"}, fn() ->
        Config.initialize()
        assert ParamsFilter.get_filter_parameters() == ["foo", "bar"]
      end)
    end

    test "filter_values" do
      assert ParamsFilter.filter_values(%{"foo" => "bar", "password" => "should_not_show"}, ["password"]) ==
        %{"foo" => "bar", "password" => "[FILTERED]"}
    end

    test "filter_values when a map has secret key" do
      assert ParamsFilter.filter_values(%{"foo" => "bar", "map" => %{"password" => "should_not_show"}}, ["password"]) ==
        %{"foo" => "bar", "map" => %{"password" => "[FILTERED]"}}
    end

    test "filter_values when a list has a map with secret" do
      assert ParamsFilter.filter_values(%{"foo" => "bar", "list" => [%{"password" => "should_not_show"}]}, ["password"]) ==
        %{"foo" => "bar", "list" => [%{"password" => "[FILTERED]"}]}
    end

    defmodule SomeStruct do
      defstruct foo: 1
    end

    test "filter_values does not filter structs" do
      assert ParamsFilter.filter_values(%{"foo" => "bar", "file" => %SomeStruct{}}, ["password"]) ==
        %{"foo" => "bar", "file" => %SomeStruct{}}

      assert ParamsFilter.filter_values(%{"foo" => "bar", "file" => %{__struct__: "s"}}, ["password"]) ==
        %{"foo" => "bar", "file" => %{:__struct__ => "s"}}
    end

    test "filter_values does not fail on atomic keys" do
      assert ParamsFilter.filter_values(%{:foo => "bar", "password" => "should_not_show"}, ["password"]) ==
        %{:foo => "bar", "password" => "[FILTERED]"}
    end
  end
end
