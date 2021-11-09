defmodule Appsignal.Test.Tracer do
  @moduledoc false
  use Appsignal.Test.Wrapper
  alias Appsignal.Tracer

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

  def set_environment(value) do
    add(:set_environment, {value})
    Tracer.set_environment(value)
  end

  def set_params(value) do
    add(:set_params, {value})
    Tracer.set_params(value)
  end

  def set_session_data(value) do
    add(:set_session_data, {value})
    Tracer.set_session_data(value)
  end

  def close_span(span) do
    add(:close_span, {span})
    Tracer.close_span(span)
  end

  def close_span(span, timestamp) do
    add(:close_span, {span, timestamp})
    Tracer.close_span(span, timestamp)
  end
end
