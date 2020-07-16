defmodule Appsignal.Instrumentation.Helpers do
  defdelegate instrument(fun), to: Appsignal.Instrumentation
  defdelegate instrument(name, fun), to: Appsignal.Instrumentation
  defdelegate instrument(name, title, fun), to: Appsignal.Instrumentation
end
