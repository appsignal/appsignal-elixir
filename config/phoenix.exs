import Config

# The Phoenix application the tests run requests through, when the dependency
# set includes Phoenix.
for endpoint <- [
      AppsignalTest.Phoenix.MountingEndpoint,
      AppsignalTest.Phoenix.Endpoint,
      AppsignalTest.Phoenix.BanditEndpoint,
      AppsignalTest.Phoenix.CowboyEndpoint
    ] do
  config :appsignal, endpoint,
    # Plug's cookie session store needs at least 64 bytes.
    secret_key_base: "0000000000000000000000000000000000000000000000000000000000000000",
    live_view: [signing_salt: "appsignal"],
    pubsub_server: AppsignalTest.Phoenix.PubSub,
    render_errors: [formats: [html: AppsignalTest.Phoenix.ErrorHTML], layout: false],
    server: false
end

config :appsignal, AppsignalTest.Phoenix.BanditEndpoint,
  adapter: Bandit.PhoenixAdapter,
  http: [ip: {127, 0, 0, 1}, port: 0],
  server: true

config :appsignal, AppsignalTest.Phoenix.CowboyEndpoint,
  http: [ip: {127, 0, 0, 1}, port: 0],
  server: true

config :phoenix, :json_library, Jason
