unless Code.ensure_loaded?(Appsignal.Phoenix) do
  defmodule Appsignal.Plug.NotAvailableError do
    @moduledoc false
    defexception []

    def message(_) do
      """
      Appsignal.Plug was used but not present in the project's dependencies.

      Since :appsignal 2.0, Appsignal's Phoenix integration was moved to a new library named :appsignal_plug. Please replace the project's dependency on :appsignal to depend on :appsignal_plug instead:

        defp deps do
          [
            {:appsignal_plug, "~> 2.0.0-alpha.1"}
          ]
        end
      """
    end
  end

  defmodule Appsignal.Plug do
    @moduledoc false

    def __using__(_) do
      raise Appsignal.Plug.NotAvailableError
    end
  end
end

unless Code.ensure_loaded?(Appsignal.Phoenix) do
  defmodule Appsignal.Phoenix.NotAvailableError do
    @moduledoc false
    defexception []

    def message(_) do
      """
      Appsignal.Phoenix was used but not present in the project's dependencies.

      Since :appsignal 2.0, Appsignal's Phoenix integration was moved to a new library named :appsignal_phoenix. Please replace the project's dependency on :appsignal to depend on :appsignal_phoenix instead:

        defp deps do
          [
            {:appsignal_phoenix, "~> 2.0.0-alpha.1"}
          ]
        end
      """
    end
  end

  defmodule Appsignal.Phoenix do
    @moduledoc false

    def __using__(_) do
      raise Appsignal.Phoenix.NotAvailableError
    end
  end
end
