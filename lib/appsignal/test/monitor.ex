defmodule Appsignal.Test.Monitor do
  @moduledoc false
  use Appsignal.Test.Wrapper
  alias Appsignal.Monitor

  def add(pid) do
    add(:add, {pid})
    Monitor.add(pid)
  end
end
