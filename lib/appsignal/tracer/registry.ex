defmodule Appsignal.Tracer.Registry do
  @moduledoc false

  alias Appsignal.Span

  @spans __MODULE__.Spans
  @ignored __MODULE__.Ignored

  def new do
    :ets.new(@spans, [:named_table, :public, :ordered_set])
    :ets.new(@ignored, [:named_table, :public, :set])
  end

  def insert(%Span{pid: pid, reference: reference} = span, origin, trace_root) do
    row = {{pid, :erlang.unique_integer([:monotonic])}, origin, span, trace_root || reference}

    try do
      :ets.insert(@spans, row)
    rescue
      ArgumentError -> nil
    end
  end

  def remove(%Span{pid: pid, reference: reference}) do
    pid
    |> registrations(reference)
    |> Enum.map(&delete_row/1)
    |> Enum.any?()
  end

  def remove(nil), do: false

  def trace_root(%Span{reference: reference} = span) do
    case last_registration(span) do
      nil -> reference
      {_key, _origin, _span, root} -> root
    end
  end

  def lookup(pid) do
    spans = pid |> span_rows() |> Enum.map(fn {{pid, _sequence}, _, span, _} -> {pid, span} end)

    if ignored_flag?(pid), do: [{pid, :ignore} | spans], else: spans
  end

  def current(pid) do
    case last_row(pid) do
      {_key, _origin, span, _root} -> span
      nil -> nil
    end
  end

  def root(pid) do
    case {ignored_flag?(pid), span_rows(pid)} do
      {false, [{_key, _origin, span, _root} | _]} -> span
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
    pid |> registrations(reference) |> List.last()
  end

  defp registrations(pid, reference) do
    :ets.select(@spans, [{{{pid, :_}, :_, %{reference: reference}, :_}, [], [:"$_"]}])
  rescue
    ArgumentError -> []
  end

  defp span_rows(pid) do
    :ets.select(@spans, [{{{pid, :_}, :_, :_, :_}, [], [:"$_"]}])
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

  defp ignored_flag?(pid) do
    try do
      :ets.member(@ignored, pid)
    rescue
      ArgumentError -> false
    end
  end

  defp delete_row({key, _origin, _span, _root}) do
    :ets.delete(@spans, key)
  rescue
    ArgumentError -> false
  end
end
