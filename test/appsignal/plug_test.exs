defmodule UsingAppsignalPlug do
  def call(%Plug.Conn{private: %{phoenix_action: :index}} = conn, _opts) do
    conn |> Plug.Conn.assign(:called?, true)
  end
  def call(%Plug.Conn{private: %{phoenix_action: :exception}}, _opts) do
    raise("Exception!")
  end
  def call(%Plug.Conn{private: %{phoenix_action: :timeout}}, _opts) do
    Task.async(fn -> :timer.sleep(10) end) |> Task.await(1)
  end

  defoverridable [call: 2]

  use Appsignal.Plug
end

defmodule Appsignal.PlugTest do
  use ExUnit.Case
  alias Appsignal.FakeTransaction

  setup do
    FakeTransaction.start_link
    :ok
  end

  describe "for a :sample transaction" do
    setup do
      conn = %Plug.Conn{}
      |> Plug.Conn.put_private(:phoenix_controller, AppsignalPhoenixExample.PageController)
      |> Plug.Conn.put_private(:phoenix_action, :index)
      |> UsingAppsignalPlug.call(%{})

      [conn: conn]
    end

    test "starts a transaction" do
      assert FakeTransaction.started_transaction?
    end

    test "calls super and returns the conn", %{conn: conn} do
      assert conn.assigns[:called?]
    end

    test "sets the transaction's action name" do
      assert "AppsignalPhoenixExample.PageController#index" == FakeTransaction.action
    end

    test "finishes the transaction" do
      assert [%Appsignal.Transaction{}] = FakeTransaction.finished_transactions
    end

    test "sets the transaction's request metadata", context do
      assert context[:conn] == FakeTransaction.request_metadata
    end

    test "completes the transaction" do
      assert [%Appsignal.Transaction{}] = FakeTransaction.completed_transactions
    end
  end

  describe "for a :no_sample transaction" do
    setup do
      FakeTransaction.set_finish(:no_sample)

      conn = %Plug.Conn{}
      |> Plug.Conn.put_private(:phoenix_controller, AppsignalPhoenixExample.PageController)
      |> Plug.Conn.put_private(:phoenix_action, :index)
      |> UsingAppsignalPlug.call(%{})

      [conn: conn]
    end

    test "does not set the transaction's request metadata" do
      assert nil == FakeTransaction.request_metadata
    end
  end

  describe "for a transaction with an error" do
    setup do
      conn = %Plug.Conn{}
      |> Plug.Conn.put_private(:phoenix_controller, AppsignalPhoenixExample.PageController)
      |> Plug.Conn.put_private(:phoenix_action, :exception)

      [conn: conn]
    end

    test "sets the transaction error", %{conn: conn} do
      :ok = try do
        UsingAppsignalPlug.call(conn, %{})
      catch
        :error, %RuntimeError{message: "Exception!"} -> :ok
        type, reason -> {type, reason}
      end

      assert [{
        %Appsignal.Transaction{},
        "RuntimeError",
        "HTTP request error: Exception!",
        _stack
      }] = FakeTransaction.errors
    end
  end

  describe "for a transaction with an timeout" do
    setup do
      conn = %Plug.Conn{}
      |> Plug.Conn.put_private(:phoenix_controller, AppsignalPhoenixExample.PageController)
      |> Plug.Conn.put_private(:phoenix_action, :timeout)

      [conn: conn]
    end

    test "sets the transaction error", %{conn: conn} do
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
      }] = FakeTransaction.errors
    end
  end

  describe "extracting error metadata" do
    setup do
      [conn: %Plug.Conn{}, stack: System.stacktrace]
    end

    test "with a reason and a conn", %{conn: conn, stack: stack} do
      error = %RuntimeError{}

      assert Appsignal.Plug.extract_error_metadata(error, conn, stack)
        == {"RuntimeError", "HTTP request error: runtime error", stack, conn}
    end

    test "with a Plug.Conn.WrapperError", %{conn: conn, stack: stack} do
      error = %Plug.Conn.WrapperError{reason: %RuntimeError{}, conn: conn}

      assert Appsignal.Plug.extract_error_metadata(error, conn, stack)
        == {"RuntimeError", "HTTP request error: runtime error", stack, conn}
    end

    test "with an error tuple", %{conn: conn, stack: stack} do
      error = {:timeout,
       {Task, :await,
        [%Task{owner: self(), pid: self(), ref: make_ref()},
         1]}}

      assert Appsignal.Plug.extract_error_metadata(error, conn, stack)
        == {":timeout", "HTTP request error: #{inspect(error)}", stack, conn}
    end

    test "ignores errors with a plug_status < 500", %{conn: conn, stack: stack} do
      error = %Plug.BadRequestError{}

      assert Appsignal.Plug.extract_error_metadata(error, conn, stack)
        == nil
    end
  end

  describe "extracting action names" do
    test "from a Plug conn" do
      assert Appsignal.Plug.extract_action(
        %Plug.Conn{method: "GET", request_path: "/foo"}
      ) == "GET /foo"
    end

    test "from a Plug conn with a Phoenix controller and action" do
      assert %Plug.Conn{}
      |> Plug.Conn.put_private(:phoenix_controller, AppsignalPhoenixExample.PageController)
      |> Plug.Conn.put_private(:phoenix_action, :index)
      |> Appsignal.Plug.extract_action == "AppsignalPhoenixExample.PageController#index"
    end
  end
end
