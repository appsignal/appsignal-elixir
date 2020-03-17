defmodule Appsignal.Span do
  alias Appsignal.{Config, Nif, Span}
  defstruct [:reference, :pid]
  @nif Application.get_env(:appsignal, :appsignal_tracer_nif, Appsignal.Nif)

  def create_root(name, pid) do
    if Config.active?() do
      {:ok, reference} = @nif.create_root_span(name)

      %Span{reference: reference, pid: pid}
    end
  end

  def create_child(name, nil, pid), do: create_root(name, pid)

  def create_child(name, parent, pid) do
    if Config.active?() do
      {:ok, trace_id} = Span.trace_id(parent)
      {:ok, span_id} = Span.span_id(parent)
      {:ok, reference} = @nif.create_child_span(name, trace_id, span_id)

      %Span{reference: reference, pid: pid}
    end
  end

  def trace_id(%Span{reference: reference}) do
    @nif.trace_id(reference)
  end

  def trace_id(nil), do: {:ok, nil}

  def span_id(%Span{reference: reference}) do
    @nif.span_id(reference)
  end

  def span_id(nil), do: {:ok, nil}

  def set_name(%Span{reference: reference} = span, name) when is_binary(name) do
    if Config.active?() do
      :ok = @nif.set_span_name(reference, name)
      span
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

    encoded_stacktrace =
      stacktrace
      |> Enum.map(&Exception.format_stacktrace_entry/1)
      |> Appsignal.Utils.DataEncoder.encode()

    :ok = @nif.add_span_error(reference, name, message, encoded_stacktrace)
    span
  end

  def close(%Span{reference: reference} = span) do
    :ok = @nif.close_span(reference)
    span
  end

  def close(nil), do: nil
end
