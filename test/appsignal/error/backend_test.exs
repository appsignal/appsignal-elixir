defmodule Murphy do
  import ExUnit.Assertions
  use GenServer

  def start_link(_opts) do
    GenServer.start(__MODULE__, [])
  end

  def init(opts), do: {:ok, opts}

  def handle_call(fun, _from, _state) do
    fun.()
  end

  def call(pid, fun) do
    ExUnit.CaptureLog.capture_log(fn ->
      catch_exit do
        GenServer.call(pid, fun)
      end
    end)
  end

  def with_conn(min_level, level, kind, data) do
    {:ok, chardata, metadata} = Logger.Translator.translate(min_level, level, kind, data)
    {:ok, chardata, metadata ++ [pid: "", conn: %{owner: self()}]}
  end

  def from_cowboy(min_level, level, kind, data) do
    {:ok, chardata, metadata} = Logger.Translator.translate(min_level, level, kind, data)
    {:ok, chardata, metadata ++ [domain: [:cowboy]]}
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
    {:ok, pid} = start_supervised(Murphy)

    %{pid: pid}
  end

  test "is added as a Logger backend" do
    assert {:error, :already_present} = Logger.add_backend(Backend)
  end

  describe "handle_event/3, when no span exists" do
    setup %{pid: pid} do
      Murphy.call(pid, fn -> raise "Exception" end)

      :ok
    end

    test "creates a span", %{pid: pid} do
      assert {:ok, [{"background_job", nil, [pid: ^pid]}]} = Test.Tracer.get(:create_span)
    end

    test "adds an error to the created span", %{pid: pid} do
      assert {:ok, [{%Span{pid: ^pid}, :error, %RuntimeError{message: "Exception"}, stack} | _]} =
               Test.Span.get(:add_error)

      assert is_list(stack)
    end

    test "closes the created span" do
      assert {:ok, [{%Span{}}]} = Test.Tracer.get(:close_span)
    end
  end

  describe "handle_event/3, with an open span" do
    setup %{pid: pid} do
      parent = self()

      Murphy.call(pid, fn ->
        span = Tracer.create_span("background_job")
        send(parent, span)
        raise "Exception"
      end)

      span =
        receive do
          span -> span
        end

      [span: span]
    end

    test "adds an error to the existing span", %{span: span} do
      assert {:ok, [{^span, :error, %RuntimeError{message: "Exception"}, _stack} | _]} =
               Test.Span.get(:add_error)
    end

    test "closes the existing span", %{span: span} do
      assert {:ok, [{^span}]} = Test.Tracer.get(:close_span)
    end
  end

  describe "handle_event/3, with an ignored process" do
    setup %{pid: pid} do
      Murphy.call(pid, fn ->
        Tracer.ignore()
        raise "Exception"
      end)

      :ok
    end

    test "does not create a span" do
      assert Test.Tracer.get(:create_span) == :error
    end
  end

  describe "handle_event/3 with a conn, with an ignored process" do
    setup %{pid: pid} do
      Logger.add_translator({Murphy, :with_conn})

      Murphy.call(pid, fn ->
        Tracer.ignore()
        raise "Exception"
      end)

      Logger.remove_translator({Murphy, :with_conn})
    end

    test "does not create a span" do
      assert Test.Tracer.get(:create_span) == :error
    end
  end

  describe "handle_event/3 from the cowboy domain, without a conn" do
    setup %{pid: pid} do
      Logger.add_translator({Murphy, :from_cowboy})

      Murphy.call(pid, fn ->
        raise "Exception"
      end)

      Logger.remove_translator({Murphy, :from_cowboy})
    end

    test "does not create a span" do
      assert Test.Tracer.get(:create_span) == :error
    end
  end

  describe "handle_event/3, with a :badarg" do
    setup %{pid: pid} do
      Murphy.call(pid, fn ->
        :erlang.error(:badarg)
      end)

      :ok
    end

    test "creates a span", %{pid: pid} do
      assert {:ok, [{"background_job", nil, [pid: ^pid]}]} = Test.Tracer.get(:create_span)
    end

    test "adds an error to the created span", %{pid: pid} do
      assert {:ok,
              [{%Span{pid: ^pid}, :error, %ArgumentError{message: "argument error"}, stack} | _]} =
               Test.Span.get(:add_error)

      assert is_list(stack)
    end

    test "closes the created span" do
      assert {:ok, [{%Span{}}]} = Test.Tracer.get(:close_span)
    end
  end

  describe "handle_event/3, with a KeyError" do
    setup %{pid: pid} do
      Murphy.call(pid, fn ->
        _ = Map.fetch!(%{}, :bad_key)
      end)

      :ok
    end

    test "creates a span", %{pid: pid} do
      assert {:ok, [{"background_job", nil, [pid: ^pid]}]} = Test.Tracer.get(:create_span)
    end

    test "adds an error to the created span", %{pid: pid} do
      assert {:ok, [{%Span{pid: ^pid}, :error, %KeyError{}, stack} | _]} =
               Test.Span.get(:add_error)

      assert is_list(stack)
    end

    test "closes the created span", %{pid: pid} do
      assert {:ok, [{%Span{pid: ^pid}} | _]} = Test.Tracer.get(:close_span)
    end
  end

  describe "handle_call/2" do
    test "replies with :ok" do
      assert Backend.handle_call(:call, %{}) == {:ok, :ok, %{}}
    end
  end

  describe "handle_info/2" do
    test "returns {:ok, state}" do
      assert Backend.handle_info({:io_reply, make_ref(), :ok}, %{}) == {:ok, %{}}
    end
  end

  describe "code_change/3" do
    test "returns {:ok, state}" do
      assert Backend.code_change(123, %{}, :extra) == {:ok, %{}}
    end
  end

  describe "terminate/2" do
    test "returns :ok" do
      assert Backend.terminate(:shutdown, %{}) == :ok
    end
  end
end
