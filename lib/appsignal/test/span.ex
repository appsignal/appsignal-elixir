defmodule Appsignal.Test.Span do
  @moduledoc false
  use Appsignal.Test.Wrapper
  alias Appsignal.Span

  def add_error(span, kind, reason, stacktrace) do
    add(:add_error, {span, kind, reason, stacktrace})
    Span.add_error(span, kind, reason, stacktrace)
  end

  def set_name(span, name) do
    add(:set_name, {span, name})
    Span.set_name(span, name)
  end

  def set_sample_data(span, key, value) do
    add(:set_sample_data, {span, key, value})
    Span.set_sample_data(span, key, value)
  end

  def set_attribute(span, key, value) do
    add(:set_attribute, {span, key, value})
    Span.set_attribute(span, key, value)
  end
end
