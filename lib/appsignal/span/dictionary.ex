defmodule Appsignal.Span.Dictionary do
  alias Appsignal.Span

  def lookup() do
    case :erlang.get(:appsignal_span) do
      [span | _] -> span
      _ -> nil
    end
  end

  def insert(%Span{} = span) do
    case :erlang.get(:appsignal_span) do
      [_ | _] = spans -> Process.put(:appsignal_span, [span | spans])
      _ -> Process.put(:appsignal_span, [span])
    end
  end

  def delete() do
    case :erlang.get(:appsignal_span) do
      [_] -> Process.delete(:appsignal_span)
      [_ | tail] -> Process.put(:appsignal_span, tail)
      _ -> nil
    end
  end
end
