defmodule Appsignal.Instrumentation.Decorators do
  use Decorator.Define, instrument: 0
  import Appsignal.Utils, only: [module_name: 1]

  def instrument(body, %{module: module, name: name, arity: arity}) do
    quote do
      Appsignal.instrument(
        "#{module_name(unquote(module))}.#{unquote(name)}/#{unquote(arity)}",
        fn -> unquote(body) end
      )
    end
  end
end
