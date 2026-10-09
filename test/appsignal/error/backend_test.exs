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
      catch_exit(GenServer.call(pid, fun))
    end)
  end

  def with_conn(min_level, level, kind, data) do
    {:ok, chardata, metadata} = Logger.Translator.translate(min_level, level, kind, data)
    {:ok, chardata, metadata ++ [pid: "", conn: %{owner: Appsignal.Error.BackendTest.pid()}]}
  end

  def from_cowboy(min_level, level, kind, data) do
    {:ok, chardata, metadata} = Logger.Translator.translate(min_level, level, kind, data)
    {:ok, chardata, metadata ++ [domain: [:cowboy]]}
  end

  def with_conn_from_cowboy(min_level, level, kind, data) do
    {:ok, chardata, metadata} = Logger.Translator.translate(min_level, level, kind, data)

    {:ok, chardata,
     metadata ++ [pid: "", conn: %{owner: Appsignal.Error.BackendTest.pid()}, domain: [:cowboy]]}
  end
end

defmodule Appsignal.Error.BackendTest do
  use ExUnit.Case
  alias Appsignal.{Error.Backend, Span, Test, Tracer}
  import AppsignalTest.Utils

  setup do
    Appsignal.Error.Backend.attach()
    on_exit(fn -> Appsignal.Utils.LoggerHandler.remove_backend(Backend) end)

    {:ok, _pid} = start_supervised(Test.Nif)
    {:ok, _pid} = start_supervised(Test.Tracer)
    {:ok, _pid} = start_supervised(Test.Span)
    {:ok, _pid} = start_supervised(Test.Monitor)
    {:ok, pid} = start_supervised(Murphy)

    %{pid: pid}
  end

  test "is added as a Logger backend" do
    assert {:error, :already_present} = Appsignal.Utils.LoggerHandler.add_backend(Backend)
  end

  test "is not added as a Logger backend when disabled" do
    Appsignal.Utils.LoggerHandler.remove_backend(Appsignal.Error.Backend)
    with_config(%{enable_error_backend: false}, fn -> Appsignal.start([], []) end)

    assert :ok = Appsignal.Error.Backend.attach()
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

  describe "handle_event/3, with a child span open" do
    setup %{pid: pid} do
      test_pid = self()

      Murphy.call(pid, fn ->
        root = Tracer.create_span("background_job")
        child = Tracer.create_span("background_job", root)
        send(test_pid, child)
        raise "Exception"
      end)

      child =
        receive do
          child -> child
        end

      [child: child]
    end

    test "adds the error to the child span", %{child: child} do
      assert {:ok, [{^child, :error, %RuntimeError{}, _stack}]} = Test.Span.get(:add_error)
    end
  end

  describe "handle_event/3, with only a span attached from another process" do
    setup %{pid: pid} do
      parent = Tracer.create_span("http_request")

      Murphy.call(pid, fn ->
        Tracer.register_current(parent)
        raise "Exception"
      end)

      [parent: parent]
    end

    test "creates a span", %{pid: pid} do
      assert {:ok, [{"background_job", nil, [pid: ^pid]} | _]} = Test.Tracer.get(:create_span)
    end

    test "adds the error to the created span", %{pid: pid} do
      assert {:ok, [{%Span{pid: ^pid} = span, :error, %RuntimeError{}, _stack}]} =
               Test.Span.get(:add_error)

      assert {:ok, [{^span}]} = Test.Tracer.get(:close_span)
    end

    test "leaves the attached span open", %{parent: parent} do
      {:ok, closed} = Test.Tracer.get(:close_span)

      refute Enum.any?(closed, fn {span} -> span.reference == parent.reference end)
    end
  end

  describe "handle_event/3, with a span of its own and a span attached from another process" do
    setup %{pid: pid} do
      parent = Tracer.create_span("http_request")
      test_pid = self()

      Murphy.call(pid, fn ->
        span = Tracer.create_span("background_job")
        Tracer.register_current(parent)
        send(test_pid, span)
        raise "Exception"
      end)

      span =
        receive do
          span -> span
        end

      [span: span]
    end

    test "adds the error to its own span", %{span: span} do
      assert {:ok, [{^span, :error, %RuntimeError{}, _stack}]} = Test.Span.get(:add_error)
    end

    test "closes its own span", %{span: span} do
      assert {:ok, [{^span}]} = Test.Tracer.get(:close_span)
    end
  end

  describe "handle_event/3, with an error the instrumentation already reported" do
    setup %{pid: pid} do
      setup_with_config(%{enable_error_backend: true})

      Murphy.call(pid, fn ->
        span = Tracer.create_span("background_job")

        try do
          raise "Exception"
        catch
          kind, reason ->
            Span.add_error(span, kind, reason, __STACKTRACE__)
            Tracer.close_span(span)
            :erlang.raise(kind, reason, __STACKTRACE__)
        end
      end)

      :ok
    end

    test "does not report it again" do
      assert Test.Tracer.get(:create_span) == :error
      assert Test.Span.get(:add_error) == :error
    end
  end

  describe "handle_event/3, with an error the instrumentation reported, re-raised wrapped" do
    # Plug and Phoenix re-raise the error wrapped in `Plug.Conn.WrapperError`,
    # with the original stack trace.
    setup %{pid: pid} do
      setup_with_config(%{enable_error_backend: true})

      Murphy.call(pid, fn ->
        span = Tracer.create_span("background_job")

        try do
          raise "Exception"
        catch
          kind, reason ->
            Span.add_error(span, kind, reason, __STACKTRACE__)
            Tracer.close_span(span)
            :erlang.raise(:error, %ArgumentError{message: "Wrapped"}, __STACKTRACE__)
        end
      end)

      :ok
    end

    test "does not report it again" do
      assert Test.Tracer.get(:create_span) == :error
    end
  end

  describe "handle_event/3, with an error the instrumentation reported a while ago" do
    setup %{pid: pid} do
      setup_with_config(%{enable_error_backend: true})
      delay = Application.fetch_env!(:appsignal, :deletion_delay)

      Murphy.call(pid, fn ->
        span = Tracer.create_span("background_job")

        try do
          raise "Exception"
        catch
          kind, reason ->
            Span.add_error(span, kind, reason, __STACKTRACE__)
            Tracer.close_span(span)
            Process.sleep(delay + 50)
            :erlang.raise(kind, reason, __STACKTRACE__)
        end
      end)

      :ok
    end

    test "reports it", %{pid: pid} do
      assert {:ok, [{"background_job", nil, [pid: ^pid]}]} = Test.Tracer.get(:create_span)
    end
  end

  describe "handle_event/3, with another error the instrumentation reported" do
    setup %{pid: pid} do
      setup_with_config(%{enable_error_backend: true})

      Murphy.call(pid, fn ->
        span = Tracer.create_span("background_job")
        Span.add_error(span, :error, %RuntimeError{message: "Other"}, [{Murphy, :other, 0, []}])
        Tracer.close_span(span)
        raise "Exception"
      end)

      :ok
    end

    test "reports it", %{pid: pid} do
      assert {:ok, [{"background_job", nil, [pid: ^pid]}]} = Test.Tracer.get(:create_span)
    end
  end

  describe "handle_event/3, with a reported error logged with a conn that has no owner" do
    # Bandit logs a crashed request's conn with its `owner` unset.
    setup do
      setup_with_config(%{enable_error_backend: true})
      span = Tracer.create_span("background_job")

      {reason, stacktrace} =
        try do
          raise "Exception"
        rescue
          exception -> {exception, __STACKTRACE__}
        end

      Span.add_error(span, :error, reason, stacktrace)
      Tracer.close_span(span)
      metadata = [crash_reason: {reason, stacktrace}, conn: %{owner: nil}]

      ExUnit.CaptureLog.capture_log(fn ->
        require Logger
        Logger.error("Exception", metadata)
      end)

      :ok
    end

    test "does not report it again" do
      Process.sleep(100)
      assert Test.Tracer.get(:create_span) == :error
    end
  end

  describe "handle_event/3, with the same error logged twice by a live process" do
    setup do
      setup_with_config(%{enable_error_backend: true})
      stacktrace = [{__MODULE__, :report, 0, []}]
      metadata = [crash_reason: {%RuntimeError{message: "Exception"}, stacktrace}]

      ExUnit.CaptureLog.capture_log(fn ->
        require Logger
        Logger.error("Exception", metadata)
        Logger.error("Exception", metadata)
      end)

      :ok
    end

    test "reports it both times, without suppressing its own reports" do
      AppsignalTest.Utils.until(fn ->
        assert {:ok, [_, _]} = Test.Tracer.get(:close_span)
      end)

      assert {:ok, [_, _]} = Test.Span.get(:add_error)
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

  describe "handle_event/3 from the cowboy domain, with a conn" do
    setup %{pid: pid} do
      Logger.add_translator({Murphy, :with_conn_from_cowboy})

      Murphy.call(pid, fn ->
        raise "Exception"
      end)

      Logger.remove_translator({Murphy, :with_conn_from_cowboy})
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

    test "adds a `reported_by` tag to the created span", %{pid: pid} do
      assert {:ok, [{%Span{pid: ^pid}, "tags", %{"reported_by" => "error_backend"}} | _]} =
               Test.Span.get(:set_sample_data)
    end

    test "closes the created span", %{pid: pid} do
      assert {:ok, [{%Span{pid: ^pid}} | _]} = Test.Tracer.get(:close_span)
    end
  end

  describe "handle_event/2, with an unexpected event" do
    test "replies with :ok" do
      assert Backend.handle_event(:event, %{}) == {:ok, %{}}
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

  def pid do
    if System.otp_release() < "21" do
      :erlang.list_to_pid(~c"<0.123.0>")
    else
      self()
    end
  end
end
