defmodule Appsignal.Phoenix.Channel do
  defmacro instrument(name, fun) do
    %{module: module} = __CALLER__

    quote do
      Appsignal.instrument(
        "#{Appsignal.Utils.module_name(unquote(module))}##{unquote(name)}",
        unquote(fun)
      )
    end
  end
end
