defmodule Appsignal.Utils.LoggerHandler do
  @moduledoc false

  # Compatibility layer for Logger backend functions that were moved to LoggerBackends in Elixir 1.15+

  if Code.ensure_loaded?(LoggerBackends) do
    def add_backend(backend, opts \\ []) do
      LoggerBackends.add(backend, opts)
    end

    def remove_backend(backend, opts \\ []) do
      LoggerBackends.remove(backend, opts)
    end
  else
    def add_backend(backend, _opts \\ []) do
      Logger.add_backend(backend)
    end

    def remove_backend(backend, _opts \\ []) do
      Logger.remove_backend(backend)
    end
  end
end
