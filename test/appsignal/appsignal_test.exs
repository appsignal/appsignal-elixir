defmodule AppsignalTest do
  use ExUnit.Case
  import Mock
  import AppsignalTest.Utils

  test "set gauge" do
    Appsignal.set_gauge("key", 10.0)
    Appsignal.set_gauge("key", 10)
  end

  test "increment counter" do
    Appsignal.increment_counter("counter")
    Appsignal.increment_counter("counter", 5)
  end

  test "add distribution value" do
    Appsignal.add_distribution_value("dist_key", 10.0)
    Appsignal.add_distribution_value("dist_key", 10)
  end

  describe "plug?/0" do
    test "is true when Plug is loaded" do
      assert Appsignal.plug? == true
    end
  end

  describe "phoenix?/0" do
    @tag :skip_env_test
    @tag :skip_env_test_no_nif
    test "is true when Phoenix is loaded" do
      assert Appsignal.phoenix? == true
    end

    @tag :skip_env_test_phoenix
    test "is false when Phoenix is not loaded" do
      assert Appsignal.phoenix? == false
    end
  end

  test "Agent environment variables" do
    with_env(%{"APPSIGNAL_APP_ENV" => "test"}, fn() ->
      Appsignal.Config.initialize()

      env = Appsignal.Config.get_system_env()
      assert "test" = env["APPSIGNAL_APP_ENV"]

      config = Application.get_env :appsignal, :config
      assert :test = config[:env]
    end)
  end

  alias Appsignal.{Transaction, TransactionRegistry}

  test "send_error" do
    with_mocks([
      {Appsignal.Transaction, [:passthrough], []},
      {Appsignal.TransactionRegistry, [:passthrough], [remove_transaction: fn(t) -> :ok end]},
    ]) do
      stack = System.stacktrace()
      Appsignal.send_error(%RuntimeError{message: "Some bad stuff happened"}, "Oops", stack)

      t = %Transaction{} = TransactionRegistry.lookup(self())

      assert called TransactionRegistry.remove_transaction(t)

      assert called Transaction.set_error(t, "RuntimeError", "Oops: Some bad stuff happened", stack)
      assert called Transaction.finish(t)
      assert called Transaction.complete(t)
    end
  end

  test "send_error with metadata" do
    with_mocks([
      {Appsignal.Transaction, [:passthrough], []},
      {Appsignal.TransactionRegistry, [:passthrough], [remove_transaction: fn(t) -> :ok end]},
    ]) do
      stack = System.stacktrace()
      Appsignal.send_error(%RuntimeError{message: "Some bad stuff happened"}, "Oops", stack, %{foo: "bar"})

      t = %Transaction{} = TransactionRegistry.lookup(self())

      assert called TransactionRegistry.remove_transaction(t)

      assert called Transaction.set_error(t, "RuntimeError", "Oops: Some bad stuff happened", stack)
      assert called Transaction.set_meta_data(t, :foo, "bar")
      assert called Transaction.finish(t)
      assert called Transaction.complete(t)
    end
  end

  test "send_error with metadata and conn" do
    with_mocks([
      {Appsignal.Transaction, [:passthrough], []},
      {Appsignal.TransactionRegistry, [:passthrough], [remove_transaction: fn(t) -> :ok end]},
    ]) do

      conn = %Plug.Conn{peer: {{127, 0, 0, 1}, 12345}, req_headers: [{"accept", "text/plain"}]}
      stack = System.stacktrace()
      Appsignal.send_error(%RuntimeError{message: "Some bad stuff happened"}, "Oops", stack, %{foo: "bar"}, conn)

      t = %Transaction{} = TransactionRegistry.lookup(self())
      env = %{
        "host" => "www.example.com", "method" => "GET",
        "peer" => "127.0.0.1:12345", "port" => 0, "query_string" => "",
        "request_path" => "", "request_uri" => "http://www.example.com:0",
        "script_name" => [], "req_headers.accept" => "text/plain",
      }

      assert called TransactionRegistry.remove_transaction(t)

      assert called Transaction.set_error(t, "RuntimeError", "Oops: Some bad stuff happened", stack)
      assert called Transaction.set_meta_data(t, :foo, "bar")
      assert called Transaction.set_sample_data(t, "environment", env)
      assert called Transaction.set_request_metadata(t, conn)
      assert called Transaction.finish(t)
      assert called Transaction.complete(t)
    end
  end

  test "send_error with a passed function" do
    with_mocks([
      {Appsignal.Transaction, [:passthrough], []},
      {Appsignal.TransactionRegistry, [:passthrough], [remove_transaction: fn(t) -> :ok end]},
    ]) do
      stack = System.stacktrace()
      Appsignal.send_error(
        %RuntimeError{message: "Some bad stuff happened"},
        "Oops",
        stack,
        %{},
        nil,
        fn(t) -> Transaction.set_sample_data(t, "key", %{foo: "bar"}) end
      )

      t = %Transaction{} = TransactionRegistry.lookup(self())

      assert called TransactionRegistry.remove_transaction(t)

      assert called Transaction.start(:_, :http_request)
      assert called Transaction.set_error(t, "RuntimeError", "Oops: Some bad stuff happened", stack)
      assert called Transaction.set_sample_data(t, "key", %{foo: "bar"})
      assert called Transaction.finish(t)
      assert called Transaction.complete(t)
    end
  end

  test "send_error with a custom namespace" do
    with_mocks([
      {Appsignal.Transaction, [:passthrough], []},
      {Appsignal.TransactionRegistry, [:passthrough], [remove_transaction: fn(t) -> :ok end]},
    ]) do
      stack = System.stacktrace()
      Appsignal.send_error(
        %RuntimeError{message: "Some bad stuff happened"},
        "Oops",
        stack,
        %{},
        nil,
        fn(transaction) -> transaction end,
        :background_job
      )

      t = %Transaction{} = TransactionRegistry.lookup(self())

      assert called TransactionRegistry.remove_transaction(t)

      assert called Transaction.start(:_, :background_job)
      assert called Transaction.set_error(t, "RuntimeError", "Oops: Some bad stuff happened", stack)
      assert called Transaction.finish(t)
      assert called Transaction.complete(t)
    end
  end
end
