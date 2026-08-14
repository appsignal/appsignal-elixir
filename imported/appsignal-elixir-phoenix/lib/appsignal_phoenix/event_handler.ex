defmodule Appsignal.Phoenix.EventHandler do
  @tracer Application.compile_env(:appsignal, :appsignal_tracer, Appsignal.Tracer)
  @span Application.compile_env(:appsignal, :appsignal_span, Appsignal.Span)
  @moduledoc false

  require Logger

  # Each start handler remembers the span it created, so that its stop handler
  # closes that span rather than whichever span happens to be the current one.
  # Anything else opening a span in between, such as a call to
  # `Appsignal.instrument/2`, would otherwise shift which span gets closed.
  #
  # These are stacks because `Phoenix.Router.forward` re-enters the router, so
  # the router dispatch events nest.
  @endpoint_key {__MODULE__, :endpoint_spans}
  @dispatch_key {__MODULE__, :router_dispatch_spans}
  @render_key {__MODULE__, :render_spans}
  @route_key {__MODULE__, :route}
  @root_span_data_key {__MODULE__, :root_span_data_set}

  def attach do
    handlers = %{
      [:phoenix, :endpoint, :start] => &__MODULE__.phoenix_endpoint_start/4,
      [:phoenix, :endpoint, :stop] => &__MODULE__.phoenix_endpoint_stop/4,
      [:phoenix, :router_dispatch, :start] => &__MODULE__.phoenix_router_dispatch_start/4,
      [:phoenix, :router_dispatch, :stop] => &__MODULE__.phoenix_router_dispatch_stop/4,
      [:phoenix, :router_dispatch, :exception] => &__MODULE__.phoenix_router_dispatch_exception/4,
      [:phoenix, :controller, :render, :start] => &__MODULE__.phoenix_template_render_start/4,
      [:phoenix, :controller, :render, :stop] => &__MODULE__.phoenix_template_render_stop/4,
      [:phoenix, :controller, :render, :exception] => &__MODULE__.phoenix_template_render_stop/4
    }

    for {event, fun} <- handlers do
      case :telemetry.attach({__MODULE__, event}, event, fun, :ok) do
        :ok ->
          _ =
            Appsignal.IntegrationLogger.debug(
              "Appsignal.Phoenix.EventHandler attached to #{inspect(event)}"
            )

          :ok

        {:error, _} = error ->
          Logger.warning(
            "Appsignal.Phoenix.EventHandler not attached to #{inspect(event)}: #{inspect(error)}"
          )

          error
      end
    end
  end

  def phoenix_endpoint_start(_event, _measurements, _metadata, _config) do
    start_request()

    parent = @tracer.current_span()

    "http_request"
    |> @tracer.create_span(parent)
    |> @span.set_attribute("appsignal:category", "call.phoenix_endpoint")
    |> push(@endpoint_key)
  end

  def phoenix_endpoint_stop(_event, _measurements, metadata, _config) do
    span = pop(@endpoint_key)

    # This event fires from a `register_before_send` callback, so it arrives
    # before the router dispatch stop event does. The root span has to be
    # described here, because it is closed below and cannot be described
    # afterwards.
    _ = Process.put(@root_span_data_key, true)
    _root_span = set_span_data(@tracer.root_span(), with_route(metadata))

    @tracer.close_span(span)
  end

  def phoenix_router_dispatch_start(_event, _measurements, metadata, _config) do
    # A Phoenix router can be dispatched to without a Phoenix endpoint, for
    # example when a Plug application forwards to one. There is no endpoint
    # start event to begin the request then, so this handler begins it instead.
    start_request()

    # The endpoint stop event does not carry the route, and it arrives before
    # the router dispatch stop event that does. Remember the route so that the
    # endpoint stop handler can still fall back to naming the span after it.
    _ = put_route(metadata)

    parent = @tracer.current_span()

    "http_request"
    |> @tracer.create_span(parent)
    |> @span.set_attribute("appsignal:category", "call.phoenix_router_dispatch")
    |> push(@dispatch_key)
  end

  def phoenix_router_dispatch_stop(_event, _measurements, metadata, _config) do
    span = pop(@dispatch_key)

    # A Phoenix router can be dispatched to without a Phoenix endpoint, for
    # example when a Plug application forwards to one. There is no endpoint stop
    # event to describe the root span then, so this handler does it instead.
    _root_span = set_root_span_data_unless_set(metadata)

    @tracer.close_span(span)
  end

  def phoenix_router_dispatch_exception(
        _event,
        _measurements,
        %{reason: %Plug.Conn.WrapperError{conn: conn, reason: reason, stack: stack}},
        _config
      ) do
    add_error(@tracer.root_span(), conn, reason, stack)
  end

  def phoenix_router_dispatch_exception(
        _event,
        _measurements,
        %{conn: conn, reason: reason, stacktrace: stack},
        _config
      ) do
    add_error(@tracer.root_span(), conn, reason, stack)
  end

  defp add_error(
         span,
         conn,
         %Phoenix.ActionClauseError{module: module, function: function} = reason,
         stack
       ) do
    span
    |> @span.set_name_if_nil("#{module}##{function}")
    |> do_add_error(conn, reason, stack)
  end

  defp add_error(span, conn, reason, stack), do: do_add_error(span, conn, reason, stack)

  defp do_add_error(span, conn, reason, stack) do
    span
    |> @span.add_error(:error, reason, stack)
    |> set_span_data(%{conn: conn})
    |> @tracer.close_span()

    # No stop event arrives for the spans this request opened, so nothing else
    # will take them off the stacks. On a web server that serves more than one
    # request per process, such as Bandit, they would pile up.
    forget()

    @tracer.ignore()
  end

  def phoenix_template_render_start(_event, _measurements, metadata, _config) do
    parent = @tracer.current_span()

    _ =
      @span.set_sample_data_if_nil(@tracer.root_span(), "tags", %{
        "phoenix_template" => metadata.template,
        "phoenix_format" => metadata.format,
        "phoenix_view" => module_name(metadata.view)
      })

    "http_request"
    |> @tracer.create_span(parent)
    |> @span.set_name(
      "Render #{inspect(metadata.template)} (#{metadata.format}) template from #{module_name(metadata.view)}"
    )
    |> @span.set_attribute("appsignal:category", "render.phoenix_template")
    |> push(@render_key)
  end

  def phoenix_template_render_stop(_event, _measurements, _metadata, _config) do
    @tracer.close_span(pop(@render_key))
  end

  defp set_span_data(span, %{conn: conn} = metadata) do
    appsignal_metadata = Appsignal.Metadata.metadata(conn)

    span
    |> @span.set_name_if_nil(name(metadata))
    |> @span.set_sample_data_if_nil("params", Appsignal.Metadata.params(conn))
    |> @span.set_sample_data_if_nil("environment", appsignal_metadata)
    |> @span.set_sample_data_if_nil("session_data", Appsignal.Metadata.session(conn))
    |> @span.set_sample_data("metadata", %{
      "request_method" => appsignal_metadata["method"],
      "request_path" => appsignal_metadata["request_path"],
      "request_id" => appsignal_metadata["request_id"],
      "response_status" => appsignal_metadata["status"]
    })
  end

  defp name(%{conn: conn} = metadata) do
    Appsignal.Metadata.name(conn) || extract_name(metadata)
  end

  defp extract_name(%{conn: %{method: method}, route: route}) do
    "#{method} #{route}"
  end

  defp extract_name(_) do
    nil
  end

  defp module_name("Elixir." <> module), do: module
  defp module_name(module) when is_binary(module), do: module
  defp module_name(module), do: module |> to_string() |> module_name()

  # A request starting in this process takes over from whatever request ran in
  # it before. On a web server that serves more than one request per process,
  # such as Bandit, what the previous request left behind is still here, and
  # using any of it would describe this request with the last one's data.
  defp start_request do
    _ = Process.delete(@root_span_data_key)
    _ = Process.delete(@route_key)

    :ok
  end

  defp set_root_span_data_unless_set(metadata) do
    case Process.get(@root_span_data_key) do
      true ->
        nil

      _ ->
        _ = Process.put(@root_span_data_key, true)
        set_span_data(@tracer.root_span(), metadata)
    end
  end

  defp put_route(%{route: route}) when is_binary(route) do
    _ = Process.put(@route_key, route)
  end

  defp put_route(_metadata), do: nil

  defp with_route(metadata) do
    case Process.get(@route_key) do
      nil -> metadata
      route -> Map.put_new(metadata, :route, route)
    end
  end

  defp push(span, key) do
    _ = Process.put(key, [span | Process.get(key, [])])
    span
  end

  # Returns `nil` when no span was pushed, which happens when AppSignal starts
  # in the middle of a request, or when the process is ignored. Deliberately
  # does not fall back to the current span: closing a span that this handler did
  # not open is the bug this bookkeeping exists to prevent.
  defp pop(key) do
    case Process.get(key, []) do
      [span | rest] ->
        _ = Process.put(key, rest)
        span

      [] ->
        nil
    end
  end

  defp forget do
    Enum.each(
      [@endpoint_key, @dispatch_key, @render_key, @route_key, @root_span_data_key],
      &Process.delete/1
    )
  end
end
