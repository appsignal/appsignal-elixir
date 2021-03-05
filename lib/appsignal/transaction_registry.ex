defmodule Appsignal.TransactionRegistry do
  @deprecated "Use Appsignal.Tracer.current_span/0-1 instead"
  def lookup(_pid) do
    nil
  end

  @deprecated "Use Appsignal.Tracer.create_span/1-3 instead"
  def register(_parent) do
    nil
  end
end
