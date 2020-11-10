defmodule Appsignal.Instrumentation.Helpers do
  defdelegate instrument(fun), to: Appsignal.Instrumentation
  defdelegate instrument(name, fun), to: Appsignal.Instrumentation
  defdelegate instrument(name, title, fun), to: Appsignal.Instrumentation
  @deprecated "Use Appsignal.instrument/3 instead."
  defdelegate instrument(transaction, name, title, fun), to: Appsignal.Instrumentation
end
