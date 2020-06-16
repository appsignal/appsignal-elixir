defmodule Appsignal.Error.BackendTest do
  use ExUnit.Case
  import AppsignalTest.Utils
  alias Appsignal.{Error.Backend, Span, Test, Tracer, WrappedNif}

  setup do
    WrappedNif.start_link()
    Test.Tracer.start_link()
    Test.Span.start_link()

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
        assert {:ok, [{"", nil, ^pid}]} = Test.Tracer.get(:create_span)
      end)
    end

    test "adds an error to the created span" do
      until(fn ->
        assert {:ok, [{%Span{}, :error, %RuntimeError{message: "Exception"}, stack}]} =
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
          span = Tracer.create_span("")
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
        assert {:ok, [{^span, :error, %RuntimeError{message: "Exception"}, _stack}]} =
                 Test.Span.get(:add_error)
      end)
    end

    test "closes the existing span", %{span: span} do
      until(fn ->
        assert {:ok, [{^span}]} = Test.Tracer.get(:close_span)
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
        assert {:ok, [{"", nil, ^pid}]} = Test.Tracer.get(:create_span)
      end)
    end

    test "adds an error to the created span" do
      until(fn ->
        assert {:ok, [{%Span{}, :error, %ArgumentError{message: "argument error"}, stack}]} =
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
        assert {:ok, [{"", nil, ^pid}]} = Test.Tracer.get(:create_span)
      end)
    end

    test "adds an error to the created span" do
      until(fn ->
        assert {:ok, [{%Span{}, :error, %RuntimeError{message: "Exception"}, stack}]} =
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

  describe "handle_event/3, with a crashing GenServer" do
    setup do
      defmodule CrashingGenServer do
        use GenServer

        def start_link(_opts) do
          GenServer.start(__MODULE__, [meta: :data], name: Elixir.MyGenServer)
        end

        def init(opts), do: {:ok, opts}

        def handle_cast(:raise_error, state) do
          Map.fetch!(%{}, :bad_key)

          {:noreply, state}
        end
      end

      {:ok, pid} = start_supervised(CrashingGenServer)

      GenServer.cast(pid, :raise_error)

      [pid: pid]
    end

    test "creates a span", %{pid: pid} do
      until(fn ->
        assert {:ok, [{"", nil, ^pid}]} = Test.Tracer.get(:create_span)
      end)
    end

    test "adds an error to the created span" do
      until(fn ->
        assert {:ok, [{%Span{}, :error, %KeyError{}, stack}]} = Test.Span.get(:add_error)

        assert is_list(stack)
      end)
    end

    test "closes the created span" do
      until(fn ->
        assert {:ok, [{%Span{}}]} = Test.Tracer.get(:close_span)
      end)
    end
  end
end
