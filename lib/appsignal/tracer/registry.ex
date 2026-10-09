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
    rows = span_rows(pid)

    {removed, _rest} =
      Enum.split_with(rows, fn {_pid, _sequence, _origin, span, _root, _anchor} ->
        span.reference == reference
      end)

    case Enum.find(removed, &match?({_, _, :own, _, _, _}, &1)) do
      {_pid, _sequence, :own, _span, _root, anchor} -> repoint(rows, reference, anchor)
      nil -> :ok
    end

    removed
    |> Enum.map(&delete_object/1)
    |> Enum.any?()
  end

  def remove(nil), do: false

  def own_spans(pid) do
    for {_pid, _sequence, :own, span, root, _anchor} <- span_rows(pid),
        do: {span, root.reference == span.reference}
  end

  def anchor(%Span{pid: pid, reference: reference}, owner_pid) when pid == owner_pid do
    if Enum.any?(span_rows(pid), &match?({_, _, :own, %Span{reference: ^reference}, _, _}, &1)),
      do: reference
  end

  def anchor(_parent, _owner_pid), do: nil

  def descendants(%Span{pid: pid, reference: reference}) do
    own_rows = pid |> span_rows() |> Enum.filter(&match?({_, _, :own, _, _, _}, &1))

    own_rows
    |> collect_descendants([reference], [])
    |> Enum.sort_by(fn {_pid, sequence, _origin, _span, _root, _anchor} -> -sequence end)
    |> Enum.map(fn {_pid, _sequence, _origin, span, _root, _anchor} -> span end)
  end

  def trace_root(%Span{} = span) do
    case last_registration(span) do
      nil -> span
      {_pid, _sequence, _origin, _span, root, _anchor} -> root
    end
  end

  def lookup(pid) do
    pid |> span_rows() |> Enum.map(fn {pid, _, _, span, _, _} -> {pid, span} end)
  end

  def current(pid) do
    case pid |> span_rows() |> List.last() do
      {_pid, _sequence, _origin, span, _root, _anchor} -> span
      nil -> nil
    end
  end

  def root(pid) do
    case pid |> span_rows() |> List.last() do
      {_pid, _sequence, _origin, _span, root, _anchor} -> root
      nil -> nil
    end
  end

  def last_own(pid) do
    case pid |> span_rows() |> Enum.filter(&match?({_, _, :own, _, _, _}, &1)) |> List.last() do
      {_pid, _sequence, :own, span, _root, _anchor} -> span
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
    pid
    |> span_rows()
    |> Enum.filter(fn {_pid, _sequence, _origin, span, _root, _anchor} ->
      span.reference == reference
    end)
    |> List.last()
  end

  defp collect_descendants(rows, frontier, found) do
    case Enum.filter(rows, fn {_pid, _sequence, _origin, _span, _root, anchor} ->
           anchor in frontier
         end) do
      [] ->
        found

      children ->
        references = Enum.map(children, fn {_, _, _, span, _, _} -> span.reference end)
        collect_descendants(rows -- children, references, found ++ children)
    end
  end

  defp repoint(rows, reference, anchor) do
    rows
    |> Enum.filter(&match?({_, _, _, _, _, ^reference}, &1))
    |> Enum.each(fn {pid, sequence, _origin, _span, _root, _anchor} ->
      :ets.update_element(@spans, {pid, sequence}, {5, anchor})
    end)
  end

  defp span_rows(pid) do
    try do
      @spans
      |> :ets.select([{{{pid, :_}, :_, :_, :_, :_}, [], [:"$_"]}])
      |> Enum.map(fn {{pid, sequence}, origin, span, root, anchor} ->
        {pid, sequence, origin, span, root, anchor}
      end)
    rescue
      ArgumentError -> []
    end
  end

  defp delete_object({pid, sequence, _origin, _span, _root, _anchor}) do
    try do
      :ets.delete(@spans, {pid, sequence})
    rescue
      ArgumentError -> false
    end
  end
end
