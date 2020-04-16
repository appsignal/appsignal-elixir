defmodule Appsignal.Phoenix.Channel do
  @span Application.get_env(:appsignal, :appsignal_span, Appsignal.Span)

  defmacro instrument(name, params, socket, fun) do
    %{module: module} = __CALLER__

    quote do
      Appsignal.instrument(
        "#{Appsignal.Utils.module_name(unquote(module))}##{unquote(name)}",
        fn span ->
          span
          |> unquote(@span).set_sample_data("params", unquote(params))
          |> Appsignal.Phoenix.Channel.set_sample_data(unquote(socket))

          unquote(fun).()
        end
      )
    end
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
