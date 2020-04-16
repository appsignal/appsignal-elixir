defmodule Appsignal.Phoenix.Channel do
  @span Application.get_env(:appsignal, :appsignal_span, Appsignal.Span)

  defmacro instrument(name, params, fun) do
    %{module: module} = __CALLER__

    quote do
      Appsignal.instrument(
        "#{Appsignal.Utils.module_name(unquote(module))}##{unquote(name)}",
        fn span ->
          unquote(@span).set_sample_data(span, "params", unquote(params))
          unquote(fun).()
        end
      )
    end
  end
end
