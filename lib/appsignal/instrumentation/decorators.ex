defmodule Appsignal.Instrumentation.Decorators do
  @moduledoc false
  @span Application.get_env(:appsignal, :appsignal_span, Appsignal.Span)

  use Decorator.Define,
    instrument: 0,
    instrument: 1,
    transaction: 0,
    transaction: 1,
    transaction_event: 0,
    transaction_event: 1,
    channel_action: 0

  import Appsignal.Utils, only: [module_name: 1]

  def instrument(namespace, body, context) when is_atom(namespace) do
    namespace
    |> Atom.to_string()
    |> instrument(body, context)
  end

  def instrument(namespace, body, %{module: module, name: name, arity: arity})
      when is_binary(namespace) do
    quote do
      Appsignal.instrument(
        "#{module_name(unquote(module))}.#{unquote(name)}/#{unquote(arity)}",
        fn span ->
          unquote(@span).set_namespace(span, unquote(namespace))
          unquote(body)
        end
      )
    end
  end

  def instrument(body, %{module: module, name: name, arity: arity}) do
    quote do
      Appsignal.instrument(
        "#{module_name(unquote(module))}.#{unquote(name)}/#{unquote(arity)}",
        fn -> unquote(body) end
      )
    end
  end

  def instrument(body, %{module: module, name: name}) do
    quote do
      Appsignal.instrument(
        "#{module_name(unquote(module))}.#{unquote(name)}",
        fn -> unquote(body) end
      )
    end
  end

  def transaction(body, context) do
    instrument(body, context)
  end

  def transaction(namespace, body, context) do
    instrument(namespace, body, context)
  end

  def transaction_event(body, context) do
    instrument(body, context)
  end

  def transaction_event(_category, body, context) do
    instrument(body, context)
  end

  def channel_action(body, %{module: module, args: [action, _payload, _socket]}) do
    instrument(body, %{module: module, name: action})
  end
end
