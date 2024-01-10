defmodule Appsignal.TracerTest do
  use ExUnit.Case
  alias Appsignal.{Span, Test, Tracer}

  setup do
    start_supervised(Test.Nif)
    start_supervised(Test.Monitor)
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

    test "creates a process monitor" do
      assert Test.Monitor.get!(:add) == [{self()}]
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

  describe "create_span/1 in other process when ignored" do
    setup [:set_pid, :ignore_process_with_pid, :create_root_span_in_other_process]

    test "returns nil", %{span: span} do
      assert span == nil
    end

    test "does not register a span", %{pid: pid} do
      assert :ets.lookup(:"$appsignal_registry", pid) == [{pid, :ignore}]
    end
  end

  describe "create_span/1, without the registry" do
    setup [:terminate_registry, :create_root_span]

    test "returns nil", %{span: span} do
      assert span == nil
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

  describe "create_span/2, with a namespace that doesn't match the current span" do
    setup [:create_root_span]

    setup %{span: span} do
      [span: Tracer.create_span("background_job", span), parent: span]
    end

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

  describe "create_span/2, without the registry" do
    setup [:create_root_span, :terminate_registry, :create_child_span]

    test "returns nil", %{span: span} do
      assert span == nil
    end
  end

  describe "create_span/3, when passing a pid" do
    setup [:set_pid, :create_root_span_in_other_process]

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

  describe "create_span/3, when passing a start time" do
    setup do
      [span: Tracer.create_span("http_request", nil, start_time: 1_588_936_027_128_939_000)]
    end

    test "returns a span", %{span: span} do
      assert %Span{} = span
    end

    test "sets the span's reference", %{span: span} do
      assert is_reference(span.reference)
    end

    test "creates a root span through the Nif" do
      assert [{"http_request", 1_588_936_027, 128_939_000}] =
               Test.Nif.get!(:create_root_span_with_timestamp)
    end
  end

  describe "create_span/3, when passing a start time and a parent" do
    setup :create_root_span

    setup %{span: span} do
      [
        parent: span,
        span: Tracer.create_span("child", span, start_time: 1_588_936_027_128_939_000)
      ]
    end

    test "returns a span", %{span: span} do
      assert %Span{} = span
    end

    test "sets the span's reference", %{span: span} do
      assert is_reference(span.reference)
    end

    test "creates a child span through the Nif" do
      assert [{_, 1_588_936_027, 128_939_000}] = Test.Nif.get!(:create_child_span_with_timestamp)
    end
  end

  describe "current_span/0, when no span exists" do
    test "returns nil" do
      assert Tracer.current_span() == nil
    end
  end

  describe "current_span/0, when a root span exists" do
    test "returns the created span" do
      assert Tracer.create_span("http_request") == Tracer.current_span()
    end
  end

  describe "current_span/0, when a child span exists" do
    setup [:create_root_span, :create_child_span]

    test "returns the child span", %{span: span} do
      assert span == Tracer.current_span()
    end
  end

  describe "current_span/0, without the registry" do
    setup :terminate_registry

    test "returns nil" do
      assert Tracer.current_span() == nil
    end
  end

  describe "current_span/1, when a span exists in another process" do
    setup [:set_pid, :create_root_span_in_other_process]

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

  describe "root_span/0, when no span exists" do
    test "returns nil" do
      assert Tracer.root_span() == nil
    end
  end

  describe "root_span/0, without the registry" do
    setup :terminate_registry

    test "returns nil" do
      assert Tracer.root_span() == nil
    end
  end

  describe "root_span/0, when a root span exists" do
    test "returns the created span" do
      assert Tracer.create_span("http_request") == Tracer.root_span()
    end
  end

  describe "root_span/0, when a child span exists" do
    setup [:create_root_span, :create_child_span]

    test "returns the root span", %{parent: span} do
      assert span == Tracer.root_span()
    end
  end

  describe "root_span/1, when a span exists in another process" do
    setup [:set_pid, :create_root_span_in_other_process]

    test "returns the created span", %{span: span, pid: pid} do
      assert span == Tracer.root_span(pid)
    end
  end

  describe "root_span/1, when the process is ignored" do
    setup :ignore_process

    test "returns nil" do
      assert Tracer.root_span() == nil
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
      assert [{^reference}] = Test.Nif.get!(:close_span)
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
    setup [:set_pid, :create_root_span_in_other_process]

    test "returns :ok", %{span: span} do
      assert Tracer.close_span(span) == :ok
    end

    test "deregisters the span", %{span: span, pid: pid} do
      Tracer.close_span(span)
      assert :ets.lookup(:"$appsignal_registry", pid) == []
    end
  end

  describe "close_span/1, without the registry" do
    setup [:create_root_span, :terminate_registry]

    test "returns :ok", %{span: span} do
      assert Tracer.close_span(span) == :ok
    end
  end

  describe "delete/1, with no registered spans" do
    setup do
      [return: Tracer.delete(self())]
    end

    test "returns :ok", %{return: return} do
      assert return == :ok
    end
  end

  describe "delete/1, without the registry" do
    setup :terminate_registry

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

  describe "ignore/0" do
    setup :ignore_process

    test "returns nil", %{return: return} do
      assert return == :ok
    end

    test "marks a pid as ignored" do
      assert :ets.lookup(:"$appsignal_registry", self()) == [{self(), :ignore}]
    end

    test "creates a process monitor" do
      assert Test.Monitor.get!(:add) == [{self()}]
    end
  end

  describe "ignore/0, with an open span" do
    setup [:create_root_span, :ignore_process]

    test "returns nil", %{return: return} do
      assert return == :ok
    end

    test "removes existing spans" do
      assert :ets.lookup(:"$appsignal_registry", self()) == [{self(), :ignore}]
    end
  end

  describe "ignore/0, without the registry" do
    setup [:create_root_span, :terminate_registry, :ignore_process]

    test "returns nil", %{return: return} do
      assert return == :ok
    end
  end

  describe "ignore/1" do
    setup [:set_pid, :ignore_process_with_pid]

    test "returns nil", %{return: return} do
      assert return == :ok
    end

    test "marks a pid as ignored", %{pid: pid} do
      assert :ets.lookup(:"$appsignal_registry", pid) == [{pid, :ignore}]
    end

    test "creates a process monitor" do
      assert Test.Monitor.get!(:add) == [{self()}]
    end
  end

  describe "ignore/1, with an open span" do
    setup [:set_pid, :create_root_span_in_other_process, :ignore_process_with_pid]

    test "returns nil", %{return: return} do
      assert return == :ok
    end

    test "removes existing spans", %{pid: pid} do
      assert :ets.lookup(:"$appsignal_registry", pid) == [{pid, :ignore}]
    end
  end

  describe "ignore/1, without the registry" do
    setup [
      :set_pid,
      :create_root_span_in_other_process,
      :terminate_registry,
      :ignore_process_with_pid
    ]

    test "returns nil", %{return: return} do
      assert return == :ok
    end
  end

  describe "multiple root spans" do
    test "are created and closed in order" do
      first = Tracer.create_span("http_request", nil)
      second = Tracer.create_span("http_request", nil)

      assert Test.Nif.get(:create_root_span) == {:ok, [{"http_request"}, {"http_request"}]}
      assert Tracer.current_span() == second

      Tracer.close_span(second)

      assert Tracer.current_span() == first

      Tracer.close_span(first)

      assert Tracer.current_span() == nil
    end
  end

  describe "register_current/1" do
    test "carries over the current span to a new PID" do
      span = Tracer.create_span("http_request")

      task =
        Task.async(fn ->
          Tracer.register_current(span)
          Tracer.current_span()
        end)

      task_current_span = Task.await(task)

      assert Map.fetch!(span, :pid) != Map.fetch!(task_current_span, :pid)
      assert Map.fetch!(span, :reference) == Map.fetch!(task_current_span, :reference)
    end
  end

  describe "on_create_span/2" do
    test "custom data is set with Appsignal.Support.Tracer defined in config" do
      assert %{"sample_data" => %{"custom_data" => "{\"foo\":\"bar\"}"}} =
               "http_request"
               |> Tracer.create_span()
               |> Span.to_map()
    end
  end

  defp create_root_span(_context) do
    [span: Tracer.create_span("http_request")]
  end

  defp create_child_span(%{span: span}) do
    [span: Tracer.create_span("http_request", span), parent: span]
  end

  defp set_pid(_context) do
    [pid: Process.whereis(Test.Nif)]
  end

  defp create_root_span_in_other_process(%{pid: pid}) do
    [span: Tracer.create_span("http_request", nil, pid: pid), pid: pid]
  end

  defp disable_appsignal(_context) do
    config = Application.get_env(:appsignal, :config)
    Application.put_env(:appsignal, :config, %{config | active: false})

    on_exit(fn ->
      Application.put_env(:appsignal, :config, config)
    end)
  end

  defp ignore_process(_context) do
    [return: Tracer.ignore()]
  end

  defp ignore_process_with_pid(%{pid: pid}) do
    [return: Tracer.ignore(pid)]
  end

  defp terminate_registry(_) do
    :ok = Supervisor.terminate_child(Appsignal.Supervisor, Tracer)

    on_exit(fn ->
      {:ok, _} = Supervisor.restart_child(Appsignal.Supervisor, Tracer)
    end)
  end
end
