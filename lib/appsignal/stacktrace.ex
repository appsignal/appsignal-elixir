defmodule Appsignal.Stacktrace do
  def get do
    :erlang.get_stacktrace()
  end
end
