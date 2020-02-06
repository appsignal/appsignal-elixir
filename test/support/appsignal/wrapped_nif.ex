defmodule Appsignal.WrappedNif do
  use Wrapper
  alias Appsignal.Nif

  def create_root_span(name) do
    add(:create_root_span, {name})
    Nif.create_root_span(name)
  end

  def create_child_span(trace_id, span_id, name) do
    add(:create_child_span, {trace_id, span_id, name})
    Nif.create_child_span(trace_id, span_id, name)
  end

  def add_span_error(reference, name, message, stacktrace) do
    add(:add_span_error, {reference, name, message, stacktrace})
    Nif.add_span_error(reference, name, message, stacktrace)
  end

  def close_span(reference) do
    add(:close_span, {reference})
    Nif.close_span(reference)
  end
end
