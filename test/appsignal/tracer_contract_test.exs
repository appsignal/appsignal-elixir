defmodule Appsignal.TracerContractTest do
  use ExUnit.Case
  import AppsignalTest.Utils, only: [until: 1]
  alias Appsignal.{Span, Test, Tracer}

  setup do
    start_supervised!(Test.Nif)
    start_supervised!(Test.Monitor)
    start_supervised!(Test.Tracer)
    start_supervised!(Test.Span)
    :ok
  end

  describe "creating a root span" do
    test "returns a span owned by the calling process, which becomes current and root" do
      span = Tracer.create_span("http_request")

      assert %Span{pid: pid, reference: reference} = span
      assert pid == self()
      assert is_reference(reference)
      assert Tracer.current_span() == span
      assert Tracer.root_span() == span
      assert Tracer.lookup(self()) == [{self(), span}]
      assert Test.Nif.get!(:create_root_span) == [{"http_request"}]
    end

    test "passes the start time to the extension" do
      Tracer.create_span("http_request", nil, start_time: 1_588_936_027_128_939_000)

      assert [{"http_request", 1_588_936_027, 128_939_000}] =
               Test.Nif.get!(:create_root_span_with_timestamp)
    end

    test "returns nil and registers nothing when AppSignal is not active" do
      config = Application.get_env(:appsignal, :config)
      Application.put_env(:appsignal, :config, %{config | active: false})
      on_exit(fn -> Application.put_env(:appsignal, :config, config) end)

      assert Tracer.create_span("http_request") == nil
      assert Tracer.current_span() == nil
      assert Tracer.lookup(self()) == []
    end

    test "returns nil when the process is ignored" do
      Tracer.ignore()

      assert Tracer.create_span("http_request") == nil
      assert Tracer.create_span("http_request", nil, []) == nil
    end

    test "returns nil when the registry is not running" do
      stop_registry()

      assert Tracer.create_span("http_request") == nil
    end

    test "calls the custom on-create function with the new span" do
      test_pid = self()
      Application.put_env(:appsignal, :custom_on_create_fun, &send(test_pid, {:created, &1}))

      on_exit(fn ->
        Application.put_env(:appsignal, :custom_on_create_fun, &Tracer.custom_on_create_fun/1)
      end)

      span = Tracer.create_span("http_request")

      assert_received {:created, ^span}
    end
  end

  describe "creating a child span" do
    test "creates the child from the given parent, and the child becomes current" do
      parent = Tracer.create_span("http_request")
      child = Tracer.create_span("http_request", parent)

      assert %Span{pid: pid} = child
      assert pid == self()
      assert Test.Nif.get!(:create_child_span) == [{parent.reference}]
      assert Tracer.current_span() == child
      assert Tracer.root_span() == parent
      assert Tracer.lookup(self()) == [{self(), parent}, {self(), child}]
    end

    test "passes the start time to the extension" do
      parent = Tracer.create_span("http_request")
      Tracer.create_span("http_request", parent, start_time: 1_588_936_027_128_939_000)

      assert [{reference, 1_588_936_027, 128_939_000}] =
               Test.Nif.get!(:create_child_span_with_timestamp)

      assert reference == parent.reference
    end

    test "returns nil when the process is ignored" do
      parent = Tracer.create_span("http_request")
      Tracer.ignore()

      assert Tracer.create_span("http_request", parent) == nil
    end

    test "accepts a parent from another process, and registers the child in the calling process" do
      parent = Tracer.create_span("http_request")

      {child, task_current, task_root, task_lookup_after_close} =
        Task.async(fn ->
          child = Tracer.create_span("http_request", parent)
          task_current = Tracer.current_span()
          task_root = Tracer.root_span()
          Tracer.close_span(child)
          {child, task_current, task_root, Tracer.lookup(self())}
        end)
        |> Task.await()

      assert child.pid != self()
      assert Test.Nif.get!(:create_child_span) == [{parent.reference}]
      assert task_current == child
      assert task_root == child
      assert task_lookup_after_close == []
      assert Tracer.current_span() == parent
      assert Tracer.lookup(self()) == [{self(), parent}]
    end
  end

  describe "creating a span for another process" do
    test "registers the span under the given pid" do
      pid = spawn_idle()
      span = Tracer.create_span("http_request", nil, pid: pid)

      assert span.pid == pid
      assert Tracer.current_span(pid) == span
      assert Tracer.root_span(pid) == span
      assert Tracer.current_span() == nil
    end

    test "returns nil when the given pid is ignored" do
      pid = spawn_idle()
      Tracer.ignore(pid)

      assert Tracer.create_span("http_request", nil, pid: pid) == nil
    end
  end

  describe "the current span" do
    test "is nil when the process has no spans" do
      assert Tracer.current_span() == nil
    end

    test "is the most recently opened span, and goes back to the previous one when it closes" do
      first = Tracer.create_span("http_request")
      second = Tracer.create_span("http_request", first)
      third = Tracer.create_span("http_request", nil)

      assert Tracer.current_span() == third
      Tracer.close_span(third)
      assert Tracer.current_span() == second
      Tracer.close_span(second)
      assert Tracer.current_span() == first
      Tracer.close_span(first)
      assert Tracer.current_span() == nil
    end

    test "does not change when a span other than the current one closes" do
      root = Tracer.create_span("http_request")
      child = Tracer.create_span("http_request", root)

      Tracer.close_span(root)

      assert Tracer.current_span() == child
      assert Tracer.lookup(self()) == [{self(), child}]
    end

    test "is nil when the registry is not running" do
      Tracer.create_span("http_request")
      stop_registry()

      assert Tracer.current_span() == nil
    end
  end

  describe "the root span" do
    test "is nil when the process has no spans" do
      assert Tracer.root_span() == nil
    end

    test "is the first span opened in the process" do
      root = Tracer.create_span("http_request")
      child = Tracer.create_span("http_request", root)
      Tracer.create_span("http_request", child)

      assert Tracer.root_span() == root
    end

    test "is the oldest span still open once the root has closed" do
      root = Tracer.create_span("http_request")
      child = Tracer.create_span("http_request", root)

      Tracer.close_span(root)

      assert Tracer.root_span() == child
    end

    test "is the outer root while a second root is open in the same process" do
      outer = Tracer.create_span("http_request")
      Tracer.create_span("live_view", nil)

      assert Tracer.root_span() == outer
    end

    test "is the first span registered in a task" do
      parent = Tracer.create_span("http_request")

      {child, task_root} =
        Task.async(fn ->
          child = Tracer.create_span("http_request", parent)
          {child, Tracer.root_span()}
        end)
        |> Task.await()

      assert task_root == child
    end
  end

  describe "closing a span with Tracer.close_span" do
    test "returns nil for nil" do
      assert Tracer.close_span(nil) == nil
      assert Tracer.close_span(nil, end_time: 1) == nil
    end

    test "ends the span through the extension and deregisters it" do
      span = Tracer.create_span("http_request")

      assert Tracer.close_span(span) == :ok
      assert closed_references() == [span.reference]
      assert Tracer.current_span() == nil
      assert Tracer.lookup(self()) == []
    end

    test "passes the end time to the extension" do
      span = Tracer.create_span("http_request")

      assert Tracer.close_span(span, end_time: 1_588_936_027_128_939_000) == :ok

      assert [{reference, 1_588_936_027, 128_939_000}] =
               Test.Nif.get!(:close_span_with_timestamp)

      assert reference == span.reference
      assert Tracer.lookup(self()) == []
    end

    test "ends the span even when the process was ignored after it opened" do
      span = Tracer.create_span("http_request")
      Tracer.ignore()

      assert Tracer.close_span(span) == :ok
      assert closed_references() == [span.reference]
    end

    test "ends the span every time it is called" do
      span = Tracer.create_span("http_request")

      assert Tracer.close_span(span) == :ok
      assert Tracer.close_span(span) == :ok
      assert closed_references() == [span.reference, span.reference]
    end

    test "ends the span when the registry is not running" do
      span = Tracer.create_span("http_request")
      stop_registry()

      assert Tracer.close_span(span) == :ok
      assert closed_references() == [span.reference]
    end

    test "removes every registration of a span registered twice in one process" do
      span = Tracer.create_span("http_request")
      Tracer.register_current(span)

      assert Tracer.lookup(self()) == [{self(), span}, {self(), span}]

      Tracer.close_span(span)

      assert Tracer.lookup(self()) == []
    end

    test "deregisters a span that belongs to another process" do
      pid = spawn_idle()
      span = Tracer.create_span("http_request", nil, pid: pid)

      assert Tracer.close_span(span) == :ok
      assert Tracer.lookup(pid) == []
    end
  end

  describe "closing a span with Span.close" do
    test "ends the span through the extension" do
      span = Tracer.create_span("http_request")

      assert Span.close(span) == span
      assert closed_references() == [span.reference]
    end

    test "leaves the span registered, current and root" do
      span = Tracer.create_span("http_request")

      Span.close(span)

      assert Tracer.current_span() == span
      assert Tracer.root_span() == span
      assert Tracer.lookup(self()) == [{self(), span}]
    end
  end

  describe "spans created with Span.create_root and Span.create_child" do
    test "are not registered and do not become current" do
      root = Span.create_root("http_request", self())
      child = Span.create_child(root, self())

      assert %Span{} = root
      assert %Span{} = child
      assert Tracer.current_span() == nil
      assert Tracer.lookup(self()) == []
    end

    test "are created even when the process is ignored" do
      Tracer.ignore()

      assert %Span{} = Span.create_root("http_request", self())
    end

    test "do not change the current span of a process that has one" do
      span = Tracer.create_span("http_request")
      Span.create_root("http_request", self())

      assert Tracer.current_span() == span
      assert Tracer.root_span() == span
    end

    test "send_error ends its own root without touching the registry" do
      span = Tracer.create_span("http_request")

      error_span = Appsignal.send_error(%RuntimeError{message: "Exception!"}, [])

      assert closed_references() == [error_span.reference]
      assert Tracer.current_span() == span
      assert Tracer.lookup(self()) == [{self(), span}]
    end
  end

  describe "ignoring a process" do
    test "removes its spans without ending them" do
      span = Tracer.create_span("http_request")
      Tracer.create_span("http_request", span)

      assert Tracer.ignore() == :ok
      assert closed_references() == []
      assert Tracer.current_span() == nil
      assert Tracer.root_span() == nil
      assert Tracer.lookup(self()) == [{self(), :ignore}]
    end

    test "works for another process" do
      pid = spawn_idle()
      Tracer.create_span("http_request", nil, pid: pid)

      assert Tracer.ignore(pid) == :ok
      assert Tracer.current_span(pid) == nil
      assert Tracer.root_span(pid) == nil
      assert Tracer.lookup(pid) == [{pid, :ignore}]
    end

    test "returns :ok when the registry is not running" do
      stop_registry()

      assert Tracer.ignore() == :ok
    end

    test "is lifted by deleting the process' entries" do
      Tracer.ignore()

      assert Tracer.delete(self()) == :ok
      assert %Span{} = Tracer.create_span("http_request")
    end

    test "is lifted by registering a span from another process" do
      parent = Tracer.create_span("http_request")

      {registered, current, created} =
        Task.async(fn ->
          Tracer.ignore()
          registered = Tracer.register_current(parent)
          {registered, Tracer.current_span(), Tracer.create_span("http_request", nil)}
        end)
        |> Task.await()

      assert %Span{} = registered
      assert current == registered
      assert %Span{} = created
    end
  end

  describe "deleting a process' entries" do
    test "removes its spans without ending them" do
      Tracer.create_span("http_request")

      assert Tracer.delete(self()) == :ok
      assert closed_references() == []
      assert Tracer.lookup(self()) == []
    end

    test "returns :ok when the registry is not running" do
      stop_registry()

      assert Tracer.delete(self()) == :ok
    end
  end

  describe "registering a span from another process" do
    test "registers a copy owned by the calling process, which becomes current" do
      parent = Tracer.create_span("http_request")

      {registered, current, lookup} =
        Task.async(fn ->
          registered = Tracer.register_current(parent)
          {registered, Tracer.current_span(), Tracer.lookup(self())}
        end)
        |> Task.await()

      assert registered.reference == parent.reference
      assert registered.pid != parent.pid
      assert current == registered
      assert lookup == [{registered.pid, registered}]
      assert Test.Nif.get(:create_root_span) == {:ok, [{"http_request"}]}
    end

    test "parents spans created afterwards in the calling process" do
      parent = Tracer.create_span("http_request")

      Task.async(fn ->
        Tracer.register_current(parent)
        Tracer.create_span("http_request", Tracer.current_span())
      end)
      |> Task.await()

      assert Test.Nif.get!(:create_child_span) == [{parent.reference}]
    end

    test "is not affected by the owner closing the span" do
      parent = Tracer.create_span("http_request")
      test_pid = self()

      task =
        Task.async(fn ->
          registered = Tracer.register_current(parent)
          send(test_pid, :registered)

          receive do
            :closed -> {registered, Tracer.current_span()}
          end
        end)

      assert_receive :registered
      Tracer.close_span(parent)
      send(task.pid, :closed)

      {registered, current} = Task.await(task)
      assert current == registered
      assert Tracer.lookup(self()) == []
    end
  end

  describe "looking up a process' entries" do
    test "is empty for a process without spans" do
      assert Tracer.lookup(self()) == []
    end

    test "lists spans in the order they were registered" do
      first = Tracer.create_span("http_request")
      second = Tracer.create_span("http_request", first)
      third = Tracer.create_span("http_request", nil)

      assert Tracer.lookup(self()) == [{self(), first}, {self(), second}, {self(), third}]
    end

    test "is empty when the registry is not running" do
      Tracer.create_span("http_request")
      stop_registry()

      assert Tracer.lookup(self()) == []
    end
  end

  describe "instrumenting a function" do
    test "opens a child of the current span, closes it on return and restores the current span" do
      root = Tracer.create_span("http_request")

      result =
        Appsignal.instrument("name", "category", fn span ->
          assert Tracer.current_span() == span
          :result
        end)

      assert result == :result
      assert [{parent_reference}] = Test.Nif.get!(:create_child_span)
      assert parent_reference == root.reference
      assert length(closed_references()) == 1
      assert Tracer.current_span() == root
      assert Tracer.lookup(self()) == [{self(), root}]
    end

    test "opens a root span when there is no current span" do
      Appsignal.instrument("name", fn -> :ok end)

      assert Test.Nif.get!(:create_root_span) == [{"background_job"}]
      assert Tracer.lookup(self()) == []
    end

    test "closes its span when the function raises" do
      root = Tracer.create_span("http_request")

      assert_raise RuntimeError, fn ->
        Appsignal.instrument("name", fn -> raise "Exception!" end)
      end

      assert length(closed_references()) == 1
      assert Tracer.lookup(self()) == [{self(), root}]
    end

    test "opens a new root with instrument_root even when a span is current" do
      outer = Tracer.create_span("http_request")

      Appsignal.Instrumentation.instrument_root("background_job", "name", fn ->
        refute Tracer.current_span() == outer
      end)

      assert Test.Nif.get!(:create_root_span) == [{"background_job"}, {"http_request"}]
      assert length(closed_references()) == 1
      assert Tracer.current_span() == outer
      assert Tracer.lookup(self()) == [{self(), outer}]
    end
  end

  describe "a process that exits with open spans" do
    test "has its spans removed without ending them" do
      test_pid = self()

      pid =
        spawn(fn ->
          span = Tracer.create_span("http_request")
          send(test_pid, {:span, span})
        end)

      assert_receive {:span, span}

      until(fn -> assert Tracer.lookup(pid) == [] end)

      refute span.reference in closed_references()
    end
  end

  defp closed_references do
    case Test.Nif.get(:close_span) do
      {:ok, calls} -> Enum.map(calls, fn {reference} -> reference end)
      :error -> []
    end
  end

  defp spawn_idle do
    pid = spawn(fn -> Process.sleep(:infinity) end)
    on_exit(fn -> Process.exit(pid, :kill) end)
    pid
  end

  defp stop_registry do
    :ok = Supervisor.terminate_child(Appsignal.Supervisor, Tracer)

    on_exit(fn ->
      {:ok, _} = Supervisor.restart_child(Appsignal.Supervisor, Tracer)
    end)
  end
end
