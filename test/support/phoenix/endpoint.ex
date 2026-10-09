if Appsignal.Dependencies.present?(:phoenix) do
  defmodule AppsignalTest.Phoenix.EndpointPlugs do
    @moduledoc false

    # What `mix phx.new` generates, for the parts the instrumentation sees.
    defmacro __using__(_opts) do
      quote do
        @session_options [store: :cookie, key: "_appsignal_key", signing_salt: "appsignal"]

        plug(:halt_before_router)
        plug(Plug.RequestId)
        plug(Plug.Telemetry, event_prefix: [:phoenix, :endpoint])

        plug(Plug.Parsers,
          parsers: [:urlencoded, :multipart, :json],
          pass: ["*/*"],
          json_decoder: Jason
        )

        plug(Plug.MethodOverride)
        plug(Plug.Head)
        plug(Plug.Session, @session_options)
        plug(:raise_before_router)
        plug(AppsignalTest.Phoenix.Router)

        defp halt_before_router(%Plug.Conn{path_info: ["halt_in_endpoint"]} = conn, _opts) do
          conn
          |> Plug.Conn.send_resp(403, "Forbidden")
          |> Plug.Conn.halt()
        end

        defp halt_before_router(conn, _opts), do: conn

        defp raise_before_router(%Plug.Conn{path_info: ["raise_in_endpoint"]}, _opts) do
          raise "Exception in the endpoint!"
        end

        defp raise_before_router(conn, _opts), do: conn
      end
    end
  end

  for endpoint <- [
        AppsignalTest.Phoenix.Endpoint,
        AppsignalTest.Phoenix.BanditEndpoint,
        AppsignalTest.Phoenix.CowboyEndpoint
      ] do
    defmodule endpoint do
      @moduledoc false
      use Phoenix.Endpoint, otp_app: :appsignal
      use AppsignalTest.Phoenix.EndpointPlugs
    end
  end

  # An endpoint that mounts the application's endpoint as a plug, as an
  # application that serves another Phoenix application from its own does.
  defmodule AppsignalTest.Phoenix.MountingEndpoint do
    @moduledoc false
    use Phoenix.Endpoint, otp_app: :appsignal

    plug(Plug.Telemetry, event_prefix: [:phoenix, :endpoint])
    plug(AppsignalTest.Phoenix.Endpoint)
  end
end
