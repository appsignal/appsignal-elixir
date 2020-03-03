defmodule PlugWithAppSignal do
  use Plug.Router
  use Appsignal.Plug
  use Plug.ErrorHandler

  plug(:match)
  plug(:dispatch)

  get "/" do
    send_resp(conn, 200, "Welcome")
  end

  get "/overwritten" do
    Appsignal.FakeTransaction.set_action("AppsignalPhoenixExample.PageController#overwritten")

    send_resp(conn, 200, "Welcome")
  end

  get "/exception" do
    raise("Exception!")
    send_resp(conn, 200, "Welcome")
  end

  get "/bad_request" do
    raise %Plug.BadRequestError{}
    send_resp(conn, 200, "Welcome")
  end

  get "/undef" do
    raise %Plug.Conn.WrapperError{
      kind: :error,
      reason: :undef,
      stack: [],
      conn: %{conn | params: %{"foo" => "bar"}}
    }

    send_resp(conn, 200, "Welcome")
  end

  get "/no_transaction" do
    new_private = Map.delete(conn.private, :appsignal_transaction)

    raise %Plug.Conn.WrapperError{
      kind: :error,
      reason: :undef,
      stack: [],
      conn: %{conn | private: new_private}
    }

    send_resp(conn, 200, "Welcome")
  end

  get "/timeout" do
    Task.async(fn -> :timer.sleep(10) end) |> Task.await(1)

    send_resp(conn, 200, "Welcome")
  end

  defp handle_errors(conn, error) do
    send_resp(conn, conn.status, inspect(error))
  end
end

defmodule ModuleWithCall do
  defmacro __using__(_) do
    quote do
      def call(%Plug.Conn{} = conn, _opts) do
        Plug.Conn.assign(conn, :called?, true)
      end

      defoverridable call: 2
    end
  end
end

defmodule OverridingAppSignalPlug do
  use ModuleWithCall
  use Appsignal.Plug

  def call(conn, opts) do
    conn = super(conn, opts)
    Plug.Conn.assign(conn, :overridden?, true)
  end
end

