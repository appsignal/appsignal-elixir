defmodule InstrumentedModule do
  use Appsignal.Instrumentation.Decorators

  @decorate instrument()
  def instrument do
    :ok
  end

  @decorate instrument("instrument")
  def background_instrument do
    :ok
  end

  @decorate instrument(:instrument)
  def background_instrument_atom do
    :ok
  end

  @decorate transaction()
  def transaction do
    :ok
  end

  @decorate transaction("transaction")
  def background_transaction do
    :ok
  end

  @decorate transaction(:transaction)
  def background_transaction_with_atom_namespace do
    :ok
  end

  @decorate transaction_event()
  def transaction_event do
    :ok
  end

  @decorate transaction_event("call.event")
  def transaction_event_category do
    :ok
  end

  @decorate transaction_event(:"call.event")
  def transaction_event_with_atom_category do
    :ok
  end

  @decorate channel_action()
  def channel_action(action, _payload, _socket) do
    action && :ok
  end
end

defmodule Appsignal.InstrumentationTest do
  use ExUnit.Case
  alias Appsignal.{Span, Test, Tracer}

  setup do
    start_supervised(Test.Nif)
    start_supervised(Test.Tracer)
    start_supervised(Test.Span)
    start_supervised(Test.Monitor)

    :ok
  end

  describe "instrument/2, with a decorator" do
    setup do
      %{return: InstrumentedModule.instrument()}
    end

    test "calls the passed function, and returns its return", %{return: return} do
      assert return == :ok
    end

    test "creates a root span" do
      assert Test.Tracer.get(:create_span) == {:ok, [{"background_job", nil}]}
    end

    test "sets the span's name" do
      assert {:ok, [{%Span{}, "InstrumentedModule.instrument_0"}]} = Test.Span.get(:set_name)
    end

    test "closes the span" do
      assert {:ok, [{%Span{}}]} = Test.Tracer.get(:close_span)
    end
  end

  describe "instrument/3, with a decorator with a custom namespace" do
    setup do
      %{return: InstrumentedModule.background_instrument()}
    end

    test "calls the passed function, and returns its return", %{return: return} do
      assert return == :ok
    end

    test "creates a root span" do
      assert Test.Tracer.get(:create_span) == {:ok, [{"background_job", nil}]}
    end

    test "sets the span's name" do
      assert {:ok, [{%Span{}, "InstrumentedModule.background_instrument_0"}]} =
               Test.Span.get(:set_name)
    end

    test "sets the span's namespace" do
      assert {:ok, [{%Span{}, "instrument"}]} = Test.Span.get(:set_namespace)
    end

    test "closes the span" do
      assert {:ok, [{%Span{}}]} = Test.Tracer.get(:close_span)
    end
  end

  describe "instrument/3, with a decorator with an atom as its custom namespace" do
    setup do
      %{return: InstrumentedModule.background_instrument_atom()}
    end

    test "sets the span's namespace" do
      assert {:ok, [{%Span{}, "instrument"}]} = Test.Span.get(:set_namespace)
    end
  end

  describe "transaction/2" do
    setup do
      %{return: InstrumentedModule.transaction()}
    end

    test "calls the passed function, and returns its return", %{return: return} do
      assert return == :ok
    end

    test "creates a root span" do
      assert Test.Tracer.get(:create_span) == {:ok, [{"background_job", nil}]}
    end

    test "sets the span's name" do
      assert {:ok, [{%Span{}, "InstrumentedModule.transaction_0"}]} = Test.Span.get(:set_name)
    end

    test "closes the span" do
      assert {:ok, [{%Span{}}]} = Test.Tracer.get(:close_span)
    end
  end

  describe "transaction/2, with a root span" do
    setup do
      Tracer.create_span("http_request")

      %{return: InstrumentedModule.transaction()}
    end

    test "calls the passed function, and returns its return", %{return: return} do
      assert return == :ok
    end

    test "creates a root span" do
      assert Test.Tracer.get(:create_span) == {:ok, [{"background_job", nil}]}
    end

    test "sets the span's name" do
      assert {:ok, [{%Span{}, "InstrumentedModule.transaction_0"}]} = Test.Span.get(:set_name)
    end

    test "closes the span" do
      assert {:ok, [{%Span{}}]} = Test.Tracer.get(:close_span)
    end
  end

  describe "transaction/3" do
    setup do
      %{return: InstrumentedModule.background_transaction()}
    end

    test "calls the passed function, and returns its return", %{return: return} do
      assert return == :ok
    end

    test "creates a root span" do
      assert Test.Tracer.get(:create_span) == {:ok, [{"transaction", nil}]}
    end

    test "sets the span's name" do
      assert {:ok, [{%Span{}, "InstrumentedModule.background_transaction_0"}]} =
               Test.Span.get(:set_name)
    end

    test "closes the span" do
      assert {:ok, [{%Span{}}]} = Test.Tracer.get(:close_span)
    end
  end

  describe "transaction/3, when passing the namespace as an atom" do
    setup do
      %{return: InstrumentedModule.background_transaction_with_atom_namespace()}
    end

    test "calls the passed function, and returns its return", %{return: return} do
      assert return == :ok
    end

    test "creates a root span" do
      assert Test.Tracer.get(:create_span) == {:ok, [{"transaction", nil}]}
    end

    test "sets the span's name" do
      assert {:ok, [{%Span{}, "InstrumentedModule.background_transaction_with_atom_namespace_0"}]} =
               Test.Span.get(:set_name)
    end

    test "closes the span" do
      assert {:ok, [{%Span{}}]} = Test.Tracer.get(:close_span)
    end
  end

  describe "transaction_event/2" do
    setup do
      %{return: InstrumentedModule.transaction_event()}
    end

    test "calls the passed function, and returns its return", %{return: return} do
      assert return == :ok
    end

    test "creates a root span" do
      assert Test.Tracer.get(:create_span) == {:ok, [{"background_job", nil}]}
    end

    test "sets the span's name" do
      assert {:ok, [{%Span{}, "InstrumentedModule.transaction_event_0"}]} =
               Test.Span.get(:set_name)
    end

    test "closes the span" do
      assert {:ok, [{%Span{}}]} = Test.Tracer.get(:close_span)
    end
  end

  describe "transaction_event/3, when passing a category" do
    setup do
      %{return: InstrumentedModule.transaction_event_category()}
    end

    test "calls the passed function, and returns its return", %{return: return} do
      assert return == :ok
    end

    test "creates a root span" do
      assert Test.Tracer.get(:create_span) == {:ok, [{"background_job", nil}]}
    end

    test "sets the span's name" do
      assert {:ok, [{%Span{}, "InstrumentedModule.transaction_event_category_0"}]} =
               Test.Span.get(:set_name)
    end

    test "sets the span's category attribute" do
      assert {:ok, [{%Span{}, "appsignal:category", "call.event"}]} =
               Test.Span.get(:set_attribute)
    end

    test "closes the span" do
      assert {:ok, [{%Span{}}]} = Test.Tracer.get(:close_span)
    end
  end

  describe "transaction_event/3, when passing a category as an atom" do
    setup do
      %{return: InstrumentedModule.transaction_event_with_atom_category()}
    end

    test "calls the passed function, and returns its return", %{return: return} do
      assert return == :ok
    end

    test "creates a root span" do
      assert Test.Tracer.get(:create_span) == {:ok, [{"background_job", nil}]}
    end

    test "sets the span's name" do
      assert {:ok, [{%Span{}, "InstrumentedModule.transaction_event_with_atom_category_0"}]} =
               Test.Span.get(:set_name)
    end

    test "sets the span's category attribute" do
      assert {:ok, [{%Span{}, "appsignal:category", "call.event"}]} =
               Test.Span.get(:set_attribute)
    end

    test "closes the span" do
      assert {:ok, [{%Span{}}]} = Test.Tracer.get(:close_span)
    end
  end

  describe "channel_action/2" do
    setup do
      %{return: InstrumentedModule.channel_action(:action, [], %{})}
    end

    test "calls the passed function, and returns its return", %{return: return} do
      assert return == :ok
    end

    test "creates a root span" do
      assert Test.Tracer.get(:create_span) == {:ok, [{"channel", nil}]}
    end

    test "sets the span's name" do
      assert {:ok, [{%Span{}, "InstrumentedModule.action"}]} = Test.Span.get(:set_name)
    end

    test "closes the span" do
      assert {:ok, [{%Span{}}]} = Test.Tracer.get(:close_span)
    end
  end

  describe "channel_action/2, with a root span" do
    setup do
      Tracer.create_span("http_request")

      %{return: InstrumentedModule.channel_action(:action, [], %{})}
    end

    test "calls the passed function, and returns its return", %{return: return} do
      assert return == :ok
    end

    test "creates a root span" do
      assert Test.Tracer.get(:create_span) == {:ok, [{"channel", nil}]}
    end

    test "sets the span's name" do
      assert {:ok, [{%Span{}, "InstrumentedModule.action"}]} = Test.Span.get(:set_name)
    end

    test "closes the span" do
      assert {:ok, [{%Span{}}]} = Test.Tracer.get(:close_span)
    end
  end

  describe "instrument/1" do
    setup do
      %{return: Appsignal.Instrumentation.instrument(fn -> :ok end)}
    end

    test "creates a root span" do
      assert Test.Tracer.get(:create_span) == {:ok, [{"background_job", nil}]}
    end

    test "calls the passed function, and returns its return", %{return: return} do
      assert return == :ok
    end

    test "closes the span" do
      assert {:ok, [{%Span{}}]} = Test.Tracer.get(:close_span)
    end
  end

  describe "instrument/1, through the Helpers module" do
    setup do
      %{return: Appsignal.Instrumentation.Helpers.instrument(fn -> :ok end)}
    end

    test "creates a root span" do
      assert Test.Tracer.get(:create_span) == {:ok, [{"background_job", nil}]}
    end

    test "calls the passed function, and returns its return", %{return: return} do
      assert return == :ok
    end

    test "closes the span" do
      assert {:ok, [{%Span{}}]} = Test.Tracer.get(:close_span)
    end
  end

  describe "instrument/1, when a root span exists" do
    setup do
      %{
        parent: Appsignal.Tracer.create_span("http_request"),
        return: Appsignal.Instrumentation.instrument(fn -> :ok end)
      }
    end

    test "creates a child span", %{parent: parent} do
      assert {:ok, [{"background_job", ^parent}]} = Test.Tracer.get(:create_span)
    end

    test "calls the passed function, and returns its return", %{return: return} do
      assert return == :ok
    end

    test "closes the span" do
      assert {:ok, [{%Span{}}]} = Test.Tracer.get(:close_span)
    end
  end

  describe "instrument/1, when passing a function that takes an argument" do
    setup do
      %{return: Appsignal.Instrumentation.instrument(fn span -> span end)}
    end

    test "calls the passed function with the created span, and returns its return", %{
      return: return
    } do
      assert %Span{} = return
    end
  end

  describe "instrument/2" do
    setup do
      %{return: Appsignal.Instrumentation.instrument("test", fn -> :ok end)}
    end

    test "creates a root span" do
      assert Test.Tracer.get(:create_span) == {:ok, [{"background_job", nil}]}
    end

    test "sets the span's name" do
      assert {:ok, [{%Span{}, "test"}]} = Test.Span.get(:set_name)
    end

    test "sets the span's category attribute" do
      assert {:ok, [{%Span{}, "appsignal:category", "test"}]} = Test.Span.get(:set_attribute)
    end

    test "calls the passed function, and returns its return", %{return: return} do
      assert return == :ok
    end

    test "closes the span" do
      assert {:ok, [{%Span{}}]} = Test.Tracer.get(:close_span)
    end
  end

  describe "instrument/2, when an error is raised from the function" do
    setup do
      try do
        Appsignal.Instrumentation.instrument("test", fn ->
          raise "Exception!"
        end)
      rescue
        e in RuntimeError ->
          e

          %{
            error: e
          }
      end
    end

    test "creates a root span" do
      assert Test.Tracer.get(:create_span) == {:ok, [{"background_job", nil}]}
    end

    test "sets the span's name" do
      assert {:ok, [{%Span{}, "test"}]} = Test.Span.get(:set_name)
    end

    test "sets the span's category attribute" do
      assert {:ok, [{%Span{}, "appsignal:category", "test"}]} = Test.Span.get(:set_attribute)
    end

    test "raises the error", %{error: error} do
      assert %RuntimeError{message: "Exception!"} = error
    end

    test "closes the span" do
      assert {:ok, [{%Span{}}]} = Test.Tracer.get(:close_span)
    end
  end

  describe "instrument/2, when passing a function that takes an argument" do
    setup do
      %{return: Appsignal.Instrumentation.instrument("test", fn span -> span end)}
    end

    test "calls the passed function with the created span, and returns its return", %{
      return: return
    } do
      assert %Span{} = return
    end
  end

  describe "instrument/3, when passing a name and a category" do
    setup do
      %{return: Appsignal.Instrumentation.instrument("test", "category", fn -> :ok end)}
    end

    test "creates a root span" do
      assert Test.Tracer.get(:create_span) == {:ok, [{"background_job", nil}]}
    end

    test "sets the span's name" do
      assert {:ok, [{%Span{}, "test"}]} = Test.Span.get(:set_name)
    end

    test "sets the span's category attribute" do
      assert {:ok, [{%Span{}, "appsignal:category", "category"}]} = Test.Span.get(:set_attribute)
    end

    test "calls the passed function, and returns its return", %{return: return} do
      assert return == :ok
    end

    test "closes the span" do
      assert {:ok, [{%Span{}}]} = Test.Tracer.get(:close_span)
    end
  end

  describe "instrument_root/3" do
    setup do
      %{
        return: Appsignal.Instrumentation.instrument_root("background_job", "name", fn -> :ok end)
      }
    end

    test "creates a root span" do
      assert Test.Tracer.get(:create_span) == {:ok, [{"background_job", nil}]}
    end

    test "calls the passed function, and returns its return", %{return: return} do
      assert return == :ok
    end

    test "closes the span" do
      assert {:ok, [{%Span{}}]} = Test.Tracer.get(:close_span)
    end
  end

  describe "instrument_root/3, a root span" do
    setup do
      Tracer.create_span("root_span")

      %{
        return: Appsignal.Instrumentation.instrument_root("background_job", "name", fn -> :ok end)
      }
    end

    test "creates a root span" do
      assert Test.Tracer.get(:create_span) == {:ok, [{"background_job", nil}]}
    end

    test "calls the passed function, and returns its return", %{return: return} do
      assert return == :ok
    end

    test "closes the span" do
      assert {:ok, [{%Span{}}]} = Test.Tracer.get(:close_span)
    end
  end

  describe "instrument_root/3, when an error is raised from the function" do
    setup do
      try do
        Appsignal.Instrumentation.instrument_root("background_job", "name", fn ->
          raise "Exception!"
        end)
      rescue
        e in RuntimeError ->
          e

          %{
            error: e
          }
      end
    end

    test "creates a root span" do
      assert Test.Tracer.get(:create_span) == {:ok, [{"background_job", nil}]}
    end

    test "raises the error", %{error: error} do
      assert %RuntimeError{message: "Exception!"} = error
    end

    test "closes the span" do
      assert {:ok, [{%Span{}}]} = Test.Tracer.get(:close_span)
    end
  end

  describe ".set_error/2, with a root span" do
    setup do
      span = Tracer.create_span("http_request")

      {exception, stack} =
        try do
          raise "Exception!"
        rescue
          exception -> {exception, __STACKTRACE__}
        end

      [
        span: span,
        exception: exception,
        stack: stack,
        return: Appsignal.Instrumentation.set_error(exception, stack)
      ]
    end

    test "returns the span", %{span: span, return: return} do
      assert return == span
    end

    test "adds the error to the span", %{exception: exception, stack: stack} do
      assert {:ok, [{%Span{}, ^exception, ^stack}]} = Test.Span.get(:add_error)
    end
  end

  describe ".set_error/2, with a child span" do
    setup do
      root = Tracer.create_span("http_request")
      Tracer.create_span("http_request")

      {exception, stack} =
        try do
          raise "Exception!"
        rescue
          exception -> {exception, __STACKTRACE__}
        end

      [
        span: root,
        exception: exception,
        stack: stack,
        return: Appsignal.Instrumentation.set_error(exception, stack)
      ]
    end

    test "returns the root span", %{span: span, return: return} do
      assert return == span
    end

    test "adds the error to the root span", %{exception: exception, stack: stack} do
      assert {:ok, [{%Span{}, ^exception, ^stack}]} = Test.Span.get(:add_error)
    end
  end

  describe ".set_error/3, with a root span" do
    setup do
      span = Tracer.create_span("http_request")

      {kind, reason, stack} =
        try do
          raise "Exception!"
        catch
          kind, reason -> {kind, reason, __STACKTRACE__}
        end

      [
        span: span,
        kind: kind,
        reason: reason,
        stack: stack,
        return: Appsignal.Instrumentation.set_error(kind, reason, stack)
      ]
    end

    test "returns the span", %{span: span, return: return} do
      assert return == span
    end

    test "adds the error to the span", %{reason: reason, stack: stack} do
      assert {:ok, [{%Span{}, :error, ^reason, ^stack}]} = Test.Span.get(:add_error)
    end
  end

  describe ".set_error/3, with a child span" do
    setup do
      root = Tracer.create_span("http_request")
      Tracer.create_span("http_request")

      {kind, reason, stack} =
        try do
          raise "Exception!"
        catch
          kind, reason -> {kind, reason, __STACKTRACE__}
        end

      [
        span: root,
        kind: kind,
        reason: reason,
        stack: stack,
        return: Appsignal.Instrumentation.set_error(kind, reason, stack)
      ]
    end

    test "returns the root span", %{span: span, return: return} do
      assert return == span
    end

    test "adds the error to the root span", %{reason: reason, stack: stack} do
      assert {:ok, [{%Span{}, :error, ^reason, ^stack}]} = Test.Span.get(:add_error)
    end
  end

  describe ".set_error/3, when no span exists" do
    setup do
      {kind, reason, stack} =
        try do
          raise "Exception!"
        catch
          kind, reason -> {kind, reason, __STACKTRACE__}
        end

      [return: Appsignal.Instrumentation.set_error(kind, reason, stack)]
    end

    test "returns nil", %{return: return} do
      assert return == nil
    end
  end

  describe ".send_error/2" do
    setup do
      {exception, stack} =
        try do
          raise "Exception!"
        rescue
          exception -> {exception, __STACKTRACE__}
        end

      [
        exception: exception,
        stack: stack,
        return: Appsignal.Instrumentation.send_error(exception, stack)
      ]
    end

    test "creates a root span" do
      assert Test.Span.get(:create_root) == {:ok, [{"http_request", self()}]}
    end

    test "adds the error to the span", %{exception: exception, stack: stack} do
      assert {:ok, [{%Span{}, ^exception, ^stack}]} = Test.Span.get(:add_error)
    end

    test "closes the span" do
      assert {:ok, [{%Span{}}]} = Test.Span.get(:close)
    end
  end

  describe ".send_error/3" do
    setup do
      {kind, reason, stack} =
        try do
          raise "Exception!"
        catch
          kind, reason -> {kind, reason, __STACKTRACE__}
        end

      [
        kind: kind,
        reason: reason,
        stack: stack,
        return: Appsignal.Instrumentation.send_error(kind, reason, stack)
      ]
    end

    test "creates a root span" do
      assert Test.Span.get(:create_root) == {:ok, [{"http_request", self()}]}
    end

    test "adds the error to the span", %{reason: reason, stack: stack} do
      assert {:ok, [{%Span{}, :error, ^reason, ^stack}]} = Test.Span.get(:add_error)
    end

    test "closes the span" do
      assert {:ok, [{%Span{}}]} = Test.Span.get(:close)
    end
  end

  describe ".send_error/3, when passing a function" do
    setup do
      {exception, stack} =
        try do
          raise "Exception!"
        rescue
          exception -> {exception, __STACKTRACE__}
        end

      return =
        Appsignal.Instrumentation.send_error(exception, stack, fn span ->
          Appsignal.Test.Span.set_attribute(span, "key", "value")
        end)

      [
        exception: exception,
        stack: stack,
        return: return
      ]
    end

    test "creates a root span" do
      assert Test.Span.get(:create_root) == {:ok, [{"http_request", self()}]}
    end

    test "adds the error to the span", %{exception: exception, stack: stack} do
      assert {:ok, [{%Span{}, ^exception, ^stack}]} = Test.Span.get(:add_error)
    end

    test "closes the span" do
      assert {:ok, [{%Span{}}]} = Test.Span.get(:close)
    end

    test "runs the function" do
      assert {:ok, [{%Appsignal.Span{}, "key", "value"}]} = Test.Span.get(:set_attribute)
    end
  end

  describe ".send_error/4, when passing a function" do
    setup do
      {kind, reason, stack} =
        try do
          raise "Exception!"
        catch
          kind, reason -> {kind, reason, __STACKTRACE__}
        end

      return =
        Appsignal.Instrumentation.send_error(kind, reason, stack, fn span ->
          Appsignal.Test.Span.set_attribute(span, "key", "value")
        end)

      [
        kind: kind,
        reason: reason,
        stack: stack,
        return: return
      ]
    end

    test "creates a root span" do
      assert Test.Span.get(:create_root) == {:ok, [{"http_request", self()}]}
    end

    test "adds the error to the span", %{reason: reason, stack: stack} do
      assert {:ok, [{%Span{}, :error, ^reason, ^stack}]} = Test.Span.get(:add_error)
    end

    test "closes the span" do
      assert {:ok, [{%Span{}}]} = Test.Span.get(:close)
    end

    test "runs the function" do
      assert {:ok, [{%Appsignal.Span{}, "key", "value"}]} = Test.Span.get(:set_attribute)
    end
  end
end
