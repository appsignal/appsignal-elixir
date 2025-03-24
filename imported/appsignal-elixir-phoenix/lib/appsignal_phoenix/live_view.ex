defmodule Appsignal.Phoenix.LiveView do
  @tracer Application.compile_env(:appsignal, :appsignal_tracer, Appsignal.Tracer)
  @span Application.compile_env(:appsignal, :appsignal_span, Appsignal.Span)
  @os Application.compile_env(:appsignal_plug, :os, :os)

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
              |> @span.set_sample_data_if_nil("environment", Appsignal.Metadata.metadata(socket))
              |> @span.add_error(kind, reason, stack)

            @tracer.ignore()
            :erlang.raise(kind, reason, stack)
        else
          result ->
            _ =
              span
              |> @span.set_sample_data_if_nil("params", params)
              |> @span.set_sample_data_if_nil("environment", Appsignal.Metadata.metadata(socket))

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
    [
      [:phoenix, :live_view, :mount],
      [:phoenix, :live_view, :handle_params],
      [:phoenix, :live_view, :handle_event],
      [:phoenix, :live_view, :render],
      [:phoenix, :live_component, :handle_event],
      [:phoenix, :live_component, :update]
    ]
    |> Enum.each(fn event ->
      name = Enum.join(event, ".")

      _ =
        :telemetry.attach(
          {__MODULE__, event ++ [:start]},
          event ++ [:start],
          &__MODULE__.handle_event_start/4,
          name
        )

      _ =
        :telemetry.attach(
          {__MODULE__, event ++ [:stop]},
          event ++ [:stop],
          &__MODULE__.handle_event_stop/4,
          name
        )

      _ =
        :telemetry.attach(
          {__MODULE__, event ++ [:exception]},
          event ++ [:exception],
          &__MODULE__.handle_event_exception/4,
          name
        )
    end)
  end

  def handle_event_start(
        [:phoenix, _type, name, :start],
        %{system_time: system_time},
        metadata,
        _event_name
      ) do
    "live_view"
    |> @tracer.create_span(nil, start_time: system_time)
    |> @span.set_name("#{Appsignal.Utils.module_name(metadata[:socket].view)}##{name}")
    |> @span.set_attribute("appsignal:category", "#{name}.live_view")
    |> @span.set_attribute("event", metadata[:event])
    |> @span.set_sample_data("params", metadata[:params])
    |> @span.set_sample_data("session_data", metadata[:session])
  end

  def handle_event_stop(_event, _params, _metadata, _event_name) do
    @tracer.close_span(@tracer.current_span(), end_time: @os.system_time())
  end

  def handle_event_exception(_event, _params, metadata, _event_name) do
    @tracer.current_span()
    |> @span.add_error(metadata[:kind], metadata[:reason], metadata[:stacktrace])
    |> @tracer.close_span(end_time: @os.system_time())

    @tracer.ignore()
  end
end
