import Config

if Mix.env() == :test do
  config :logger, level: :warning

  config :appsignal, appsignal_tracer: Appsignal.Test.Tracer
  config :appsignal, appsignal_span: Appsignal.Test.Span
  config :appsignal_plug, os: FakeOS

  config :appsignal, :config,
    push_api_key: "00000000-0000-0000-0000-000000000000",
    name: "appsignal-plug",
    env: "test",
    active: true
end
