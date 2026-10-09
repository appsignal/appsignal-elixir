defmodule Appsignal.HTTPoison.Base do
  @moduledoc false

  @httpoison_base Application.compile_env(
                    :appsignal,
                    :appsignal_httpoison_base,
                    Elixir.HTTPoison.Base
                  )
  @tracer Application.compile_env(:appsignal, :appsignal_tracer, Appsignal.Tracer)
  @span Application.compile_env(:appsignal, :appsignal_span, Appsignal.Span)

  defmacro __using__(opts) do
    httpoison_base = @httpoison_base

    quote do
      use unquote(httpoison_base), unquote(opts)

      def request(method, url, body, headers, options) do
        Appsignal.HTTPoison.Base.instrument(method, url, fn ->
          super(method, url, body, headers, options)
        end)
      end

      defoverridable request: 5
    end
  end

  @doc false
  def instrument(method, url, fun) do
    case @tracer.current_span() do
      nil ->
        fun.()

      parent ->
        %URI{scheme: scheme, host: host, port: port} = URI.parse(url)
        sanitized_url = to_string(%URI{scheme: scheme, host: host, port: port})
        method_string = method |> to_string() |> String.upcase()

        span =
          "http_request"
          |> @tracer.create_span(parent)
          |> @span.set_name("#{method_string} #{sanitized_url}")
          |> @span.set_attribute("appsignal:category", "request.httpoison")

        try do
          fun.()
        after
          @tracer.close_span(span)
        end
    end
  end
end

defmodule Appsignal.HTTPoison do
  @moduledoc false
  unless Code.ensure_loaded?(HTTPoison), do: @compile({:no_warn_undefined, HTTPoison})

  @httpoison Application.compile_env(:appsignal, :appsignal_httpoison, HTTPoison)

  defdelegate request(request), to: HTTPoison

  def request(method, url, body \\ "", headers \\ [], options \\ []) do
    Appsignal.HTTPoison.Base.instrument(method, url, fn ->
      @httpoison.request(method, url, body, headers, options)
    end)
  end

  defdelegate request!(request), to: HTTPoison

  def request!(method, url, body \\ "", headers \\ [], options \\ []) do
    Appsignal.HTTPoison.Base.instrument(method, url, fn ->
      @httpoison.request!(method, url, body, headers, options)
    end)
  end

  def get(url, headers \\ [], options \\ []) do
    request(:get, url, "", headers, options)
  end

  def get!(url, headers \\ [], options \\ []) do
    request!(:get, url, "", headers, options)
  end

  def head(url, headers \\ [], options \\ []) do
    request(:head, url, "", headers, options)
  end

  def head!(url, headers \\ [], options \\ []) do
    request!(:head, url, "", headers, options)
  end

  def delete(url, headers \\ [], options \\ []) do
    request(:delete, url, "", headers, options)
  end

  def delete!(url, headers \\ [], options \\ []) do
    request!(:delete, url, "", headers, options)
  end

  def options(url, headers \\ [], options \\ []) do
    request(:options, url, "", headers, options)
  end

  def options!(url, headers \\ [], options \\ []) do
    request!(:options, url, "", headers, options)
  end

  def put(url, body \\ "", headers \\ [], options \\ []) do
    request(:put, url, body, headers, options)
  end

  def put!(url, body \\ "", headers \\ [], options \\ []) do
    request!(:put, url, body, headers, options)
  end

  def post(url, body, headers \\ [], options \\ []) do
    request(:post, url, body, headers, options)
  end

  def post!(url, body, headers \\ [], options \\ []) do
    request!(:post, url, body, headers, options)
  end

  def patch(url, body, headers \\ [], options \\ []) do
    request(:patch, url, body, headers, options)
  end

  def patch!(url, body, headers \\ [], options \\ []) do
    request!(:patch, url, body, headers, options)
  end

  defdelegate start(), to: HTTPoison
  defdelegate stream_next(response), to: HTTPoison
  defdelegate transformer(target), to: HTTPoison

  @deprecated "Use process_response_headers/1 instead"
  def process_headers(headers), do: call_deprecated(:process_headers, [headers])

  defdelegate process_request_body(body), to: HTTPoison
  defdelegate process_request_headers(headers), to: HTTPoison
  defdelegate process_request_options(options), to: HTTPoison
  defdelegate process_request_params(params), to: HTTPoison
  defdelegate process_request_url(url), to: HTTPoison
  defdelegate process_response(response), to: HTTPoison
  defdelegate process_response_body(body), to: HTTPoison
  defdelegate process_response_chunk(chunk), to: HTTPoison
  defdelegate process_response_headers(headers), to: HTTPoison
  defdelegate process_response_status_code(status_code), to: HTTPoison

  @deprecated "Use process_response_status_code/1 instead"
  def process_status_code(status_code), do: call_deprecated(:process_status_code, [status_code])

  @deprecated "Use process_request_url/1 instead"
  def process_url(url), do: call_deprecated(:process_url, [url])

  # HTTPoison deprecates these hooks. A dynamic call keeps the compiler from
  # warning about the deprecation here; `@deprecated` passes it on to callers.
  defp call_deprecated(function, args), do: apply(HTTPoison, function, args)
end
