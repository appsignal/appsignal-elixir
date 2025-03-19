defmodule Mix.Tasks.Appsignal.CheckInstall do
  use Mix.Task

  def run(_) do
    Application.ensure_all_started(:appsignal)

    if Appsignal.Nif.loaded?() do
      IO.puts("The AppSignal NIF was successfully installed and loaded.")
    else
      IO.puts(
        "AppSignal failed to load the extension. Please run the diagnose tool and email us at support@appsignal.com: https://docs.appsignal.com/elixir/command-line/diagnose.html"
      )

      exit({:shutdown, 1})
    end
  end
end
