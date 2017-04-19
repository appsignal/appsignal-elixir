defmodule AppsignalTransactionTest do
  use ExUnit.Case
  import Mock
  import AppsignalTest.Utils

  alias Appsignal.Transaction

  test "transaction lifecycle" do
    transaction = Transaction.start("test1", :http_request)
    assert %Transaction{} = transaction

    assert ^transaction = Transaction.start_event(transaction)
    assert ^transaction = Transaction.finish_event(transaction, "sql.query", "Model load", "SELECT * FROM table;", 1)
    assert ^transaction = Transaction.record_event(transaction, "sql.query", "Model load", "SELECT * FROM table;", 1000 * 1000 * 3, 1)
    assert ^transaction = Transaction.set_error(transaction, "Error", "error message", ['backtrace'])
    assert ^transaction = Transaction.set_sample_data(transaction, "key", %{user_id: 1})
    assert ^transaction = Transaction.set_action(transaction, "GET:/")
    assert ^transaction = Transaction.set_queue_start(transaction, 1000)
    assert ^transaction = Transaction.set_meta_data(transaction, "email", "info@info.com")
    assert [:sample, :no_sample] |> Enum.member?(Transaction.finish(transaction))
    assert :ok = Transaction.complete(transaction)
  end

  test "use default transaction in Transaction calls" do

    transaction = Transaction.start("test2", :http_request)
    assert %Transaction{} = transaction

    assert ^transaction = Transaction.start_event()
    assert ^transaction = Transaction.finish_event("sql.query", "Model load", "SELECT * FROM table;", 1)
    assert ^transaction = Transaction.record_event("sql.query", "Model load", "SELECT * FROM table;", 1000 * 1000 * 3, 1)
    assert ^transaction = Transaction.set_error("Error", "error message", ['backtrace'])
    assert ^transaction = Transaction.set_sample_data("key", %{user_id: 1})
    assert ^transaction = Transaction.set_action("GET:/")
    assert ^transaction = Transaction.set_queue_start(1000)
    assert ^transaction = Transaction.set_meta_data("email", "info@info.com")
    assert [:sample, :no_sample] |> Enum.member?(Transaction.finish())
    assert :ok = Transaction.complete()

  end


  test "returns nil in simplified Transaction calls when no current transaction" do

    assert nil == Transaction.start_event()
    assert nil == Transaction.finish_event("sql.query", "Model load", "SELECT * FROM table;", 1)
    assert nil == Transaction.record_event("sql.query", "Model load", "SELECT * FROM table;", 1000 * 1000 * 3, 1)
    assert nil == Transaction.set_error("Error", "error message", "['backtrace']")
    assert nil == Transaction.set_sample_data("key", "{'user_id': 1}")
    assert nil == Transaction.set_action("GET:/")
    assert nil == Transaction.set_queue_start(1000)

    assert nil == Transaction.set_meta_data("email", "info@info.com")
    assert nil == Transaction.set_meta_data(email: "email@email.com")
    assert nil == Transaction.set_meta_data(%{"foo" => "bar", "value" => 123})

    assert nil == Transaction.finish()
    assert nil == Transaction.complete()

  end

  test_with_mock "use shorthand set_meta_data function", Appsignal.Nif, [], [
    start_transaction: fn(_,_) -> {:ok, nil} end,
    set_meta_data: fn(_,_,_) -> :ok end
  ] do
    transaction = Transaction.start("test3", :http_request)
    assert %Transaction{} = transaction

    Transaction.set_meta_data(email: "email@email.com")
    assert called Appsignal.Nif.set_meta_data(transaction.resource, "email", "email@email.com")

    Transaction.set_meta_data(%{"foo" => "bar", "value" => 123})
    assert called Appsignal.Nif.set_meta_data(transaction.resource, "foo", "bar")
    assert called Appsignal.Nif.set_meta_data(transaction.resource, "value", "123")
  end

  test "data encoding" do
    transaction = Transaction.start("test3", :http_request)

    # Map
    assert ^transaction = Transaction.set_sample_data("key", %{"user_id" => 1})

    # Atom
    assert ^transaction = Transaction.set_sample_data("key", %{user_id: 1})

    # complex
    assert ^transaction = Transaction.set_sample_data("key", %{values: %{1 => 2, 3 => 4}})
  end

  test "finishing an event with a non-string body" do
    transaction = Transaction.start("test4", :http_request)
    assert %Transaction{} = transaction

    assert ^transaction = Transaction.start_event(transaction)
    assert ^transaction = Transaction.finish_event(transaction, "render.phoenix_controller", "phoenix_controller_render", %{format: "html", template: "index.html"}, 0)
  end

  test "handles unformatted stacktraces" do
    transaction = Transaction.start("test1", :http_request)
    stacktrace =  [{:elixir_translator, :guard_op, 2, [file: 'src/elixir_translator.erl', line: 317]}]
    assert ^transaction = Transaction.set_error(transaction, "Error", "error message", stacktrace)
    assert ^transaction = Transaction.start_event(transaction)
    assert ^transaction = Transaction.finish_event(transaction, "render.phoenix_controller", "phoenix_controller_render", %{format: "html", template: "index.html"}, 0)
  end

  describe "concerning skipping session data" do
    setup do
      conn = %Plug.Conn{peer: {{127, 0, 0, 1}, 12345}}
      |> Plug.Conn.put_private(:plug_session, %{})
      |> Plug.Conn.put_private(:plug_session_fetch, :done)

      {:ok, conn: conn}
    end

    @tag :skip_env_test_no_nif
    @tag :skip_env_test
    test_with_mock "sends session data", context, Appsignal.Transaction, [:passthrough], [] do
      transaction = "test5"
      |> Transaction.start(:http_request)
      |> Transaction.set_request_metadata(context[:conn])

      assert called Transaction.set_sample_data(
        transaction, "session_data", context[:conn].private.plug_session
      )
    end

    @tag :skip_env_test_no_nif
    @tag :skip_env_test
    test_with_mock "sends session data when skip_session_data is false", context, Appsignal.Transaction, [:passthrough], [] do
      transaction = with_config(%{skip_session_data: false}, fn() ->
        "test5"
        |> Transaction.start(:http_request)
        |> Transaction.set_request_metadata(context[:conn])
      end)

      assert called Appsignal.Transaction.set_sample_data(
        transaction, "session_data", context[:conn].private.plug_session
      )
    end

    @tag :skip_env_test_no_nif
    @tag :skip_env_test
    test_with_mock "does not send session data when skip_session_data is true", context, Appsignal.Transaction, [:passthrough], [] do
      transaction = with_config(%{skip_session_data: true}, fn() ->
        "test5"
        |> Transaction.start(:http_request)
        |> Transaction.set_request_metadata(context[:conn])
      end)

      assert not called Appsignal.Transaction.set_sample_data(
        transaction, "session_data", context[:conn].private.plug_session
      )
    end
  end
end
