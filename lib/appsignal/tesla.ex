defmodule Appsignal.Tesla do
  require Logger

  @tracer Application.compile_env(:appsignal, :appsignal_tracer, Appsignal.Tracer)
  @span Application.compile_env(:appsignal, :appsignal_span, Appsignal.Span)

  @moduledoc false

  def attach do
    handlers = %{
      [:tesla, :request, :start] => &__MODULE__.tesla_request_start/4,
      [:tesla, :request, :stop] => &__MODULE__.tesla_request_stop/4,
      [:tesla, :request, :exception] => &__MODULE__.tesla_request_stop/4
    }

    for {event, fun} <- handlers do
      case :telemetry.attach({__MODULE__, event}, event, fun, :ok) do
        :ok ->
          _ = Appsignal.IntegrationLogger.debug("Appsignal.Tesla attached to #{inspect(event)}")

          :ok

        {:error, _} = error ->
          Logger.warning("Appsignal.Tesla not attached to #{inspect(event)}: #{inspect(error)}")

          error
      end
    end
  end

  def tesla_request_start(
        _event,
        _measurements,
        %{env: env},
        _config
      ) do
    do_tesla_request_start(@tracer.current_span(), env)
  end

  defp do_tesla_request_start(nil, _env), do: nil

  defp do_tesla_request_start(parent, env) do
    %{method: method, url: url} = env

    middlewares = env_middlewares(env)
    base_url = middleware_base_url(middlewares)
    use_full_path = path_params?(middlewares)

    sanitised_url = sanitise_url(url, base_url, use_full_path)

    upcased_method = String.upcase(Atom.to_string(method))

    name = "#{upcased_method} #{sanitised_url}"

    "http_request"
    |> @tracer.create_span(parent)
    |> @span.set_name(name)
    |> @span.set_attribute("appsignal:category", "request.tesla")
  end

  # Sanitises an URL by keeping only its scheme, host and port.
  #
  # The `use_full_path` parameter is set to true for enhanced grouping
  # when `Tesla.Middleware.PathParams` is present.
  #
  # If the URL does not contain a host, and a base URL is provided by
  # `Tesla.Middleware.BaseUrl`, then the base URL's scheme, host,
  # port and path are used instead.
  def sanitise_url(url, base_url, use_full_path) do
    do_sanitise_url(URI.parse(url || ""), URI.parse(base_url || ""), use_full_path)
  end

  # Users can specify a host in the request's URL, which overrides the
  # base URL in the BaseURL middleware. Only use the base URL if the URL
  # in the telemetry event does not already have a host.
  #
  # When using the base URL, its path fragment will be used, regardless
  # of the value of `use_full_path`.
  #
  # If `use_full_path` is true, then the path fragments of the base URL
  # and the URL are concatenated together.
  defp do_sanitise_url(%URI{host: nil, path: path}, base_uri, true) do
    do_sanitise_url(base_uri, "#{base_uri.path}#{path}")
  end

  defp do_sanitise_url(%URI{host: nil}, base_uri, _) do
    do_sanitise_url(base_uri, base_uri.path)
  end

  defp do_sanitise_url(uri, _, true) do
    do_sanitise_url(uri, uri.path)
  end

  defp do_sanitise_url(uri, _, _) do
    do_sanitise_url(uri, nil)
  end

  defp do_sanitise_url(%URI{scheme: scheme, host: host, port: port}, path) do
    URI.to_string(%URI{scheme: scheme, host: host, port: port, path: path})
  end

  def env_middlewares(env) do
    # Use the same middleware order implemented in `Tesla.prepare`, but ignore
    # `post` client middlewares, which are not relevant to our use case:
    # https://github.com/elixir-tesla/tesla/blob/9fbf221/lib/tesla.ex#L116-L120
    normalize_middlewares(client_pre_middlewares(env) ++ module_middlewares(env))
  end

  defp module_middlewares(env) do
    module = Map.get(env, :__module__)

    if module != nil and function_exported?(module, :__middleware__, 0) do
      module.__middleware__()
    end || []
  end

  defp client_pre_middlewares(env) do
    client = Map.get(env, :__client__)

    if client != nil do
      Map.get(client, :pre, [])
    end || []
  end

  defp normalize_middlewares(middlewares) do
    # The `Tesla.Env.runtime()` type obtained from the `__middleware__`
    # property in the module and the `pre` property in the client can
    # contain middlewares and adapters of different shapes. Keep only
    # module-based middlewares and their arguments, if any, using an
    # unified value shape.

    middlewares
    |> Enum.map(fn
      {:fn, _} -> nil
      {middleware, _, opts} -> {middleware, opts}
      {middleware, _} -> {middleware, nil}
      _ -> nil
    end)
    |> Enum.reject(&is_nil/1)
  end

  defp middleware_base_url(normalized_middlewares) do
    Enum.find_value(normalized_middlewares, fn {middleware, opts} ->
      if middleware == Tesla.Middleware.BaseUrl, do: List.first(opts)
    end)
  end

  def path_params?(normalized_middlewares) do
    path_params_position =
      middleware_position(normalized_middlewares, Tesla.Middleware.PathParams)

    telemetry_position = middleware_position(normalized_middlewares, Tesla.Middleware.Telemetry)

    # If the PathParams middleware appears before the Telemetry middleware,
    # the URL in the telemetry event will already have the parameter values
    # interpolated into it, and therefore it cannot be used for grouping.
    path_params_position && telemetry_position < path_params_position
  end

  defp middleware_position(normalized_middlewares, expected_middleware) do
    Enum.find_index(normalized_middlewares, fn {middleware, _opts} ->
      middleware == expected_middleware
    end)
  end

  def tesla_request_stop(_event, _measurements, _metadata, _config) do
    @tracer.close_span(@tracer.current_span())
  end
end
