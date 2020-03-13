defmodule Appsignal.Test.Span do
  use Appsignal.Test.Wrapper
  alias Appsignal.Span

  def add_error(span, error, stacktrace) do
    add(:add_error, {span, error, stacktrace})
    Span.add_error(span, error, stacktrace)
  end

  def set_name(span, name) do
    add(:set_name, {span, name})
    Span.set_name(span, name)
  end
end
