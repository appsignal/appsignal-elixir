defmodule Appsignal.Phoenix.Channel do
  @tracer Application.get_env(:appsignal, :appsignal_tracer, Appsignal.Tracer)
  @span Application.get_env(:appsignal, :appsignal_span, Appsignal.Span)

  def instrument(module, name, socket, fun) do
    instrument(module, name, %{}, socket, fun)
  end

  def instrument(module, name, params, socket, fun) do
    Appsignal.instrument(
      "#{Appsignal.Utils.module_name(module)}##{name}",
      fn span ->
        try do
          fun.()
        catch
          kind, reason ->
            stack = __STACKTRACE__

            span
            |> @span.set_sample_data("params", params)
            |> Appsignal.Phoenix.Channel.set_sample_data(socket)
            |> @span.add_error(kind, reason, stack)
            |> @tracer.close_span()

            @tracer.ignore()
            :erlang.raise(kind, reason, stack)
        else
          result ->
            span
            |> @span.set_sample_data("params", params)
            |> Appsignal.Phoenix.Channel.set_sample_data(socket)

            result
        end
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
