defmodule AppsignalTransactionFilterTest do
  use ExUnit.Case
  alias Appsignal.Config

  alias Appsignal.Utils.ParamsFilter

  describe "parameter filtering" do
    test "uses parameter filters from the appsignal config" do
      with_app_config(:appsignal, :config, [filter_parameters: ["password"]], fn() ->
        Config.initialize()
        assert ParamsFilter.get_filter_parameters() == ["password"]
      end)
    end

    test "uses parameter filters from the phoenix config" do
      with_app_config(:phoenix, :config, [filter_parameters: ["secret1"]], fn() ->
        Config.initialize()
        assert ParamsFilter.get_filter_parameters() == ["secret1"]
      end)
    end

    test "appsignal's paramter filters override Phoenix' parameter filters" do
      with_app_config(:phoenix, :config, [filter_parameters: ["secret1"]], fn() ->
        with_app_config(:appsignal, :config, [filter_parameters: ["secret2"]], fn() ->
          Config.initialize()
          assert ParamsFilter.get_filter_parameters() == ["secret2"]
        end)
      end)
    end

    test "uses filter parameters from the OS environment" do
      System.put_env("APPSIGNAL_FILTER_PARAMETERS", "foo,bar")
      Config.initialize()
      assert ParamsFilter.get_filter_parameters() == ["foo", "bar"]
      System.delete_env("APPSIGNAL_FILTER_PARAMETERS")
      Application.delete_env(:appsignal, :config)
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

    test "filter_values does not filter structs" do
      assert ParamsFilter.filter_values(%{"foo" => "bar", "file" => %Plug.Upload{}}, ["password"]) ==
        %{"foo" => "bar", "file" => %Plug.Upload{}}

      assert ParamsFilter.filter_values(%{"foo" => "bar", "file" => %{__struct__: "s"}}, ["password"]) ==
        %{"foo" => "bar", "file" => %{:__struct__ => "s"}}
    end

    test "filter_values does not fail on atomic keys" do
      assert ParamsFilter.filter_values(%{:foo => "bar", "password" => "should_not_show"}, ["password"]) ==
        %{:foo => "bar", "password" => "[FILTERED]"}
    end
  end


  defp with_app_config(app, key, value, function) do
    Application.put_env(app, key, value)
    function.()
    Application.delete_env(app, key)
    System.delete_env("APPSIGNAL_FILTER_PARAMETERS")
  end

end
