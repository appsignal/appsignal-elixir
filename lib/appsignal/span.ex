defmodule Appsignal.Span do
  alias Appsignal.{Nif, Span, Span.Dictionary, Span.Registry}
  defstruct [:reference]

  def trace_id(%Span{reference: reference}) do
    Nif.trace_id(reference)
  end

  def span_id(%Span{reference: reference}) do
    Nif.span_id(reference)
  end

  def set_name(%Span{reference: reference} = span, name) when is_binary(name) do
    :ok = Nif.set_span_name(reference, name)
    span
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
end
