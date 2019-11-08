defmodule Appsignal.Span do
  alias Appsignal.{Nif, Span.Registry}

  def trace_id(reference) do
    Nif.trace_id(reference)
  end

  def span_id(reference) do
    Nif.span_id(reference)
  end

  def create(name) do
    case parent() do
      {_pid, trace_id, span_id} ->
        create(name, trace_id, span_id)

      _ ->
        case Registry.lookup() do
          {_pid, trace_id, span_id} ->
            create(name, trace_id, span_id)

          _ ->
            {:ok, reference} = Nif.create_root_span(name)
            {:ok, trace_id} = trace_id(reference)
            {:ok, span_id} = span_id(reference)

            Process.put(:appsignal_trace_id, trace_id)
            Process.put(:appsignal_span_id, span_id)
            Registry.insert(trace_id, span_id)
            reference
        end
    end
  end

  defp parent do
    {:dictionary, values} = Process.info(self(), :dictionary)

    case values[:"$callers"] do
      [parent | _] ->
        [{^parent, trace_id, span_id}] = Appsignal.Span.Registry.lookup(parent)
        {parent, trace_id, span_id}

      _ ->
        nil
    end
  end

  def create(name, trace_id, parent_id) do
    {:ok, reference} = Nif.create_child_span(trace_id, parent_id, name)
    {:ok, span_id} = span_id(reference)

    Process.put(:appsignal_trace_id, trace_id)
    Process.put(:appsignal_span_id, span_id)
    Registry.insert(trace_id, span_id)
    reference
  end

  def set_attribute(reference, key, true) when is_binary(key) do
    :ok = Nif.set_span_attribute_bool(reference, key, 1)
    reference
  end

  def set_attribute(reference, key, false) when is_binary(key) do
    :ok = Nif.set_span_attribute_bool(reference, key, 0)
    reference
  end

  def set_attribute(reference, key, value) when is_binary(key) and is_binary(value) do
    :ok = Nif.set_span_attribute_string(reference, key, value)
    reference
  end

  def set_attribute(reference, key, value) when is_binary(key) and is_integer(value) do
    :ok = Nif.set_span_attribute_int(reference, key, value)
    reference
  end

  def set_attribute(reference, key, value) when is_binary(key) and is_float(value) do
    :ok = Nif.set_span_attribute_double(reference, key, value)
    reference
  end

  def close(reference) do
    :ok = Nif.close_span(reference)
    reference
  end
end
