defmodule Appsignal.Instrumentation.Decorators do
  use Decorator.Define,
    transaction_event: 0,
    transaction_event: 1,
    channel_action: 0

  def transaction_event(category, body, context) do
    decorate_event(".#{category}", body, context)
  end

  def transaction_event(body, context) do
    decorate_event("", body, context)
  end

  defp decorate_event(postfix, body, context) do
    quote do
      Appsignal.Instrumentation.Helpers.instrument(
        self(),
        unquote("#{context.name}#{postfix}"),
        unquote("#{context.module}.#{context.name}"),
        fn -> unquote(body) end)
    end
  end


  def channel_action(body, context = %{args: [action, _payload, socket]}) do
    quote do
      Appsignal.Phoenix.Channel.channel_action(
        unquote(context.module),
        unquote(action),
        unquote(socket),
        fn -> unquote(body) end
      )
    end
  end

end
