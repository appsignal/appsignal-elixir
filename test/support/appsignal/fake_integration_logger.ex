defmodule Appsignal.FakeIntegrationLogger do
  use TestAgent, %{
    logs: []
  }

  def trace(message) do
    add(:logs, [:trace, message])
  end

  def debug(message) do
    add(:logs, [:debug, message])
  end

  def info(message) do
    add(:logs, [:info, message])
  end

  def warn(message) do
    add(:logs, [:warn, message])
  end

  def error(message) do
    add(:logs, [:error, message])
  end

  def logged?(pid_or_module, type, message) do
    Enum.any?(get(pid_or_module, :logs), fn element ->
      match?([^type, ^message], element)
    end)
  end

  def get_logs(pid_or_module, type) do
    Enum.filter(get(pid_or_module, :logs), fn element ->
      match?([^type, _], element)
    end)
  end

  def clear do
    Agent.cast(__MODULE__, fn state ->
      Map.update!(state, :logs, fn _ -> [] end)
    end)
  end

  defp add(key, event) do
    Agent.cast(__MODULE__, fn state ->
      Map.update!(state, key, fn current -> [event | current] end)
    end)
  end
end
