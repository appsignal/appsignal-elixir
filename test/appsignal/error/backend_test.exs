defmodule CrashingGenServer do
  use GenServer

  def start_link(_opts) do
    GenServer.start(__MODULE__, [])
  end

  def init(opts), do: {:ok, opts}

  def handle_cast(:raise_error, state) do
    _ = Map.fetch!(%{}, :bad_key)

    {:noreply, state}
  end
end

defmodule Appsignal.Error.BackendTest do
  use ExUnit.Case
  import AppsignalTest.Utils
  alias Appsignal.{Error.Backend, Span, Test, Tracer}

  setup do
    {:ok, _pid} = start_supervised(Test.Nif)
    {:ok, _pid} = start_supervised(Test.Tracer)
    {:ok, _pid} = start_supervised(Test.Span)
    {:ok, _pid} = start_supervised(Test.Monitor)

    :ok
  end

  test "is added as a Logger backend" do
    assert {:error, :already_present} = Logger.add_backend(Backend)
  end

  describe "handle_event/3, when no span exists" do
    setup do
      [pid: spawn(fn -> raise "Exception" end)]
    end

    test "creates a span", %{pid: pid} do
      until(fn ->
        assert {:ok, [{"background_job", nil, [pid: ^pid]}]} = Test.Tracer.get(:create_span)
      end)
    end

    test "adds an error to the created span", %{pid: pid} do
      until(fn ->
        assert {:ok, [{%Span{pid: ^pid}, :error, %RuntimeError{message: "Exception"}, stack} | _]} =
                 Test.Span.get(:add_error)

        assert is_list(stack)
      end)
    end

    test "closes the created span" do
      until(fn ->
        assert {:ok, [{%Span{}}]} = Test.Tracer.get(:close_span)
      end)
    end
  end

  describe "handle_event/3, with an open span" do
    setup do
      parent = self()

      pid =
        spawn(fn ->
          span = Tracer.create_span("background_job")
          send(parent, span)
          raise "Exception"
        end)

      span =
        receive do
          span -> span
        end

      [pid: pid, span: span]
    end

    test "adds an error to the existing span", %{span: span} do
      until(fn ->
        assert {:ok, [{^span, :error, %RuntimeError{message: "Exception"}, _stack} | _]} =
                 Test.Span.get(:add_error)
      end)
    end

    test "closes the existing span", %{span: span} do
      until(fn ->
        assert {:ok, [{^span}]} = Test.Tracer.get(:close_span)
      end)
    end
  end

  describe "handle_event/3, with an ignored process" do
    setup do
      [
        pid:
          spawn(fn ->
            Tracer.ignore()
            raise "Exception"
          end)
      ]
    end

    test "does not create a span", %{pid: pid} do
      repeatedly(fn ->
        assert Test.Tracer.get(:create_span) == :error
      end)
    end
  end

  describe "handle_event/3, with a :badarg" do
    setup do
      pid =
        spawn(fn ->
          :erlang.error(:badarg)
        end)

      [pid: pid]
    end

    test "creates a span", %{pid: pid} do
      until(fn ->
        assert {:ok, [{"background_job", nil, [pid: ^pid]}]} = Test.Tracer.get(:create_span)
      end)
    end

    test "adds an error to the created span", %{pid: pid} do
      until(fn ->
        assert {:ok,
                [{%Span{pid: ^pid}, :error, %ArgumentError{message: "argument error"}, stack} | _]} =
                 Test.Span.get(:add_error)

        assert is_list(stack)
      end)
    end

    test "closes the created span" do
      until(fn ->
        assert {:ok, [{%Span{}}]} = Test.Tracer.get(:close_span)
      end)
    end
  end

  describe "handle_event/3, with a Task" do
    setup do
      parent = self()

      spawn(fn ->
        %Task{pid: pid} =
          Task.async(fn ->
            raise "Exception"
          end)

        send(parent, pid)
      end)

      pid =
        receive do
          pid -> pid
        end

      [pid: pid]
    end

    test "creates a span", %{pid: pid} do
      until(fn ->
        assert {:ok, [{"background_job", nil, [pid: ^pid]}]} = Test.Tracer.get(:create_span)
      end)
    end

    test "adds an error to the created span", %{pid: pid} do
      until(fn ->
        assert {:ok, [{%Span{pid: ^pid}, :error, %RuntimeError{message: "Exception"}, stack} | _]} =
                 Test.Span.get(:add_error)

        assert is_list(stack)
      end)
    end

    test "closes the created span", %{pid: pid} do
      until(fn ->
        assert {:ok, [{%Span{pid: ^pid}} | _]} = Test.Tracer.get(:close_span)
      end)
    end
  end

  describe "handle_event/3, with a crashing GenServer" do
    setup do
      {:ok, pid} = start_supervised(CrashingGenServer)

      GenServer.cast(pid, :raise_error)

      [pid: pid]
    end

    test "creates a span", %{pid: pid} do
      until(fn ->
        assert {:ok, [{"background_job", nil, [pid: ^pid]}]} = Test.Tracer.get(:create_span)
      end)
    end

    test "adds an error to the created span", %{pid: pid} do
      until(fn ->
        assert {:ok, [{%Span{pid: ^pid}, :error, %KeyError{}, stack} | _]} =
                 Test.Span.get(:add_error)

        assert is_list(stack)
      end)
    end

    test "closes the created span", %{pid: pid} do
      until(fn ->
        assert {:ok, [{%Span{pid: ^pid}} | _]} = Test.Tracer.get(:close_span)
      end)
    end
  end

  describe "handle_call/2" do
    test "replies with :ok" do
      assert Backend.handle_call(:call, %{}) == {:ok, :ok, %{}}
    end
  end
end
