use Mix.Config

if Mix.env() in [:bench, :test, :test_no_nif] do
  config :appsignal, appsignal_system: Appsignal.FakeSystem
  config :appsignal, appsignal_nif: Appsignal.FakeNif
  config :appsignal, appsignal_diagnose_report: Appsignal.Diagnose.FakeReport
  config :appsignal, appsignal: Appsignal.FakeAppsignal
  config :appsignal, inet: FakeInet

  config :appsignal, appsignal_tracer_nif: Appsignal.Test.Nif
  config :appsignal, appsignal_tracer: Appsignal.Test.Tracer
  config :appsignal, appsignal_span: Appsignal.Test.Span
  config :appsignal, appsignal_monitor: Appsignal.Test.Monitor
  config :appsignal, deletion_delay: 100

  config :appsignal, :config,
    otp_app: :appsignal,
    push_api_key: "00000000-0000-0000-0000-000000000000",
    name: "AppSignal test suite app v0",
    env: "test",
    active: true

  config :appsignal,
    ecto_repos: [Appsignal.Test.Repo]
end
