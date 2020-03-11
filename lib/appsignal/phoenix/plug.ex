defmodule Appsignal.Phoenix.Plug do
  defmacro __using__(_) do
    IO.warn("Appsignal.Phoenix.Plug is deprecated. Use Appsignal.Plug instead.")

    quote do
      use Appsignal.Plug
    end
  end

  @deprecated "Use Appsignal.Error.metadata/1 instead."
  def extract_error_metadata(reason, conn, _stack) do
    {exception, stack} = Appsignal.Error.normalize(reason, [])
    {name, message} = Appsignal.Error.metadata(exception)
    {name, message, stack, conn}
  end
end
