defmodule Appsignal.Logger.Backend do
  @behaviour :gen_event

  def init({__MODULE__, options}) do
    {:ok, Keyword.merge([group: "app", format: :plaintext], options)}
  end

  def handle_event({level, _gl, {Logger, message, _timestamp, metadata}}, options) do
    Appsignal.Logger.log(
      level,
      options[:group],
      IO.chardata_to_string(message),
      Enum.into(metadata, %{}),
      options[:format]
    )

    {:ok, options}
  end

  def handle_event(_event, options) do
    {:ok, options}
  end

  def handle_call(_messsage, options) do
    {:ok, nil, options}
  end
end
