defmodule Appsignal.Tracer.RegistryTest do
  use ExUnit.Case
  alias Appsignal.{Span, Test, Tracer}
  alias Appsignal.Tracer.Registry

  @spans Appsignal.Tracer.Registry.Spans
  @ignored Appsignal.Tracer.Registry.Ignored

  setup do
    start_supervised!(Test.Nif)
    start_supervised!(Test.Monitor)
    :ok
  end

  describe "registering a span" do
    test "stores one row with a sequence, the origin, the span and its trace root" do
      span = Tracer.create_span("http_request")

      assert [%{pid: pid, sequence: sequence, origin: :own, span: ^span, root: reference}] =
               rows(self())

      assert pid == self()
      assert is_integer(sequence)
      assert reference == span.reference
    end

    test "records the trace root of the parent for a child span" do
      root = Tracer.create_span("http_request")
      child = Tracer.create_span("http_request", root)
      grandchild = Tracer.create_span("http_request", child)

      assert Registry.trace_root(child) == root.reference
      assert Registry.trace_root(grandchild) == root.reference
    end

    test "records the parent itself as the trace root when the parent is not registered" do
      parent = Span.create_root("http_request", self())
      child = Tracer.create_span("http_request", parent)

      assert Registry.trace_root(child) == parent.reference
    end

    test "records a span registered from another process as attached, with its trace root" do
      root = Tracer.create_span("http_request")
      child = Tracer.create_span("http_request", root)

      rows =
        Task.async(fn ->
          Tracer.register_current(child)
          rows(self())
        end)
        |> Task.await()

      assert [%{origin: :attached, span: attached, root: trace_root}] = rows
      assert attached.reference == child.reference
      assert trace_root == root.reference
    end
  end

  describe "closing a span" do
    test "leaves no rows behind" do
      root = Tracer.create_span("http_request")
      child = Tracer.create_span("http_request", root)

      Tracer.close_span(child)
      Span.close(root)

      assert rows(self()) == []
    end

    test "removes every row of a span registered twice in its own process" do
      span = Tracer.create_span("http_request")
      Tracer.register_current(span)

      Tracer.close_span(span)

      assert rows(self()) == []
    end

    test "keeps the rows of a span attached in another process" do
      span = Tracer.create_span("http_request")
      test_pid = self()

      task =
        Task.async(fn ->
          Tracer.register_current(span)
          send(test_pid, :attached)

          receive do
            :closed -> rows(self())
          end
        end)

      assert_receive :attached
      Tracer.close_span(span)
      send(task.pid, :closed)

      assert [%{origin: :attached}] = Task.await(task)
    end

    test "removes nothing for a span that is not registered" do
      Tracer.create_span("http_request")
      unregistered = Span.create_root("http_request", self())

      assert Registry.remove(unregistered) == false
      assert length(rows(self())) == 1
    end
  end

  describe "ignoring a process" do
    test "removes its span rows and stores the flag separately" do
      Tracer.create_span("http_request")

      Tracer.ignore()

      assert rows(self()) == []
      assert :ets.lookup(@ignored, self()) == [{self()}]
    end

    test "keeps the flag when a span is registered from another process afterwards" do
      parent = Tracer.create_span("http_request")

      {spans, flags} =
        Task.async(fn ->
          Tracer.ignore()
          Tracer.register_current(parent)
          {rows(self()), :ets.lookup(@ignored, self())}
        end)
        |> Task.await()

      assert [%{origin: :attached}] = spans
      assert [{_pid}] = flags
    end
  end

  describe "deleting a process' entries" do
    test "removes its span rows and its flag" do
      Tracer.create_span("http_request")
      Tracer.ignore()
      Tracer.register_current(Span.create_root("http_request", self()))

      Tracer.delete(self())

      assert rows(self()) == []
      assert :ets.lookup(@ignored, self()) == []
    end
  end

  describe "a process that exits" do
    test "has its span rows and flag removed by the monitor" do
      test_pid = self()

      pid =
        spawn(fn ->
          Tracer.create_span("http_request")
          Tracer.ignore(self())
          Tracer.register_current(Span.create_root("http_request", self()))
          send(test_pid, :done)
        end)

      assert_receive :done

      AppsignalTest.Utils.until(fn ->
        assert rows(pid) == []
        assert :ets.lookup(@ignored, pid) == []
      end)
    end
  end

  describe "the rows of a process" do
    test "are kept apart from another process's rows" do
      first = spawn_idle()
      second = spawn_idle()

      first_root = Tracer.create_span("http_request", nil, pid: first)
      second_root = Tracer.create_span("http_request", nil, pid: second)
      first_child = Tracer.create_span("http_request", first_root, pid: first)
      second_child = Tracer.create_span("http_request", second_root, pid: second)

      assert Tracer.lookup(first) == [{first, first_root}, {first, first_child}]
      assert Tracer.lookup(second) == [{second, second_root}, {second, second_child}]

      Tracer.delete(first)

      assert rows(first) == []
      assert Tracer.lookup(second) == [{second, second_root}, {second, second_child}]
    end
  end

  # Reads the registry's table, so these tests see what `lookup/1` does not
  # show: origins and trace roots. Order is checked through
  # `lookup/1`, since this sorts the rows itself.
  defp rows(pid) do
    @spans
    |> :ets.select([{{{pid, :_}, :_, :_, :_}, [], [:"$_"]}])
    |> Enum.map(fn {{pid, sequence}, origin, span, root} ->
      %{pid: pid, sequence: sequence, origin: origin, span: span, root: root}
    end)
    |> Enum.sort_by(& &1.sequence)
  end

  defp spawn_idle do
    pid = spawn(fn -> Process.sleep(:infinity) end)
    on_exit(fn -> Process.exit(pid, :kill) end)
    pid
  end
end
