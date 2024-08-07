defmodule Appsignal.Heartbeat do
  alias Appsignal.CheckIn
  alias Appsignal.CheckIn.Cron

  @type t :: Cron.t()

  @spec new(String.t()) :: Cron.t()
  @deprecated "Use `Appsignal.CheckIn.Cron.new/1` instead."
  defdelegate new(name), to: Cron

  @spec start(Cron.t()) :: :ok
  @deprecated "Use `Appsignal.CheckIn.Cron.start/1` instead."
  defdelegate start(cron), to: Cron

  @spec finish(Cron.t()) :: :ok
  @deprecated "Use `Appsignal.CheckIn.Cron.finish/1` instead."
  defdelegate finish(cron), to: Cron

  @spec heartbeat(String.t()) :: :ok
  @deprecated "Use `Appsignal.CheckIn.cron/1` instead."
  defdelegate heartbeat(name), to: CheckIn, as: :cron

  @spec heartbeat(String.t(), (-> out)) :: out when out: var
  @deprecated "Use `Appsignal.CheckIn.cron/2` instead."
  defdelegate heartbeat(name, fun), to: CheckIn, as: :cron
end
