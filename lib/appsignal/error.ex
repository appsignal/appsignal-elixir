defmodule Appsignal.Error do
  @moduledoc false
  def metadata(%_{__exception__: true} = exception, stack) do
    {
      inspect(exception.__struct__),
      Exception.format_banner(:error, exception, stack),
      Appsignal.Stacktrace.format(stack)
    }
  end

  def metadata(:error, reason, stack) do
    :error
    |> Exception.normalize(reason, stack)
    |> metadata(stack)
  end

  def metadata(kind, reason, stack) do
    {
      inspect(kind),
      Exception.format_banner(kind, reason, stack),
      Appsignal.Stacktrace.format(stack)
    }
  end
end
