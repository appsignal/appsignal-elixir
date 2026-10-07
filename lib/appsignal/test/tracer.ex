defmodule Appsignal.Test.Tracer do
  @moduledoc false
  use Appsignal.Test.Wrapper
  alias Appsignal.Tracer
  alias Appsignal.Tracer.Registry

  defdelegate current_span(), to: Tracer
  defdelegate current_span(pid), to: Tracer
  defdelegate lookup(pid), to: Tracer
  defdelegate root_span(), to: Tracer
  defdelegate root_span(pid), to: Tracer
  defdelegate ignore(), to: Tracer

  def create_span(namespace) do
    add(:create_span, {namespace})
    Tracer.create_span(namespace)
  end

  def create_span(namespace, parent) do
    add(:create_span, {namespace, parent})
    Tracer.create_span(namespace, parent)
  end

  def create_span(namespace, parent, options) do
    add(:create_span, {namespace, parent, options})
    Tracer.create_span(namespace, parent, options)
  end

  def close_span(span) do
    add(:close_span, {span})
    Tracer.close_span(span)
  end

  def close_span(span, timestamp) do
    add(:close_span, {span, timestamp})
    Tracer.close_span(span, timestamp)
  end

  # Called by the monitor, whenever a process it watches goes down, including
  # outside the tests that record calls.
  def close_abandoned(pid, options) do
    if Process.whereis(__MODULE__) do
      add(:close_abandoned, {pid, for({span, _root?} <- Registry.own_spans(pid), do: span)})
    end

    Tracer.close_abandoned(pid, options)
  end
end
