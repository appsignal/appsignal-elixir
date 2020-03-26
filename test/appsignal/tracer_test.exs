defmodule Appsignal.TracerTest do
  use ExUnit.Case
  alias Appsignal.{Span, Test, Tracer, WrappedNif}

  setup do
    WrappedNif.start_link()
    Test.Monitor.start_link()
    :ok
  end

  describe "create_span/1" do
    setup :create_root_span

    test "returns a span", %{span: span} do
      assert %Span{} = span
    end

    test "registers the span", %{span: span} do
      assert :ets.lookup(:"$appsignal_registry", self()) == [{self(), span}]
    end
  end

  describe "create_span/1, when disabled" do
    setup [:disable_appsignal, :create_root_span]

    test "returns nil", %{span: span} do
      assert span == nil
    end

    test "does not register a span" do
      assert :ets.lookup(:"$appsignal_registry", self()) == []
    end
  end

  describe "create_span/1, when ignored" do
    setup [:ignore_process, :create_root_span]

    test "returns nil", %{span: span} do
      assert span == nil
    end

    test "does not register a span" do
      assert :ets.lookup(:"$appsignal_registry", self()) == [{self(), :ignore}]
    end
  end

  describe "create_span/2" do
    setup [:create_root_span, :create_child_span]

    test "returns a span", %{span: span} do
      assert %Span{} = span
    end

    test "registers the span without overwriting its parent", %{span: span, parent: parent} do
      assert :ets.lookup(:"$appsignal_registry", self()) == [{self(), parent}, {self(), span}]
    end
  end

  describe "create_span/2, when ignored" do
    setup [:create_root_span, :ignore_process, :create_child_span]

    test "returns nil", %{span: span} do
      assert span == nil
    end

    test "does not register a span" do
      assert :ets.lookup(:"$appsignal_registry", self()) == [{self(), :ignore}]
    end
  end

  describe "create_span/3, when passing a pid" do
    setup :create_root_span_in_other_process

    test "returns a span", %{span: span} do
      assert %Span{} = span
    end

    test "sets the span's reference", %{span: span} do
      assert is_reference(span.reference)
    end

    test "registers the span", %{span: span, pid: pid} do
      assert :ets.lookup(:"$appsignal_registry", pid) == [{pid, span}]
    end
  end

  describe "current_span/0, when no span exists" do
    test "returns nil" do
      assert Tracer.current_span() == nil
    end
  end

  describe "current_span/0, when a root span exists" do
    test "returns the created span" do
      assert Tracer.create_span("current") == Tracer.current_span()
    end
  end

  describe "current_span/0, when a child span exists" do
    setup [:create_root_span, :create_child_span]

    test "returns the child span", %{span: span} do
      assert span == Tracer.current_span()
    end
  end

  describe "current_span/1, when a span exists in another process" do
    setup :create_root_span_in_other_process

    test "returns the created span", %{span: span, pid: pid} do
      assert span == Tracer.current_span(pid)
    end
  end

  describe "current_span/1, when the process is ignored" do
    setup :ignore_process

    test "returns nil" do
      assert Tracer.current_span() == nil
    end
  end

  describe "close_span/1, when passing a nil" do
    test "returns nil" do
      assert Tracer.close_span(nil) == nil
    end
  end

  describe "close_span/1, when passing a root span" do
    setup :create_root_span

    test "returns :ok", %{span: span} do
      assert Tracer.close_span(span) == :ok
    end

    test "deregisters the span", %{span: span} do
      Tracer.close_span(span)
      assert :ets.lookup(:"$appsignal_registry", self()) == []
    end

    test "closes the span through the Nif", %{span: %Span{reference: reference} = span} do
      Tracer.close_span(span)
      assert [{^reference}] = WrappedNif.get!(:close_span)
    end
  end

  describe "close_span/1, when passing a child span" do
    setup [:create_root_span, :create_child_span]

    test "deregisters the span, but leaves its parent span", %{span: span, parent: parent} do
      Tracer.close_span(span)
      assert :ets.lookup(:"$appsignal_registry", self()) == [{self(), parent}]
    end
  end

  describe "close_span/1, when passing a span in another process" do
    setup :create_root_span_in_other_process

    test "returns :ok", %{span: span} do
      assert Tracer.close_span(span) == :ok
    end

    test "deregisters the span", %{span: span, pid: pid} do
      Tracer.close_span(span)
      assert :ets.lookup(:"$appsignal_registry", pid) == []
    end
  end

  describe "delete/1, with no registed spans" do
    setup do
      [return: Tracer.delete(self())]
    end

    test "returns :ok", %{return: return} do
      assert return == :ok
    end
  end

  describe "delete/1" do
    setup :create_root_span

    setup do
      [return: Tracer.delete(self())]
    end

    test "returns :ok", %{return: return} do
      assert return == :ok
    end

    test "deletes the span" do
      assert :ets.lookup(:"$appsignal_registry", self()) == []
    end
  end

  describe "delete/1, with multiple spans" do
    setup [:create_root_span, :create_child_span]

    setup do
      [return: Tracer.delete(self())]
    end

    test "returns :ok", %{return: return} do
      assert return == :ok
    end

    test "deletes the span" do
      assert :ets.lookup(:"$appsignal_registry", self()) == []
    end
  end

  describe "ignore/1" do
    setup :ignore_process

    test "marks a pid as ignored" do
      assert :ets.lookup(:"$appsignal_registry", self()) == [{self(), :ignore}]
    end

    test "creates a process monitor" do
      assert Test.Monitor.get!(:add) == [{self()}]
    end
  end

  describe "ignore/1, with an open span" do
    setup [:create_root_span, :ignore_process]

    test "removes existing spans" do
      assert :ets.lookup(:"$appsignal_registry", self()) == [{self(), :ignore}]
    end
  end

  defp create_root_span(_context) do
    [span: Tracer.create_span("root")]
  end

  defp create_child_span(%{span: span}) do
    [span: Tracer.create_span("child", span), parent: span]
  end

  defp create_root_span_in_other_process(_context) do
    pid = Process.whereis(WrappedNif)
    [span: Tracer.create_span("root", nil, pid), pid: pid]
  end

  defp disable_appsignal(_context) do
    config = Application.get_env(:appsignal, :config)
    Application.put_env(:appsignal, :config, %{config | active: false})

    on_exit(fn ->
      Application.put_env(:appsignal, :config, config)
    end)
  end

  defp ignore_process(_context) do
    Tracer.ignore()
  end
end
