defmodule Appsignal.Test.Logger do
  @moduledoc false
  use Appsignal.Test.Wrapper
  require Logger

  def debug(log) do
    add(:debug, {log})
    Logger.debug(log)
  end
end
