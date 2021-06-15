defmodule Appsignal.Error do
  @moduledoc false
  def metadata(%_{__exception__: true} = exception, stack) do
    banner = Exception.format_banner(:error, exception, stack)

    {
      name(banner, exception.__struct__),
      banner,
      Appsignal.Stacktrace.format(stack)
    }
  end

  def metadata(:error, reason, stack) do
    :error
    |> Exception.normalize(reason, stack)
    |> metadata(stack)
  end

  def metadata(kind, reason, stack) do
    banner = Exception.format_banner(kind, reason, stack)

    {
      name(banner, kind),
      banner,
      Appsignal.Stacktrace.format(stack)
    }
  end

  defp name(banner, type) do
    if String.contains?(banner, inspect(type)) do
      banner
    else
      type <> " " <> banner
    end
  end
end
