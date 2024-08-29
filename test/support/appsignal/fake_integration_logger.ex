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

  def logged?(pid_or_module \\ __MODULE__, type, message)

  def logged?(pid_or_module, type, message) when is_binary(message) do
    logged?(pid_or_module, type, &(&1 == message))
  end

  def logged?(pid_or_module, type, matcher) when is_function(matcher) do
    Enum.any?(get(pid_or_module, :logs), fn [logged_type, logged_message] ->
      type == logged_type && matcher.(logged_message)
    end)
  end

  def get_logs(pid_or_module \\ __MODULE__, type) do
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
