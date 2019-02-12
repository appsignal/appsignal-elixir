defmodule AppsignalTest do
  use ExUnit.Case, async: true
  import AppsignalTest.Utils
  import ExUnit.CaptureIO

  alias Appsignal.{FakeTransaction, Transaction}

  setup do
    {:ok, fake_transaction} = FakeTransaction.start_link()
    [fake_transaction: fake_transaction]
  end

  test "set gauge" do
    Appsignal.set_gauge("key", 10.0)
    Appsignal.set_gauge("key", 10)
    Appsignal.set_gauge("key", 10.0, %{:a => "b"})
    Appsignal.set_gauge("key", 10, %{:a => "b"})
  end

  test "increment counter" do
    Appsignal.increment_counter("counter")
    Appsignal.increment_counter("counter", 5)
    Appsignal.increment_counter("counter", 5, %{:a => "b"})
    Appsignal.increment_counter("counter", 5.0)
    Appsignal.increment_counter("counter", 5.0, %{:a => "b"})
  end

  test "add distribution value" do
    Appsignal.add_distribution_value("dist_key", 10.0)
    Appsignal.add_distribution_value("dist_key", 10)
    Appsignal.add_distribution_value("dist_key", 10.0, %{:a => "b"})
    Appsignal.add_distribution_value("dist_key", 10, %{:a => "b"})
  end

  describe "plug?/0" do
    test "is true when Plug is loaded" do
      assert Appsignal.plug?() == true
    end
  end

  describe "phoenix?/0" do
    @tag :skip_env_test
    @tag :skip_env_test_no_nif
    test "is true when Phoenix is loaded" do
      assert Appsignal.phoenix?() == true
    end

    @tag :skip_env_test_phoenix
    test "is false when Phoenix is not loaded" do
      assert Appsignal.phoenix?() == false
    end
  end

  test "Agent environment variables" do
    with_env(%{"APPSIGNAL_APP_ENV" => "test"}, fn ->
      Appsignal.Config.initialize()

      env = Appsignal.Config.get_system_env()
      assert "test" = env["APPSIGNAL_APP_ENV"]

      config = Application.get_env(:appsignal, :config)
      assert :test = config[:env]
    end)
  end

  test "send_error", %{fake_transaction: fake_transaction} do
    transaction = Appsignal.send_error(%RuntimeError{message: "Exception!"}, "Error occurred", [])

    assert [{^transaction, "RuntimeError", "Error occurred: Exception!", []}] =
             FakeTransaction.errors(fake_transaction)

    assert [^transaction] = FakeTransaction.finished_transactions(fake_transaction)
    assert [^transaction] = FakeTransaction.completed_transactions(fake_transaction)
  end

  test "send_error without a stack trace", %{fake_transaction: fake_transaction} do
    output =
      capture_io(:stderr, fn ->
        transaction = Appsignal.send_error(%RuntimeError{message: "Exception!"})
        send(self(), transaction)
      end)

    assert output =~
             "Appsignal.send_error/1-7 without passing a stack trace is deprecated, and defaults to passing an empty stacktrace."

    transaction =
      receive do
        transaction = %Transaction{} -> transaction
      end

    assert [{^transaction, "RuntimeError", "Exception!", []}] =
             FakeTransaction.errors(fake_transaction)

    assert [^transaction] = FakeTransaction.finished_transactions(fake_transaction)
    assert [^transaction] = FakeTransaction.completed_transactions(fake_transaction)
  end

  test "send_error with metadata", %{fake_transaction: fake_transaction} do
    transaction =
      Appsignal.send_error(%RuntimeError{message: "Exception!"}, "Error occurred", [], %{
        foo: "bar"
      })

    assert [{^transaction, "RuntimeError", "Error occurred: Exception!", _stack}] =
             FakeTransaction.errors(fake_transaction)

    assert %{foo: "bar"} = FakeTransaction.metadata(fake_transaction)
    assert [^transaction] = FakeTransaction.finished_transactions(fake_transaction)
    assert [^transaction] = FakeTransaction.completed_transactions(fake_transaction)
  end

  test "send_error with metadata and conn", %{fake_transaction: fake_transaction} do
    conn = %Plug.Conn{req_headers: [{"accept", "text/plain"}]}

    transaction =
      Appsignal.send_error(
        %RuntimeError{message: "Exception!"},
        "Error occurred",
        [],
        %{foo: "bar"},
        conn
      )

    assert [{^transaction, "RuntimeError", "Error occurred: Exception!", _stack}] =
             FakeTransaction.errors(fake_transaction)

    assert %{foo: "bar"} = FakeTransaction.metadata(fake_transaction)
    assert ^conn = FakeTransaction.request_metadata(fake_transaction)
    assert [^transaction] = FakeTransaction.finished_transactions(fake_transaction)
    assert [^transaction] = FakeTransaction.completed_transactions(fake_transaction)
  end

  test "send_error with a passed function", %{fake_transaction: fake_transaction} do
    transaction =
      Appsignal.send_error(
        %RuntimeError{message: "Exception!"},
        "Error occurred",
        [],
        %{},
        nil,
        fn t -> FakeTransaction.set_sample_data(t, "key", %{foo: "bar"}) end
      )

    assert [{^transaction, "RuntimeError", "Error occurred: Exception!", _stack}] =
             FakeTransaction.errors(fake_transaction)

    assert %{"key" => %{foo: "bar"}} = FakeTransaction.sample_data(fake_transaction)
    assert [^transaction] = FakeTransaction.finished_transactions(fake_transaction)
    assert [^transaction] = FakeTransaction.completed_transactions(fake_transaction)
  end

  test "send_error with a custom namespace", %{fake_transaction: fake_transaction} do
    transaction =
      Appsignal.send_error(
        %RuntimeError{message: "Exception!"},
        "Error occurred",
        [],
        %{},
        nil,
        fn transaction -> transaction end,
        :background_job
      )

    assert [{^transaction, "RuntimeError", "Error occurred: Exception!", _stack}] =
             FakeTransaction.errors(fake_transaction)

    assert [{"_123", :background_job}] = FakeTransaction.created_transactions(fake_transaction)
    assert [^transaction] = FakeTransaction.finished_transactions(fake_transaction)
    assert [^transaction] = FakeTransaction.completed_transactions(fake_transaction)
  end
end
