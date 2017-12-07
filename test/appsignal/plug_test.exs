defmodule UsingAppsignalPlug do
  def call(%Plug.Conn{private: %{phoenix_action: :exception}}, _opts) do
    raise("Exception!")
  end
  def call(%Plug.Conn{private: %{phoenix_action: :timeout}}, _opts) do
    Task.async(fn -> :timer.sleep(10) end) |> Task.await(1)
  end
  def call(%Plug.Conn{private: %{phoenix_action: :bad_request}}, _opts) do
    raise %Plug.BadRequestError{}
  end
  def call(%Plug.Conn{private: %{phoenix_action: :undef}} = conn, _opts) do
    raise %Plug.Conn.WrapperError{
      kind: :error, reason: :undef, stack: System.stacktrace, conn: conn
    }
  end
  def call(%Plug.Conn{} = conn, _opts) do
    conn |> Plug.Conn.assign(:called?, true)
  end

  defoverridable [call: 2]

  use Appsignal.Plug
end

defmodule Appsignal.PlugTest do
  use ExUnit.Case
  alias Appsignal.FakeTransaction

  setup do
    {:ok, fake_transaction} = FakeTransaction.start_link
    [fake_transaction: fake_transaction]
  end

  describe "for a :sample transaction" do
    setup do
      conn = %Plug.Conn{}
      |> Plug.Conn.put_private(:phoenix_controller, AppsignalPhoenixExample.PageController)
      |> Plug.Conn.put_private(:phoenix_action, :index)
      |> UsingAppsignalPlug.call(%{})

      [conn: conn]
    end

    test "starts a transaction", %{fake_transaction: fake_transaction} do
      assert FakeTransaction.started_transaction?(fake_transaction)
    end

    test "calls super and returns the conn", %{conn: conn} do
      assert conn.assigns[:called?]
    end

    test "sets the transaction's action name", %{fake_transaction: fake_transaction} do
      assert "AppsignalPhoenixExample.PageController#index"
        == FakeTransaction.action(fake_transaction)
    end

    test "finishes the transaction", %{fake_transaction: fake_transaction} do
      assert [%Appsignal.Transaction{}] = FakeTransaction.finished_transactions(fake_transaction)
    end

    test "sets the transaction's request metadata", %{conn: conn, fake_transaction: fake_transaction} do
      assert conn == FakeTransaction.request_metadata(fake_transaction)
    end

    test "completes the transaction", %{fake_transaction: fake_transaction} do
      assert [%Appsignal.Transaction{}] =
        FakeTransaction.completed_transactions(fake_transaction)
    end
  end

  describe "for a :no_sample transaction" do
    setup %{fake_transaction: fake_transaction} do
      FakeTransaction.update(fake_transaction, :finish, :no_sample)

      conn = %Plug.Conn{}
      |> Plug.Conn.put_private(:phoenix_controller, AppsignalPhoenixExample.PageController)
      |> Plug.Conn.put_private(:phoenix_action, :index)
      |> UsingAppsignalPlug.call(%{})

      [conn: conn]
    end

    test "does not set the transaction's request metadata", %{fake_transaction: fake_transaction} do
      assert nil == FakeTransaction.request_metadata(fake_transaction)
    end
  end

  describe "for a transaction with a Phoenix endpoint, but no action" do
    setup do
      conn = %Plug.Conn{}
      |> Plug.Conn.put_private(:phoenix_endpoint, MyEndpoint)
      |> UsingAppsignalPlug.call(%{})

      [conn: conn]
    end

    test "does not set the transaction's action name", %{fake_transaction: fake_transaction} do
      assert FakeTransaction.action(fake_transaction) == nil
    end
  end

  describe "for a transaction with an error" do
    setup do
      conn = %Plug.Conn{}
      |> Plug.Conn.put_private(:phoenix_controller, AppsignalPhoenixExample.PageController)
      |> Plug.Conn.put_private(:phoenix_action, :exception)

      :ok = try do
        UsingAppsignalPlug.call(conn, %{})
      catch
        :error, %RuntimeError{message: "Exception!"} -> :ok
        type, reason -> {type, reason}
      end

      [conn: conn]
    end

    test "sets the transaction error", %{fake_transaction: fake_transaction} do
      assert [{
        %Appsignal.Transaction{},
        "RuntimeError",
        "HTTP request error: Exception!",
        _stack
      }] = FakeTransaction.errors(fake_transaction)
    end

    test "sets the transaction's action name", %{fake_transaction: fake_transaction} do
      assert "AppsignalPhoenixExample.PageController#exception"
        == FakeTransaction.action(fake_transaction)
    end

    test "finishes the transaction", %{fake_transaction: fake_transaction} do
      assert [%Appsignal.Transaction{}] =
        FakeTransaction.finished_transactions(fake_transaction)
    end

    test "sets the transaction's request metadata", %{conn: conn, fake_transaction: fake_transaction} do
      assert Plug.Conn.put_status(conn, 500) ==
        FakeTransaction.request_metadata(fake_transaction)
    end

    test "completes the transaction", %{fake_transaction: fake_transaction} do
      assert [%Appsignal.Transaction{}] = FakeTransaction.completed_transactions(fake_transaction)
    end
  end

  describe "for a transaction with a bad request error" do
    setup do
      conn = %Plug.Conn{}
      |> Plug.Conn.put_private(:phoenix_controller, AppsignalPhoenixExample.PageController)
      |> Plug.Conn.put_private(:phoenix_action, :bad_request)

      [conn: conn]
    end

    test "does not set the transaction error", %{conn: conn, fake_transaction: fake_transaction} do
      :ok = try do
        UsingAppsignalPlug.call(conn, %{})
      catch
        :error, %Plug.BadRequestError{} -> :ok
        type, reason -> {type, reason}
      end

      assert [] = FakeTransaction.errors(fake_transaction)
    end
  end

  describe "for a wrapped undefined error" do
    setup do
      conn = %Plug.Conn{}
      |> Plug.Conn.put_private(:phoenix_controller, AppsignalPhoenixExample.PageController)
      |> Plug.Conn.put_private(:phoenix_action, :undef)

      [conn: conn]
    end

    test "sets the transaction error", %{conn: conn, fake_transaction: fake_transaction} do
      :ok = try do
        UsingAppsignalPlug.call(conn, %{})
      rescue
        Plug.Conn.WrapperError -> :ok
      end

      assert [{
        %Appsignal.Transaction{},
        "UndefinedFunctionError",
        "HTTP request error: undefined function",
        _stack
      }] = FakeTransaction.errors(fake_transaction)
    end
  end

  describe "for a transaction with an timeout" do
    setup do
      conn = %Plug.Conn{}
      |> Plug.Conn.put_private(:phoenix_controller, AppsignalPhoenixExample.PageController)
      |> Plug.Conn.put_private(:phoenix_action, :timeout)

      [conn: conn]
    end

    test "sets the transaction error", %{conn: conn, fake_transaction: fake_transaction} do
      :ok = try do
        UsingAppsignalPlug.call(conn, %{})
      catch
        :exit, {:timeout, {Task, :await, _}} -> :ok
        type, reason -> {type, reason}
      end

      assert [{
        %Appsignal.Transaction{},
        ":timeout",
        "HTTP request error: {:timeout, {Task, :await, [%Task{owner: " <> _,
        _stack
      }] = FakeTransaction.errors(fake_transaction)
    end
  end

  describe "extracting error metadata" do
    test "with a RuntimeError" do
      assert Appsignal.Plug.extract_error_metadata(%RuntimeError{})
        == {"RuntimeError", "HTTP request error: runtime error"}
    end

    test "with a Plug.Conn.WrapperError" do
      error = %Plug.Conn.WrapperError{reason: %RuntimeError{}}

      assert Appsignal.Plug.extract_error_metadata(error)
        == {"RuntimeError", "HTTP request error: runtime error"}
    end

    test "with an error tuple" do
      error = {:timeout,
       {Task, :await,
        [%Task{owner: self(), pid: self(), ref: make_ref()},
         1]}}

      assert Appsignal.Plug.extract_error_metadata(error)
        == {":timeout", "HTTP request error: #{inspect(error)}"}
    end

    test "ignores errors with a plug_status < 500" do
      assert Appsignal.Plug.extract_error_metadata(%Plug.BadRequestError{})
        == nil
    end
  end

  describe "extracting action names" do
    test "from a Plug conn" do
      assert Appsignal.Plug.extract_action(
        %Plug.Conn{method: "GET", request_path: "/foo"}
      ) == "GET /foo"
    end

    test "from a Plug conn with a Phoenix endpoint, but no controller or action" do
      assert %Plug.Conn{}
      |> Plug.Conn.put_private(:phoenix_endpoint, MyEndpoint)
      |> Appsignal.Plug.extract_action == nil
    end

    test "from a Plug conn with a Phoenix controller and action" do
      assert %Plug.Conn{}
      |> Plug.Conn.put_private(:phoenix_controller, AppsignalPhoenixExample.PageController)
      |> Plug.Conn.put_private(:phoenix_action, :index)
      |> Appsignal.Plug.extract_action == "AppsignalPhoenixExample.PageController#index"
    end
  end

  describe "extracting request metadata" do
    test "from a Plug conn" do
      assert Appsignal.Plug.extract_meta_data(
        %Plug.Conn{
          method: "GET",
          request_path: "/foo",
          resp_headers: [{"x-request-id", "kk4hk5sis7c3b56t683nnmdig632c9ot"}]
        }
      ) == %{
        "method" => "GET",
        "path" => "/foo",
        "request_id" => "kk4hk5sis7c3b56t683nnmdig632c9ot"
      }
    end
  end

  describe "extracting sample data" do
    setup do
      %{conn: %Plug.Conn{
        params: %{"foo" => "bar"},
        host: "www.example.com",
        method: "GET",
        script_name: ["foo", "bar"],
        request_path: "/foo/bar",
        port: 80,
        query_string: "foo=bar",
        peer: {{127, 0, 0, 1}, 12345},
        scheme: :http,
        req_headers: [{"accept", "text/html"}]
      }}
    end

    test "from a Plug conn", %{conn: conn} do
      assert Appsignal.Plug.extract_sample_data(conn) == %{
        "params" => %{"foo" => "bar"},
        "environment" => %{
          "host" => "www.example.com",
          "method" => "GET",
          "script_name" => ["foo", "bar"],
          "request_path" => "/foo/bar",
          "port" => 80,
          "query_string" => "foo=bar",
          "peer" => "127.0.0.1:12345",
          "request_uri" => "http://www.example.com:80/foo/bar",
          "req_headers.accept" => "text/html"
        }
      }
    end

    test "with a param that should be filtered out", %{conn: conn} do
      AppsignalTest.Utils.with_config(%{filter_parameters: ["password"]}, fn() ->
        conn = %{conn | params: %{"password" => "secret"}}
        assert %{"params" => %{"password" => "[FILTERED]"}} =
          Appsignal.Plug.extract_sample_data(conn)
      end)
    end
  end

  describe "extracting request headers" do
    test "from a Plug conn" do
      conn = %Plug.Conn{
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

          {"cookie", "__ar_v4=U35IKTLTJNEP7GWW6OH3N2%3A20161120%3A90%7CI..."}
        ]
      }

      assert Appsignal.Plug.extract_request_headers(conn) == %{
        "req_headers.content-length" => "1024",
        "req_headers.accept" => "text/html",
        "req_headers.accept-charset" => "utf-8",
        "req_headers.accept-encoding" => "gzip, deflate",
        "req_headers.accept-language" => "en-us",
        "req_headers.cache-control" => "no-cache",
        "req_headers.connection" => "keep-alive",
        "req_headers.user-agent" => "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_12_3...",
        "req_headers.from" => "webmaster@example.org",
        "req_headers.referer" => "http://localhost:4001/",
        "req_headers.range" => "bytes=0-1023"
      }
    end
  end
end
