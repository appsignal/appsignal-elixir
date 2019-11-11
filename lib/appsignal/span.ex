defmodule Appsignal.Span do
  alias Appsignal.{Nif, Span, Span.Registry}
  defstruct [:reference, :trace_id, :span_id]

  def trace_id(reference) do
    Nif.trace_id(reference)
  end

  def span_id(reference) do
    Nif.span_id(reference)
  end

  def create(name) do
    case parent() do
      %Span{trace_id: trace_id, span_id: span_id} ->
        create(name, trace_id, span_id)

      _ ->
        {:ok, reference} = Nif.create_root_span(name)
        {:ok, trace_id} = trace_id(reference)
        {:ok, span_id} = span_id(reference)

        span = %Span{reference: reference, trace_id: trace_id, span_id: span_id}

        Process.put(:appsignal_span, span)
        Registry.insert(span)

        span
    end
  end

  def create(name, trace_id, parent_id) do
    {:ok, reference} = Nif.create_child_span(trace_id, parent_id, name)
    {:ok, span_id} = span_id(reference)

    span = %Span{reference: reference, trace_id: trace_id, span_id: span_id}

    Process.put(:appsignal_span, span)
    Registry.insert(span)
    reference
  end

  defp parent do
    {:dictionary, values} = Process.info(self(), :dictionary)

    case values[:"$callers"] do
      [parent | _] ->
        [{^parent, %Span{} = span}] = Appsignal.Span.Registry.lookup(parent)
        span

      _ ->
        nil
    end
  end

  def set_attribute(%Span{reference: reference} = span, key, true) when is_binary(key) do
    :ok = Nif.set_span_attribute_bool(reference, key, 1)
    span
  end

  def set_attribute(%Span{reference: reference} = span, key, false) when is_binary(key) do
    :ok = Nif.set_span_attribute_bool(reference, key, 0)
    span
  end

  def set_attribute(%Span{reference: reference} = span, key, value)
      when is_binary(key) and is_binary(value) do
    :ok = Nif.set_span_attribute_string(reference, key, value)
    span
  end

  def set_attribute(%Span{reference: reference} = span, key, value)
      when is_binary(key) and is_integer(value) do
    :ok = Nif.set_span_attribute_int(reference, key, value)
    span
  end

  def set_attribute(%Span{reference: reference} = span, key, value)
      when is_binary(key) and is_float(value) do
    :ok = Nif.set_span_attribute_double(reference, key, value)
    span
  end

  def close() do
    :appsignal_span
    |> Process.get()
    |> close()
  end

  def close(%Span{reference: reference} = span) do
    :ok = Nif.close_span(reference)
    Process.delete(:appsignal_span)
    Registry.delete()
    span
  end
end
