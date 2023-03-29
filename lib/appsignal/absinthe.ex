defmodule Appsignal.Absinthe do
  require Appsignal.Utils

  @tracer Appsignal.Utils.compile_env(:appsignal, :appsignal_tracer, Appsignal.Tracer)
  @span Appsignal.Utils.compile_env(:appsignal, :appsignal_span, Appsignal.Span)

  @moduledoc false

  require Logger

  def attach do
    handlers = %{
      [:absinthe, :execute, :operation, :start] => &__MODULE__.absinthe_execute_operation_start/4,
      [:absinthe, :execute, :operation, :stop] => &__MODULE__.absinthe_execute_operation_stop/4
    }

    for {event, fun} <- handlers do
      detach = :telemetry.detach({__MODULE__, event})
      attach = :telemetry.attach({__MODULE__, event}, event, fun, :ok)

      case {detach, attach} do
        {:ok, :ok} ->
          _ =
            Appsignal.IntegrationLogger.debug(
              "Appsignal.Absinthe reattached to #{inspect(event)}"
            )

          :ok

        {{:error, :not_found}, :ok} ->
          _ =
            Appsignal.IntegrationLogger.debug("Appsignal.Absinthe attached to #{inspect(event)}")

          :ok

        {_, {:error, _} = error} ->
          Logger.warn("Appsignal.Absinthe not attached to #{inspect(event)}: #{inspect(error)}")

          error
      end
    end
  end

  def absinthe_execute_operation_start(_event, _measurements, _metadata, _config) do
    @tracer.create_span("absinthe")
    |> @span.set_name("graphql")
    |> @span.set_attribute("appsignal:category", "call.graphql")
  end

  def absinthe_execute_operation_stop(_event, _measurements, _metadata, _config) do
    @tracer.close_span(@tracer.current_span())
  end
end
