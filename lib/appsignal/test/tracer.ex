defmodule Appsignal.Test.Tracer do
  use Appsignal.Test.Wrapper
  alias Appsignal.Tracer

  defdelegate current_span(), to: Tracer
  defdelegate current_span(pid), to: Tracer
  defdelegate ignore(), to: Tracer

  def create_span(namespace) do
    add(:create_span, {namespace})
    Tracer.create_span(namespace)
  end

  def create_span(namespace, parent) do
    add(:create_span, {namespace, parent})
    Tracer.create_span(namespace, parent)
  end

  def create_span(namespace, parent, pid) do
    add(:create_span, {namespace, parent, pid})
    Tracer.create_span(namespace, parent, pid)
  end

  def close_span(span) do
    add(:close_span, {span})
    Tracer.close_span(span)
  end
end
