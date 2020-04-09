defmodule Appsignal.Error do
  def metadata(:error, reason, stack) do
    exception = Exception.normalize(:error, reason, stack)

    {
      inspect(exception.__struct__),
      Exception.format_banner(:error, exception, stack),
      Appsignal.Stacktrace.format(stack)
    }
  end
end
