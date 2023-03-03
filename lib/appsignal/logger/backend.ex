defmodule Appsignal.Logger.Backend do
  @behaviour :gen_event

  def init({__MODULE__, group}) do
    {:ok, group}
  end

  def init(_) do
    {:ok, "app"}
  end

  def handle_event({level, _gl, {Logger, message, _timestamp, metadata}}, group) do
    Appsignal.Logger.log(level, group, IO.chardata_to_string(message), Enum.into(metadata, %{}))
    {:ok, group}
  end

  def handle_call(_messsage, group) do
    {:ok, nil, group}
  end
end
