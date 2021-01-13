defmodule Appsignal.Instrumentation.Helpers do
  defdelegate instrument(fun), to: Appsignal.Instrumentation
  defdelegate instrument(name, fun), to: Appsignal.Instrumentation
  defdelegate instrument(name, title, fun), to: Appsignal.Instrumentation

  @deprecated "Use Appsignal.instrument/3 instead."
  def instrument(_transaction, name, title, fun) do
    Appsignal.Instrumentation.instrument(name, title, fun)
  end
end
