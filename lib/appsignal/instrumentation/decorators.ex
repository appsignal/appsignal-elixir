defmodule Appsignal.Instrumentation.Decorators do
  @moduledoc """
  Instrumentation decorators

  This module contains various [function
  decorators](https://github.com/arjan/decorator) for instrumenting
  function calls.

  `@decorate transaction` - when a function decorated like this is
  called, a transaction is started in the `:http_request` namespace.

  `@decorate transaction(:background_job)` - when a function decorated
  like this is called, a transaction is started in the
  `:background_job` namespace.

  `@decorate transaction_event` - when a function decorated like this
  is called, it will add an event onto the transaction's timeline. The
  name of the event will be the name of the function that's decorated.

  `@decorate transaction_event(:category)` - when a function decorated
  like this is called, it will add an event onto the transaction's
  timeline. The name of the event will be the name of the function
  that's decorated. In addition, the event will be grouped into the
  given `:category`.

  `@decorate channel_action` - this decorator is meant to be put
  before the `handle_in/3` function of a Phoenix.Channel. See
  `Appsignal.Phoenix.Channel` for more information on how to
  instrument channel events.
  """

  use Decorator.Define,
    transaction: 0,
    transaction: 1,
    transaction_event: 0,
    transaction_event: 1,
    channel_action: 0

  @transaction Application.get_env(:appsignal, :appsignal_transaction, Appsignal.Transaction)

  @doc false
  def transaction(body, context) do
    transaction(:http_request, body, context)
  end

  @doc false
  def transaction(namespace, body, context) do
    quote do
      Appsignal.Instrumentation.Decorators.in_transaction(
        unquote(namespace),
        unquote("#{context.module}##{context.name}"),
        unquote(body)
      )
    end
  end

  @doc false
  def transaction_event(category, body, context) do
    decorate_event(".#{category}", body, context)
  end

  @doc false
  def transaction_event(body, context) do
    decorate_event("", body, context)
  end

  defp decorate_event(postfix, body, context) do
    quote do
      Appsignal.Instrumentation.Helpers.instrument(
        self(),
        unquote("#{context.name}#{postfix}"),
        unquote("#{context.module}.#{context.name}"),
        fn -> unquote(body) end
      )
    end
  end

  @doc false
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

  @doc false
  def in_transaction(namespace, action, body) do
    transaction =
      @transaction.generate_id()
      |> @transaction.start(namespace)
      |> @transaction.set_action(action)

    result = body

    @transaction.finish(transaction)
    :ok = @transaction.complete(transaction)

    result
  end
end
