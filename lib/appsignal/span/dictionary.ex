defmodule Appsignal.Span.Dictionary do
  alias Appsignal.Span

  def lookup() do
    Process.get(:appsignal_span)
  end

  def insert(%Span{} = span) do
    Process.put(:appsignal_span, span)
  end

  def delete() do
    Process.delete(:appsignal_span)
  end
end