defmodule Appsignal.PlugTest do
  alias Appsignal.FakeTransaction
  import AppsignalTest.Utils
  use ExUnit.Case
  use Plug.Test

  setup do
    {:ok, fake_transaction} = FakeTransaction.start_link()
    [fake_transaction: fake_transaction]
  end

  describe "for a :sample transaction" do
    setup do
      conn =
        :get
        |> conn("/", "")
        |> Plug.Conn.put_private(:phoenix_controller, AppsignalPhoenixExample.PageController)
        |> Plug.Conn.put_private(:phoenix_action, :index)
        |> PlugWithAppSignal.call([])

      [conn: conn]
    end

    test "starts a transaction", %{fake_transaction: fake_transaction} do
      assert FakeTransaction.started_transaction?(fake_transaction)
    end

    test "returns the updated conn", %{conn: conn} do
      assert conn.state == :sent
    end

    test "adds the transaction to the conn", %{conn: conn} do
      assert %Appsignal.Transaction{id: "123"} = conn.private[:appsignal_transaction]
    end

    test "sets the transaction's action name", %{fake_transaction: fake_transaction} do
      assert "AppsignalPhoenixExample.PageController#index" ==
               FakeTransaction.action(fake_transaction)
    end

    test "finishes the transaction", %{fake_transaction: fake_transaction} do
      assert [%Appsignal.Transaction{}] = FakeTransaction.finished_transactions(fake_transaction)
    end

    test "sets the transaction's request metadata", %{
      conn: conn,
      fake_transaction: fake_transaction
    } do
      assert conn == FakeTransaction.request_metadata(fake_transaction)
    end

    test "completes the transaction", %{fake_transaction: fake_transaction} do
      assert [%Appsignal.Transaction{}] = FakeTransaction.completed_transactions(fake_transaction)
    end
  end

  describe "for a :no_sample transaction" do
    setup %{fake_transaction: fake_transaction} do
      FakeTransaction.update(fake_transaction, :finish, :no_sample)

      conn =
        :get
        |> conn("/", "")
        |> Plug.Conn.put_private(:phoenix_controller, AppsignalPhoenixExample.PageController)
        |> Plug.Conn.put_private(:phoenix_action, :index)
        |> PlugWithAppSignal.call([])

      [conn: conn]
    end

    test "does not set the transaction's request metadata", %{fake_transaction: fake_transaction} do
      assert nil == FakeTransaction.request_metadata(fake_transaction)
    end
  end

  describe "for a transaction without a Phoenix endpoint" do
    setup do
      conn =
        :get
        |> conn("/", "")
        |> PlugWithAppSignal.call([])

      [conn: conn]
    end

    test "does not set the transaction's action name", %{fake_transaction: fake_transaction} do
      assert FakeTransaction.action(fake_transaction) == "unknown"
    end
  end

  describe "for a transaction with a Phoenix endpoint, but no action" do
    setup do
      conn =
        :get
        |> conn("/", "")
        |> Plug.Conn.put_private(:phoenix_endpoint, MyEndpoint)
        |> PlugWithAppSignal.call([])

      [conn: conn]
    end

    test "does not set the transaction's action name", %{fake_transaction: fake_transaction} do
      assert FakeTransaction.action(fake_transaction) == nil
    end
  end

  describe "for a transaction with an overwritten action name" do
    setup do
      conn =
        :get
        |> conn("/overwritten", "")
        |> PlugWithAppSignal.call([])

      [conn: conn]
    end

    test "sets the transaction's action name", %{fake_transaction: fake_transaction} do
      assert "AppsignalPhoenixExample.PageController#overwritten" ==
               FakeTransaction.action(fake_transaction)
    end
  end

  describe "for a transaction with an error" do
    setup do
      try do
        :get
        |> conn("/exception", %{"foo" => "bar"})
        |> Plug.Conn.put_private(:phoenix_controller, AppsignalPhoenixExample.PageController)
        |> Plug.Conn.put_private(:phoenix_action, :exception)
        |> PlugWithAppSignal.call([])
      catch
        :error, %Plug.Conn.WrapperError{reason: %RuntimeError{message: "Exception!"}} ->
          :ok

        type, reason ->
          {type, reason}
      end
    end

    test "sets the transaction's action name", %{fake_transaction: fake_transaction} do
      assert "AppsignalPhoenixExample.PageController#exception" ==
               FakeTransaction.action(fake_transaction)
    end

    test "finishes the transaction", %{fake_transaction: fake_transaction} do
      assert [%Appsignal.Transaction{}] = FakeTransaction.finished_transactions(fake_transaction)
    end

    test "sets the transaction's request metadata", %{
      fake_transaction: fake_transaction
    } do
      assert %Plug.Conn{params: %{"foo" => "bar"}} =
               FakeTransaction.request_metadata(fake_transaction)
    end

    test "completes the transaction", %{fake_transaction: fake_transaction} do
      assert [%Appsignal.Transaction{}] = FakeTransaction.completed_transactions(fake_transaction)
    end

    test "ignores the process' pid" do
      until(fn ->
        assert Appsignal.TransactionRegistry.lookup(self()) == :ignored
      end)
    end
  end

  describe "for a transaction with a bad request error" do
    setup do
      [conn: conn(:get, "/bad_request", "")]
    end

    test "does not set the transaction error", %{conn: conn, fake_transaction: fake_transaction} do
      :ok =
        try do
          PlugWithAppSignal.call(conn, %{})
        catch
          :error, %Plug.Conn.WrapperError{reason: %Plug.BadRequestError{}} -> :ok
          type, reason -> {type, reason}
        end

      assert [] = FakeTransaction.errors(fake_transaction)
    end
  end

  describe "for a wrapped undefined error" do
    setup do
      :ok =
        try do
          :get
          |> conn("/undef", %{"foo" => "bar"})
          |> PlugWithAppSignal.call([])
        rescue
          Plug.Conn.WrapperError -> :ok
        end
    end

    test "sets the transaction's request metadata", %{
      fake_transaction: fake_transaction
    } do
      assert %Plug.Conn{params: %{"foo" => "bar"}} =
               FakeTransaction.request_metadata(fake_transaction)
    end
  end

  describe "for a conn without a transaction" do
    setup do
      :ok =
        try do
          :get
          |> conn("/no_transaction")
          |> PlugWithAppSignal.call([])
        rescue
          Plug.Conn.WrapperError -> :ok
        end
    end

    test "does not set a transaction error", %{fake_transaction: fake_transaction} do
      assert [] = FakeTransaction.errors(fake_transaction)
    end
  end

  describe "when AppSignal is disabled" do
    setup do
      conn =
        AppsignalTest.Utils.with_config(%{active: false}, fn ->
          :get
          |> conn("/", "")
          |> PlugWithAppSignal.call([])
        end)

      [conn: conn]
    end

    test "does not start a transaction", %{fake_transaction: fake_transaction} do
      refute FakeTransaction.started_transaction?(fake_transaction)
    end

    test "returns the updated conn", %{conn: conn} do
      assert conn.state == :sent
    end
  end

  describe "extracting action names" do
    test "from a Plug conn" do
      assert Appsignal.Plug.extract_action(%Plug.Conn{method: "GET", request_path: "/foo"}) ==
               "unknown"
    end

    test "from a Plug conn with a Phoenix endpoint, but no controller or action" do
      assert %Plug.Conn{}
             |> Plug.Conn.put_private(:phoenix_endpoint, MyEndpoint)
             |> Appsignal.Plug.extract_action() == nil
    end

    test "from a Plug conn with a Phoenix controller and action" do
      assert %Plug.Conn{}
             |> Plug.Conn.put_private(:phoenix_controller, AppsignalPhoenixExample.PageController)
             |> Plug.Conn.put_private(:phoenix_action, :index)
             |> Appsignal.Plug.extract_action() == "AppsignalPhoenixExample.PageController#index"
    end
  end

  describe "extracting request metadata" do
    test "from a Plug conn" do
      assert Appsignal.Plug.extract_meta_data(%Plug.Conn{
               method: "GET",
               request_path: "/foo",
               resp_headers: [{"x-request-id", "kk4hk5sis7c3b56t683nnmdig632c9ot"}],
               status: 200
             }) == %{
               "method" => "GET",
               "path" => "/foo",
               "request_id" => "kk4hk5sis7c3b56t683nnmdig632c9ot",
               "http_status_code" => 200
             }
    end
  end

  describe "extracting sample data" do
    setup do
      %{
        conn: %Plug.Conn{
          params: %{"foo" => "bar"},
          host: "www.example.com",
          method: "GET",
          script_name: ["foo", "bar"],
          request_path: "/foo/bar",
          port: 80,
          query_string: "foo=bar",
          scheme: :http,
          req_headers: [{"accept", "text/html"}]
        }
      }
    end

    test "from a Plug conn", %{conn: conn} do
      assert Appsignal.Plug.extract_sample_data(conn) == %{
               "params" => %{"foo" => "bar"},
               "environment" => %{
                 "host" => "www.example.com",
                 "method" => "GET",
                 "request_path" => "/foo/bar",
                 "port" => 80,
                 "request_uri" => "http://www.example.com:80/foo/bar",
                 "req_headers.accept" => "text/html"
               }
             }
    end

    test "with a param that should be filtered out", %{conn: conn} do
      AppsignalTest.Utils.with_config(%{filter_parameters: ["password"]}, fn ->
        conn = %{conn | params: %{"password" => "secret"}}

        assert %{"params" => %{"password" => "[FILTERED]"}} =
                 Appsignal.Plug.extract_sample_data(conn)
      end)
    end
  end

  describe "extracting request headers" do
    setup do
      [
        conn: %Plug.Conn{
          req_headers: [
            {"content-length", "1024"},
            {"accept", "text/html"},
            {"accept-charset", "utf-8"},
            {"accept-encoding", "gzip, deflate"},
            {"accept-language", "en-us"},
            {"cache-control", "no-cache"},
            {"connection", "keep-alive"},
            {"user-agent", "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_12_3..."},
            {"from", "webmaster@example.org"},
            {"referer", "http://localhost:4001/"},
            {"range", "bytes=0-1023"},
            {"cookie", "__ar_v4=U35IKTLTJNEP7GWW6OH3N2%3A20161120%3A90%7CI..."},
            {"x-real-ip", "179.146.231.170"}
          ]
        }
      ]
    end

    test "with header key configuration", %{conn: conn} do
      AppsignalTest.Utils.with_config(%{request_headers: ["content-length"]}, fn ->
        assert Appsignal.Plug.extract_request_headers(conn) == %{
                 "req_headers.content-length" => "1024"
               }
      end)
    end

    test "with fallback header keys", %{conn: conn} do
      assert Appsignal.Plug.extract_request_headers(conn) == %{
               "req_headers.content-length" => "1024",
               "req_headers.accept" => "text/html",
               "req_headers.accept-charset" => "utf-8",
               "req_headers.accept-encoding" => "gzip, deflate",
               "req_headers.accept-language" => "en-us",
               "req_headers.cache-control" => "no-cache",
               "req_headers.connection" => "keep-alive",
               "req_headers.range" => "bytes=0-1023"
             }
    end
  end

  describe "handling errors for a wrapped error" do
    setup do
      transaction = %Appsignal.Transaction{}
      conn = %Plug.Conn{private: %{appsignal_transaction: transaction}}
      kind = :error
      wrapped_reason = :undef
      stack = []

      reason = %Plug.Conn.WrapperError{
        kind: kind,
        reason: wrapped_reason,
        stack: stack,
        conn: conn
      }

      :ok =
        try do
          Appsignal.Plug.handle_error(conn, kind, reason, stack)
        rescue
          Plug.Conn.WrapperError -> :ok
        end

      [conn: conn]
    end

    test "sets the transaction's request metdata", %{
      fake_transaction: fake_transaction,
      conn: conn
    } do
      assert conn == FakeTransaction.request_metadata(fake_transaction)
    end
  end

  describe "handling errors for an error with a plug status < 500" do
    test "reraises the error" do
      :ok =
        try do
          transaction = %Appsignal.Transaction{}

          Appsignal.Plug.handle_error(
            %Plug.Conn{private: %{appsignal_transaction: transaction}},
            :error,
            %Plug.BadRequestError{},
            []
          )
        rescue
          Plug.BadRequestError -> :ok
        end
    end
  end

  describe "handling errors for a conn without a transaction" do
    test "reraises the error" do
      :ok =
        try do
          Appsignal.Plug.handle_error(%Plug.Conn{}, :error, :undef, [])
        rescue
          UndefinedFunctionError -> :ok
        end
    end
  end

  describe "when overriding the AppSignal Plug" do
    setup do
      conn = OverridingAppSignalPlug.call(%Plug.Conn{}, %{})

      [conn: conn]
    end

    test "starts a transaction", %{fake_transaction: fake_transaction} do
      assert FakeTransaction.started_transaction?(fake_transaction)
    end

    test "calls super and returns the conn", %{conn: conn} do
      assert conn.assigns[:called?]
    end

    test "calls the overridden call/2", %{conn: conn} do
      assert conn.assigns[:overridden?]
    end
  end
end
