defmodule Appsignal.Stacktrace do
  def get do
    System.stacktrace()
  end
end
