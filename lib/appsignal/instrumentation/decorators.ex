defmodule Appsignal.Instrumentation.Decorators do
  @moduledoc false

  @span Application.compile_env(:appsignal, :appsignal_span, Appsignal.Span)

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

  def instrument(namespace, body, context) when is_binary(namespace) do
    do_instrument(body, Map.put(context, :namespace, namespace))
  end

  def instrument(body, context) do
    do_instrument(body, context)
  end

  defp do_instrument(body, %{module: module, name: name, arity: arity, namespace: namespace}) do
    quote do
      Appsignal.Instrumentation.instrument(
        "#{module_name(unquote(module))}.#{unquote(name)}_#{unquote(arity)}",
        fn span ->
          _ = unquote(@span).set_namespace(span, unquote(namespace))
          unquote(body)
        end
      )
    end
  end

  defp do_instrument(body, %{module: module, name: name, namespace: namespace}) do
    quote do
      Appsignal.Instrumentation.instrument(
        "#{module_name(unquote(module))}.#{unquote(name)}",
        fn span ->
          _ = unquote(@span).set_namespace(span, unquote(namespace))
          unquote(body)
        end
      )
    end
  end

  defp do_instrument(body, %{module: module, name: name, arity: arity, category: category}) do
    quote do
      Appsignal.Instrumentation.instrument(
        "#{module_name(unquote(module))}.#{unquote(name)}_#{unquote(arity)}",
        unquote(category),
        fn -> unquote(body) end
      )
    end
  end

  defp do_instrument(body, %{module: module, name: name, arity: arity}) do
    quote do
      Appsignal.Instrumentation.instrument(
        "#{module_name(unquote(module))}.#{unquote(name)}_#{unquote(arity)}",
        fn -> unquote(body) end
      )
    end
  end

  defp do_instrument(body, %{module: module, name: name}) do
    quote do
      Appsignal.Instrumentation.instrument(
        "#{module_name(unquote(module))}.#{unquote(name)}",
        fn -> unquote(body) end
      )
    end
  end

  def transaction(body, context) do
    transaction("background_job", body, context)
  end

  def transaction(namespace, body, context) when is_atom(namespace) do
    namespace
    |> Atom.to_string()
    |> transaction(body, context)
  end

  def transaction(namespace, body, %{module: module, name: name, arity: arity})
      when is_binary(namespace) do
    quote do
      Appsignal.Instrumentation.instrument_root(
        unquote(namespace),
        "#{module_name(unquote(module))}.#{unquote(name)}_#{unquote(arity)}",
        fn -> unquote(body) end
      )
    end
  end

  def transaction_event(body, context) do
    instrument(body, context)
  end

  def transaction_event(category, body, context) when is_atom(category) do
    category
    |> Atom.to_string()
    |> transaction_event(body, context)
  end

  def transaction_event(category, body, context) do
    do_instrument(body, Map.put(context, :category, category))
  end

  def channel_action(body, %{module: module, args: [action, _payload, _socket]}) do
    quote do
      Appsignal.Instrumentation.instrument_root(
        "channel",
        "#{module_name(unquote(module))}.#{unquote(action)}",
        fn -> unquote(body) end
      )
    end
  end
end
