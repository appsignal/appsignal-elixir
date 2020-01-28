defmodule Appsignal.WrappedNif do
  import ExUnit.Assertions
  alias Appsignal.Nif

  def start_link do
    {:ok, pid} = Agent.start_link(fn -> %{} end, name: __MODULE__)

    ExUnit.Callbacks.on_exit(fn ->
      ref = Process.monitor(pid)
      assert_receive {:DOWN, ^ref, _, _, _}, 500
    end)

    {:ok, pid}
  end

  def create_root_span(name) do
    add(:create_root_span, {name})
    Nif.create_root_span(name)
  end

  def create_child_span(trace_id, span_id, name) do
    add(:create_child_span, {trace_id, span_id, name})
    Nif.create_child_span(trace_id, span_id, name)
  end

  def close_span(reference) do
    add(:close_span, {reference})
    Nif.close_span(reference)
  end

  def get(key) do
    Agent.get(__MODULE__, &Map.fetch!(&1, key))
  end

  defp add(key, value) do
    Agent.get_and_update(__MODULE__, fn state ->
      Map.get_and_update(state, key, fn current ->
        case current do
          nil -> {nil, [value]}
          _ -> {current, [value | current]}
        end
      end)
    end)
  end
end
