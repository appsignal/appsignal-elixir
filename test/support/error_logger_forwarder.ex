defmodule ErrorLoggerForwarder do
  def init(pid) do
    {:ok, pid}
  end

  def handle_event(event, pid) do
    send(pid, event)
    {:ok, pid}
  end

  def handle_info(_, state) do
    {:ok, state}
  end
end
