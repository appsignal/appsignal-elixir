defmodule Appsignal.Span do
  alias Appsignal.{Nif, Span, Span.Dictionary, Span.Registry}
  defstruct [:reference, :trace_id, :span_id]

  def trace_id(reference) do
    Nif.trace_id(reference)
  end

  def span_id(reference) do
    Nif.span_id(reference)
  end

  def create(name \\ "") do
    case Dictionary.lookup() || parent() do
      %Span{trace_id: trace_id, span_id: span_id} ->
        create(name, trace_id, span_id)

      _ ->
        {:ok, reference} = Nif.create_root_span(name)
        {:ok, trace_id} = trace_id(reference)
        {:ok, span_id} = span_id(reference)

        register(%Span{reference: reference, trace_id: trace_id, span_id: span_id})
    end
  end

  def create(name, trace_id, parent_id) do
    {:ok, reference} = Nif.create_child_span(trace_id, parent_id, name)
    {:ok, span_id} = span_id(reference)

    register(%Span{reference: reference, trace_id: trace_id, span_id: span_id})
  end

  defp register(span) do
    Dictionary.insert(span)
    Registry.insert(span)

    span
  end

  defp parent do
    {:dictionary, values} = :erlang.process_info(self(), :dictionary)

    case values[:"$callers"] do
      [parent | _] -> Registry.lookup(parent)
      _ -> nil
    end
  end

  def set_namespace(%Span{reference: reference} = span, namespace) when is_binary(namespace) do
    :ok = Nif.set_span_namespace(reference, namespace)
    span
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

  def set_sample_data(%Span{reference: reference} = span, key, value)
      when is_binary(key) and is_map(value) do
    data = Appsignal.Utils.DataEncoder.encode(value)
    :ok = Nif.set_span_sample_data(reference, key, data)
    span
  end

  def add_error(%Span{reference: reference} = span, error, stacktrace) do
    {name, message} = Appsignal.Error.metadata(error)

    backtrace =
      stacktrace
      |> Appsignal.Backtrace.from_stacktrace()
      |> Appsignal.Utils.DataEncoder.encode()

    :ok = Nif.add_span_error(reference, name, message, backtrace)
    span
  end

  def close() do
    Dictionary.lookup() |> close()
  end

  def close(%Span{reference: reference} = span) do
    :ok = Nif.close_span(reference)
    Dictionary.delete()
    Registry.delete()
    span
  end
end
