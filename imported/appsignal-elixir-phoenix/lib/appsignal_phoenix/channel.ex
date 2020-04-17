defmodule Appsignal.Phoenix.Channel do
  @span Application.get_env(:appsignal, :appsignal_span, Appsignal.Span)

  def instrument(module, name, socket, fun) do
    instrument(module, name, %{}, socket, fun)
  end

  def instrument(module, name, params, socket, fun) do
    Appsignal.instrument(
      "#{Appsignal.Utils.module_name(module)}##{name}",
      fn span ->
        span
        |> unquote(@span).set_sample_data("params", params)
        |> Appsignal.Phoenix.Channel.set_sample_data(socket)

        fun.()
      end
    )
  end

  def set_sample_data(span, %Phoenix.Socket{
        id: id,
        channel: channel,
        endpoint: endpoint,
        handler: handler,
        ref: ref,
        topic: topic,
        transport: transport
      }) do
    @span.set_sample_data(span, "environment", %{
      "channel" => channel,
      "endpoint" => endpoint,
      "handler" => handler,
      "id" => id,
      "ref" => ref,
      "topic" => topic,
      "transport" => transport
    })
  end
end
