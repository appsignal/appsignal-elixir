defmodule Appsignal.Span do
  alias Appsignal.Nif

  def trace_id(reference) do
    Nif.trace_id(reference)
  end

  def span_id(reference) do
    Nif.span_id(reference)
  end

  def create(name) do
    {:ok, reference} = Nif.create_root_span(name)
    # TODO: Store the span reference in the process dictionary.
    reference
  end

  def create(trace_id, parent_id, name) do
    {:ok, reference} = Nif.create_child_span(trace_id, parent_id, name)
    # TODO: Store the span reference in the process dictionary.
    reference
  end

  def set_attribute(reference, key, value) when is_binary(value) do
    :ok = Nif.set_span_attribute_string(reference, key, value)
    reference
  end

  def close(reference) do
    :ok = Nif.close_span(reference)
    reference
  end
end
