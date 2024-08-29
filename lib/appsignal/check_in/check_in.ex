defmodule Appsignal.CheckIn do
  alias Appsignal.CheckIn.Cron

  @spec cron(String.t()) :: :ok
  def cron(identifier) do
    Cron.finish(Cron.new(identifier))
  end

  @spec cron(String.t(), (-> out)) :: out when out: var
  def cron(identifier, fun) do
    cron = Cron.new(identifier)

    Cron.start(cron)
    output = fun.()
    Cron.finish(cron)

    output
  end
end
