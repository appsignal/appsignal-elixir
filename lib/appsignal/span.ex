defmodule Appsignal.Span do
  alias Appsignal.{Config, Nif, Span}
  defstruct [:reference, :pid]
  @nif Application.get_env(:appsignal, :appsignal_tracer_nif, Appsignal.Nif)

  def create_root(namespace, pid) do
    if Config.active?() do
      {:ok, reference} = @nif.create_root_span(namespace)

      %Span{reference: reference, pid: pid}
    end
  end

  def create_root(namespace, pid, start_time) do
    if Config.active?() do
      sec = :erlang.convert_time_unit(start_time, :native, :second)
      nsec = :erlang.convert_time_unit(start_time, :native, :nanosecond) - sec * 1_000_000_000
      {:ok, reference} = @nif.create_root_span_with_timestamp(namespace, sec, nsec)

      %Span{reference: reference, pid: pid}
    end
  end

  def create_child(parent, pid) do
    if Config.active?() do
      {:ok, trace_id} = Span.trace_id(parent)
      {:ok, span_id} = Span.span_id(parent)
      {:ok, reference} = @nif.create_child_span(trace_id, span_id)

      %Span{reference: reference, pid: pid}
    end
  end

  def create_child(parent, pid, start_time) do
    if Config.active?() do
      sec = :erlang.convert_time_unit(start_time, :native, :second)
      nsec = :erlang.convert_time_unit(start_time, :native, :nanosecond) - sec * 1_000_000_000

      {:ok, trace_id} = Span.trace_id(parent)
      {:ok, span_id} = Span.span_id(parent)
      {:ok, reference} = @nif.create_child_span_with_timestamp(trace_id, span_id, sec, nsec)

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

  def set_name(%Span{reference: reference} = span, name)
      when is_reference(reference) and is_binary(name) do
    if Config.active?() do
      :ok = @nif.set_span_name(reference, name)
      span
    end
  end

  def set_name(_span, _name), do: nil

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

  def set_attribute(_span, _key, _value), do: nil

  def set_sql(%Span{reference: reference} = span, body) when is_binary(body) do
    :ok = Nif.set_span_attribute_sql_string(reference, "appsignal:body", body)
    span
  end

  def set_sql(_span, _body), do: nil

  def set_sample_data(%Span{reference: reference} = span, key, value)
      when is_binary(key) and is_map(value) do
    data =
      value
      |> Appsignal.Utils.MapFilter.filter()
      |> Appsignal.Utils.DataEncoder.encode()

    :ok = Nif.set_span_sample_data(reference, key, data)
    span
  end

  def set_sample_data(_span, _key, _value), do: nil

  def add_error(%Span{reference: reference} = span, kind, reason, stacktrace) do
    if Config.active?() do
      {name, message, formatted_stacktrace} = Appsignal.Error.metadata(kind, reason, stacktrace)

      :ok =
        @nif.add_span_error(
          reference,
          name,
          message,
          Appsignal.Utils.DataEncoder.encode(formatted_stacktrace)
        )

      span
    end
  end

  def add_error(nil, _kind, _reason, _stacktrace), do: nil

  def close(%Span{reference: reference} = span) do
    :ok = @nif.close_span(reference)
    span
  end

  def close(%Span{reference: reference} = span, end_time) do
    sec = :erlang.convert_time_unit(end_time, :native, :second)
    nsec = :erlang.convert_time_unit(end_time, :native, :nanosecond) - sec * 1_000_000_000
    :ok = @nif.close_span_with_timestamp(reference, sec, nsec)
    span
  end

  def close(nil), do: nil

  def to_map(%Span{reference: reference}) do
    {:ok, json} = Nif.span_to_json(reference)
    Appsignal.Json.decode!(json)
  end
end
