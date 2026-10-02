defmodule Appsignal.Tracer.Registry do
  @moduledoc false

  alias Appsignal.Span

  @spans __MODULE__.Spans
  @ignored __MODULE__.Ignored

  def new do
    :ets.new(@spans, [:named_table, :public, :ordered_set])
    :ets.new(@ignored, [:named_table, :public, :set])
  end

  def insert(%Span{pid: pid} = span, origin, trace_root) do
    row = {{pid, :erlang.unique_integer([:monotonic])}, origin, span, trace_root || span}

    try do
      :ets.insert(@spans, row)
    rescue
      ArgumentError -> nil
    end
  end

  def remove(%Span{pid: pid, reference: reference}) do
    pid
    |> span_rows()
    |> Enum.filter(fn {_pid, _sequence, _origin, span, _root} -> span.reference == reference end)
    |> Enum.map(&delete_object/1)
    |> Enum.any?()
  end

  def remove(nil), do: false

  def trace_root(%Span{} = span) do
    case last_registration(span) do
      nil -> span
      {_pid, _sequence, _origin, _span, root} -> root
    end
  end

  def lookup(pid) do
    spans = pid |> span_rows() |> Enum.map(fn {pid, _, _, span, _} -> {pid, span} end)

    if ignored_flag?(pid), do: [{pid, :ignore} | spans], else: spans
  end

  def current(pid) do
    case pid |> span_rows() |> List.last() do
      {_pid, _sequence, _origin, span, _root} -> span
      nil -> nil
    end
  end

  def root(pid) do
    case {ignored_flag?(pid), pid |> span_rows() |> List.last()} do
      {false, {_pid, _sequence, _origin, _span, root}} -> root
      _ -> nil
    end
  end

  def ignore(pid) do
    delete(pid)

    try do
      :ets.insert(@ignored, {pid})
    rescue
      ArgumentError -> nil
    end
  end

  def ignored?(pid) do
    ignored_flag?(pid) and span_rows(pid) == []
  end

  def last_own(pid) do
    case pid |> span_rows() |> Enum.filter(&match?({_, _, :own, _, _}, &1)) |> List.last() do
      {_pid, _sequence, :own, span, _root} -> span
      nil -> nil
    end
  end

  def delete(pid) do
    try do
      :ets.select_delete(@spans, [{{{pid, :_}, :_, :_, :_}, [], [true]}])
      :ets.delete(@ignored, pid)
    rescue
      ArgumentError -> :ok
    end

    :ok
  end

  defp last_registration(%Span{pid: pid, reference: reference}) do
    pid
    |> span_rows()
    |> Enum.filter(fn {_pid, _sequence, _origin, span, _root} -> span.reference == reference end)
    |> List.last()
  end

  defp span_rows(pid) do
    try do
      @spans
      |> :ets.select([{{{pid, :_}, :_, :_, :_}, [], [:"$_"]}])
      |> Enum.map(fn {{pid, sequence}, origin, span, root} ->
        {pid, sequence, origin, span, root}
      end)
    rescue
      ArgumentError -> []
    end
  end

  defp ignored_flag?(pid) do
    try do
      :ets.member(@ignored, pid)
    rescue
      ArgumentError -> false
    end
  end

  defp delete_object({pid, sequence, _origin, _span, _root}) do
    try do
      :ets.delete(@spans, {pid, sequence})
    rescue
      ArgumentError -> false
    end
  end
end
