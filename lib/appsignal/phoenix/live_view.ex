defmodule Appsignal.Phoenix.LiveView do
  @tracer Application.compile_env(:appsignal, :appsignal_tracer, Appsignal.Tracer)
  @span Application.compile_env(:appsignal, :appsignal_span, Appsignal.Span)
  @os Application.compile_env(:appsignal, :os_internal, :os)

  def instrument(module, name, socket, fun) do
    instrument(module, name, %{}, socket, fun)
  end

  def instrument(module, name, params, socket, fun) do
    Appsignal.instrument(
      "#{Appsignal.Utils.module_name(module)}##{name}",
      fn span ->
        _ = @span.set_namespace(span, "live_view")

        try do
          fun.()
        catch
          kind, reason ->
            stack = __STACKTRACE__

            _ =
              span
              |> @span.set_sample_data_if_nil("params", params)
              |> @span.set_sample_data_if_nil(
                "environment",
                Appsignal.Metadata.metadata(socket)
              )
              |> @span.add_error(kind, reason, stack)

            :erlang.raise(kind, reason, stack)
        else
          result ->
            _ =
              span
              |> @span.set_sample_data_if_nil("params", params)
              |> @span.set_sample_data_if_nil(
                "environment",
                Appsignal.Metadata.metadata(socket)
              )

            result
        end
      end
    )
  end

  def live_view_action(module, name, socket, function) do
    instrument(module, name, socket, function)
  end

  def live_view_action(module, name, params, socket, function) do
    instrument(module, name, params, socket, function)
  end

  def attach do
    if Appsignal.Dependencies.match?(:phoenix_live_view, ">= 0.17.12"), do: attach_handlers()
    :ok
  end

  defp attach_handlers do
    handlers = %{
      [:phoenix, :live_view, :mount, :start] => &__MODULE__.handle_live_view_event_start/4,
      [:phoenix, :live_view, :handle_params, :start] =>
        &__MODULE__.handle_live_view_event_start/4,
      [:phoenix, :live_view, :handle_event, :start] => &__MODULE__.handle_live_view_event_start/4,
      [:phoenix, :live_view, :render, :start] => &__MODULE__.handle_live_view_event_start/4,
      [:phoenix, :live_component, :handle_event, :start] =>
        &__MODULE__.handle_live_component_event_start/4,
      [:phoenix, :live_component, :update, :start] =>
        &__MODULE__.handle_live_component_event_start/4,
      [:phoenix, :live_view, :mount, :stop] => &__MODULE__.handle_event_stop/4,
      [:phoenix, :live_view, :mount, :exception] => &__MODULE__.handle_event_exception/4,
      [:phoenix, :live_view, :handle_params, :stop] => &__MODULE__.handle_event_stop/4,
      [:phoenix, :live_view, :handle_params, :exception] => &__MODULE__.handle_event_exception/4,
      [:phoenix, :live_view, :handle_event, :stop] => &__MODULE__.handle_event_stop/4,
      [:phoenix, :live_view, :handle_event, :exception] => &__MODULE__.handle_event_exception/4,
      [:phoenix, :live_view, :render, :stop] => &__MODULE__.handle_event_stop/4,
      [:phoenix, :live_view, :render, :exception] => &__MODULE__.handle_event_exception/4,
      [:phoenix, :live_component, :handle_event, :stop] => &__MODULE__.handle_event_stop/4,
      [:phoenix, :live_component, :handle_event, :exception] =>
        &__MODULE__.handle_event_exception/4,
      [:phoenix, :live_component, :update, :stop] => &__MODULE__.handle_event_stop/4,
      [:phoenix, :live_component, :update, :exception] => &__MODULE__.handle_event_exception/4
    }

    Appsignal.Telemetry.attach(__MODULE__, handlers)
  end

  def handle_live_view_event_start(
        [:phoenix, :live_view, name, :start],
        %{system_time: system_time},
        metadata,
        _event_name
      ) do
    "live_view"
    |> @tracer.create_span(nil, start_time: system_time)
    |> @span.set_name(span_name(metadata[:socket].view, name, metadata[:event]))
    |> @span.set_attribute("appsignal:category", "#{name}.live_view")
    |> @span.set_attribute("event", metadata[:event])
    |> @span.set_sample_data("params", metadata[:params])
    |> @span.set_sample_data("session_data", metadata[:session])
    |> then(&Appsignal.Telemetry.put_span(__MODULE__, metadata, &1))
  end

  def handle_live_component_event_start(
        [:phoenix, :live_component, name, :start],
        %{system_time: system_time},
        metadata,
        _event_name
      ) do
    span =
      "live_view"
      |> @tracer.create_span(nil, start_time: system_time)
      |> @span.set_name(span_name(metadata[:component], name, metadata[:event]))
      |> @span.set_attribute("appsignal:category", "#{name}.live_component")
      |> @span.set_attribute("event", metadata[:event])
      |> @span.set_sample_data("params", metadata[:params])

    if metadata[:socket] && metadata[:socket].view do
      @span.set_attribute(span, "view", Appsignal.Utils.module_name(metadata[:socket].view))
    end

    Appsignal.Telemetry.put_span(__MODULE__, metadata, span)
  end

  def handle_event_stop(_event, _params, metadata, _event_name) do
    __MODULE__
    |> Appsignal.Telemetry.take_span(metadata)
    |> @tracer.close_all(end_time: @os.system_time())
  end

  def handle_event_exception(_event, _params, metadata, _event_name) do
    __MODULE__
    |> Appsignal.Telemetry.take_span(metadata)
    |> @span.add_error(metadata[:kind], metadata[:reason], metadata[:stacktrace])
    |> @tracer.close_all(end_time: @os.system_time())
  end

  defp span_name(module, method, nil) do
    "#{Appsignal.Utils.module_name(module)}##{method}"
  end

  defp span_name(module, method, event) do
    "#{Appsignal.Utils.module_name(module)}##{method} (#{event})"
  end
end
