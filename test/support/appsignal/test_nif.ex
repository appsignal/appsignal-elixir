defmodule Appsignal.Test.Nif do
  use Appsignal.Test.Wrapper
  alias Appsignal.Nif

  defdelegate trace_id(span), to: Nif
  defdelegate span_id(span), to: Nif

  def create_root_span(namespace) do
    add(:create_root_span, {namespace})
    Nif.create_root_span(namespace)
  end

  def create_root_span_with_timestamp(namespace, sec, nsec) do
    add(:create_root_span_with_timestamp, {namespace, sec, nsec})
    Nif.create_root_span_with_timestamp(namespace, sec, nsec)
  end

  def create_child_span(trace_id, span_id) do
    add(:create_child_span, {trace_id, span_id})
    Nif.create_child_span(trace_id, span_id)
  end

  def create_child_span_with_timestamp(trace_id, span_id, sec, nsec) do
    add(:create_child_span_with_timestamp, {trace_id, span_id, sec, nsec})
    Nif.create_child_span_with_timestamp(trace_id, span_id, sec, nsec)
  end

  def set_span_name(reference, name) do
    add(:set_span_name, {reference, name})
    Nif.set_span_name(reference, name)
  end

  def add_span_error(reference, name, message, stacktrace) do
    add(:add_span_error, {reference, name, message, stacktrace})
    Nif.add_span_error(reference, name, message, stacktrace)
  end

  def close_span(reference) do
    add(:close_span, {reference})
    Nif.close_span(reference)
  end

  def close_span_with_timestamp(reference, sec, nsec) do
    add(:close_span_with_timestamp, {reference, sec, nsec})
    Nif.close_span_with_timestamp(reference, sec, nsec)
  end
end
