defmodule Appsignal.Test.Monitor do
  @moduledoc false
  use Appsignal.Test.Wrapper
  alias Appsignal.Monitor

  def add do
    add(:add, {self()})
    Monitor.add()
  end
end
