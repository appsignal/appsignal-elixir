defmodule Appsignal.Absinthe do
  @tracer Application.compile_env(:appsignal, :appsignal_tracer, Appsignal.Tracer)
  @span Application.compile_env(:appsignal, :appsignal_span, Appsignal.Span)

  @moduledoc false

  def attach do
    if Appsignal.Dependencies.match?(:absinthe, ">= 1.6.0"), do: attach_handlers(), else: []
  end

  defp attach_handlers do
    handlers = %{
      [:absinthe, :execute, :operation, :start] => &__MODULE__.absinthe_execute_operation_start/4,
      [:absinthe, :execute, :operation, :stop] => &__MODULE__.absinthe_execute_operation_stop/4
    }

    Appsignal.Telemetry.attach(__MODULE__, handlers)
  end

  def absinthe_execute_operation_start(_event, _measurements, metadata, _config) do
    operation_name = metadata[:options][:operation_name]

    "graphql"
    |> @tracer.create_span(@tracer.current_span())
    |> then(&Appsignal.Telemetry.put_span(__MODULE__, metadata, &1))
    |> @span.set_name(operation_name || "graphql")
    |> @span.set_attribute("appsignal:category", "call.graphql")

    root_span = @tracer.root_span()

    root_span
    |> @span.set_namespace_if_nil("graphql")

    if operation_name do
      root_span
      |> @span.set_name_if_nil(operation_name)
    end
  end

  def absinthe_execute_operation_stop(_event, _measurements, metadata, _config) do
    __MODULE__ |> Appsignal.Telemetry.take_span(metadata) |> @tracer.close_all()
  end
end
