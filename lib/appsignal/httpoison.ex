defmodule Appsignal.HTTPoison.Base do
  @moduledoc false

  @httpoison_base Application.compile_env(
                    :appsignal,
                    :appsignal_httpoison_base,
                    Elixir.HTTPoison.Base
                  )

  defmacro __using__(opts) do
    httpoison_base = @httpoison_base

    quote do
      use unquote(httpoison_base), unquote(opts)

      @tracer Application.compile_env(:appsignal, :appsignal_tracer, Appsignal.Tracer)
      @span Application.compile_env(:appsignal, :appsignal_span, Appsignal.Span)

      def request(method, url, body, headers, options) do
        parent = @tracer.current_span()

        span =
          if parent do
            %URI{scheme: scheme, host: host, port: port} = URI.parse(url)
            sanitized_url = URI.to_string(%URI{scheme: scheme, host: host, port: port})
            method_string = method |> to_string() |> String.upcase()

            "http_request"
            |> @tracer.create_span(parent)
            |> @span.set_name("#{method_string} #{sanitized_url}")
            |> @span.set_attribute("appsignal:category", "request.httpoison")
          end

        try do
          super(method, url, body, headers, options)
        after
          if span, do: @tracer.close_span(span)
        end
      end

      defoverridable request: 5
    end
  end
end

# Only define Appsignal.HTTPoison when HTTPoison is available.
# This allows the library to compile cleanly for users who have not installed HTTPoison.
httpoison_base =
  Application.compile_env(:appsignal, :appsignal_httpoison_base, Elixir.HTTPoison.Base)

case Code.ensure_compiled(httpoison_base) do
  {:module, _} ->
    defmodule Appsignal.HTTPoison do
      @moduledoc false
      use Appsignal.HTTPoison.Base
    end

  {:error, _} ->
    # Don't define Appsignal.HTTPoison if the base module isn't available.
    :ok
end
