defmodule Appsignal.Stacktrace do
  if Version.compare(System.version(), "1.7.0") == :lt do
    defmacro get do
      quote do
        :erlang.get_stacktrace()
      end
    end
  else
    defmacro get do
      quote do
        __STACKTRACE__
      end
    end
  end
end
