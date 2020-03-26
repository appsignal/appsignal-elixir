defmodule Appsignal.Test.Monitor do
  use Appsignal.Test.Wrapper
  alias Appsignal.Monitor

  def add do
    add(:add, {self()})
    Monitor.add()
  end
end
