defmodule Appsignal.TransactionRegistry do
  @doc false
  @deprecated "Use Appsignal.Span instead."

  def lookup(_pid) do
    nil
  end

  def register(_parent) do
    nil
  end
end
