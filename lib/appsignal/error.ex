defmodule Appsignal.Error do
  def metadata(:error, reason, stack) do
    {
      inspect(reason.__struct__),
      Exception.format_banner(:error, reason, stack),
      Appsignal.Stacktrace.format(stack)
    }
  end
end
