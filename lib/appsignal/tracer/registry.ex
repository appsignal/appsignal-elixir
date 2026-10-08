defmodule Appsignal.Tracer.Registry do
  @moduledoc false

  alias Appsignal.Span

  @spans __MODULE__.Spans

  def new do
    :ets.new(@spans, [:named_table, :public, :ordered_set])
  end

  def insert(%Span{pid: pid} = span, origin, trace_root, anchor) do
    row = {{pid, :erlang.unique_integer([:monotonic])}, origin, span, trace_root || span, anchor}

    try do
      :ets.insert(@spans, row)
    rescue
      ArgumentError -> nil
    end
  end

  def remove(%Span{pid: pid, reference: reference}) do
    removed = registrations(pid, reference)

    case Enum.find(removed, &match?({_, :own, _, _, _}, &1)) do
      {_key, :own, _span, _root, anchor} -> repoint(pid, reference, anchor)
      nil -> :ok
    end

    removed
    |> Enum.map(&delete_row/1)
    |> Enum.any?()
  end

  def remove(nil), do: false

  def own_spans(pid) do
    for {_key, :own, span, _root, _anchor} <- span_rows(pid), do: span
  end

  def anchor(%Span{pid: pid, reference: reference}, owner_pid) when pid == owner_pid do
    if Enum.any?(registrations(pid, reference), &match?({_, :own, _, _, _}, &1)),
      do: reference
  end

  def anchor(_parent, _owner_pid), do: nil

  def descendants(%Span{pid: pid, reference: reference}) do
    own_rows = pid |> span_rows() |> Enum.filter(&match?({_, :own, _, _, _}, &1))

    own_rows
    |> collect_descendants([reference], [])
    |> Enum.sort_by(fn {{_pid, sequence}, _origin, _span, _root, _anchor} -> -sequence end)
    |> Enum.map(fn {_key, _origin, span, _root, _anchor} -> span end)
  end

  def trace_root(%Span{} = span) do
    case last_registration(span) do
      nil -> span
      {_key, _origin, _span, root, _anchor} -> root
    end
  end

  def lookup(pid) do
    pid |> span_rows() |> Enum.map(fn {{pid, _sequence}, _, span, _, _} -> {pid, span} end)
  end

  def current(pid) do
    case last_row(pid) do
      {_key, _origin, span, _root, _anchor} -> span
      nil -> nil
    end
  end

  def root(pid) do
    case last_row(pid) do
      {_key, _origin, _span, root, _anchor} -> root
      nil -> nil
    end
  end

  def last_own(pid) do
    case pid |> span_rows() |> Enum.filter(&match?({_, :own, _, _, _}, &1)) |> List.last() do
      {_key, :own, span, _root, _anchor} -> span
      nil -> nil
    end
  end

  def delete(pid) do
    try do
      :ets.select_delete(@spans, [{{{pid, :_}, :_, :_, :_, :_}, [], [true]}])
    rescue
      ArgumentError -> :ok
    end

    :ok
  end

  defp last_registration(%Span{pid: pid, reference: reference}) do
    pid |> registrations(reference) |> List.last()
  end

  defp collect_descendants(rows, frontier, found) do
    case Enum.filter(rows, fn {_key, _origin, _span, _root, anchor} -> anchor in frontier end) do
      [] ->
        found

      children ->
        references = Enum.map(children, fn {_, _, span, _, _} -> span.reference end)
        collect_descendants(rows -- children, references, found ++ children)
    end
  end

  defp repoint(pid, reference, anchor) do
    @spans
    |> :ets.select([{{{pid, :_}, :_, :_, :_, reference}, [], [{:element, 1, :"$_"}]}])
    |> Enum.each(&:ets.update_element(@spans, &1, {5, anchor}))
  end

  defp registrations(pid, reference) do
    :ets.select(@spans, [{{{pid, :_}, :_, %{reference: reference}, :_, :_}, [], [:"$_"]}])
  rescue
    ArgumentError -> []
  end

  defp span_rows(pid) do
    :ets.select(@spans, [{{{pid, :_}, :_, :_, :_, :_}, [], [:"$_"]}])
  rescue
    ArgumentError -> []
  end

  # Keys are `{pid, sequence}`, and a list sorts after any integer, so the key
  # before `{pid, []}` is the pid's latest registration.
  defp last_row(pid) do
    case :ets.prev(@spans, {pid, []}) do
      {^pid, _sequence} = key -> @spans |> :ets.lookup(key) |> List.first()
      _ -> nil
    end
  rescue
    ArgumentError -> nil
  end

  defp delete_row({key, _origin, _span, _root, _anchor}) do
    :ets.delete(@spans, key)
  rescue
    ArgumentError -> false
  end
end
