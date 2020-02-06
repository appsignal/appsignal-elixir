defmodule Appsignal.Test.Tracer do
  use Appsignal.Test.Wrapper
  alias Appsignal.Tracer

  defdelegate current_span(pid), to: Tracer

  def create_span(name) do
    add(:create_span, {name})
    Tracer.create_span(name)
  end

  def create_span(name, parent, pid) do
    add(:create_span, {name, parent, pid})
    Tracer.create_span(name, parent, pid)
  end

  def close_span(span) do
    add(:close_span, {span})
    Tracer.close_span(span)
  end
end
