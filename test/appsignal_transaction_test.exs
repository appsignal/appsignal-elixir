defmodule AppsignalTransactionTest do
  use ExUnit.Case
  alias Appsignal.Config

  alias Appsignal.Transaction

  test "transaction lifecycle" do
    transaction = Transaction.start("test1", :http_request)
    assert %Transaction{} = transaction

    assert ^transaction = Transaction.start_event(transaction)
    assert ^transaction = Transaction.finish_event(transaction, "sql.query", "Model load", "SELECT * FROM table;", 1)
    assert ^transaction = Transaction.record_event(transaction, "sql.query", "Model load", "SELECT * FROM table;", 1000 * 1000 * 3, 1)
    assert ^transaction = Transaction.set_error(transaction, "Error", "error message", "['backtrace']")
    assert ^transaction = Transaction.set_sample_data(transaction, "key", "{'user_id': 1}")
    assert ^transaction = Transaction.set_action(transaction, "GET:/")
    assert ^transaction = Transaction.set_queue_start(transaction, 1000)
    assert ^transaction = Transaction.set_meta_data(transaction, "email", "info@info.com")
    assert [:sample, :no_sample] |> Enum.member?(Transaction.finish(transaction))
    assert :ok = Transaction.complete(transaction)
  end

  describe "parameter filtering" do
    test "uses parameter filters from the appsignal config" do
      with_app_config(:appsignal, :config, [filter_parameters: ["password"]], fn() ->
        Config.initialize()
        assert Transaction.filter_parameters == ["password"]
      end)
    end

    test "uses parameter filters from the phoenix config" do
      with_app_config(:phoenix, :config, [filter_parameters: ["secret1"]], fn() ->
        Config.initialize()
        assert Transaction.filter_parameters == ["secret1"]
      end)
    end

    test "appsignal's paramter filters override Phoenix' parameter filters" do
      with_app_config(:phoenix, :config, [filter_parameters: ["secret1"]], fn() ->
        with_app_config(:appsignal, :config, [filter_parameters: ["secret2"]], fn() ->
          Config.initialize()
          assert Transaction.filter_parameters == ["secret2"]
        end)
      end)
    end

    test "uses filter parameters from the OS environment" do
      System.put_env("APPSIGNAL_FILTER_PARAMETERS", "foo,bar")
      Config.initialize()
      assert Transaction.filter_parameters == ["foo", "bar"]
      System.delete_env("APPSIGNAL_FILTER_PARAMETERS")
    end

    test "filter_values" do
      assert Transaction.filter_values(%{"foo" => "bar", "password" => "should_not_show"}, ["password"]) ==
        %{"foo" => "bar", "password" => "[FILTERED]"}
    end

    test "filter_values when a map has secret key" do
      assert Transaction.filter_values(%{"foo" => "bar", "map" => %{"password" => "should_not_show"}}, ["password"]) ==
        %{"foo" => "bar", "map" => %{"password" => "[FILTERED]"}}
    end

    test "filter_values when a list has a map with secret" do
      assert Transaction.filter_values(%{"foo" => "bar", "list" => [%{"password" => "should_not_show"}]}, ["password"]) ==
        %{"foo" => "bar", "list" => [%{"password" => "[FILTERED]"}]}
    end

    test "filter_values does not filter structs" do
      assert Transaction.filter_values(%{"foo" => "bar", "file" => %Plug.Upload{}}, ["password"]) ==
        %{"foo" => "bar", "file" => %Plug.Upload{}}

      assert Transaction.filter_values(%{"foo" => "bar", "file" => %{__struct__: "s"}}, ["password"]) ==
        %{"foo" => "bar", "file" => %{:__struct__ => "s"}}
    end

    test "filter_values does not fail on atomic keys" do
      assert Transaction.filter_values(%{:foo => "bar", "password" => "should_not_show"}, ["password"]) ==
        %{:foo => "bar", "password" => "[FILTERED]"}
    end
  end


  defp with_app_config(app, key, value, function) do
    old = Application.get_env(app, key)
    Application.put_env(app, key, value)
    function.()
    Application.delete_env(app, key)
  end

end
