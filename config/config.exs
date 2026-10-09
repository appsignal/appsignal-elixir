import Config

if Mix.env() in [:bench, :test, :test_no_nif] do
  config :appsignal, appsignal_system: Appsignal.FakeSystem
  config :appsignal, appsignal_nif: Appsignal.FakeNif
  config :appsignal, appsignal_diagnose_report: Appsignal.Diagnose.FakeReport

  config :appsignal,
    appsignal_diagnose_installation_report: Appsignal.Diagnose.FakeInstallationReport

  config :appsignal, appsignal: Appsignal.FakeAppsignal
  config :appsignal, appsignal_integration_logger: Appsignal.FakeIntegrationLogger
  config :appsignal, appsignal_transmitter: Appsignal.FakeTransmitter
  config :appsignal, appsignal_checkin_scheduler: Appsignal.FakeScheduler
  config :appsignal, appsignal_checkin_debounce: Appsignal.FakeDebounce
  config :appsignal, inet: FakeInet
  config :appsignal, system: FakeSystem
  config :appsignal, io: FakeIO
  config :appsignal, file: FakeFile
  config :appsignal, os_internal: FakeOS
  config :appsignal, ecto_repo: FakeEctoRepo

  config :appsignal, appsignal_monitor: Appsignal.Test.Monitor
  config :appsignal, appsignal_span: Appsignal.Test.Span
  config :appsignal, appsignal_tracer: Appsignal.Test.Tracer
  config :appsignal, appsignal_tracer_nif: Appsignal.Test.Nif

  config :appsignal, deletion_delay: 100
  config :appsignal, appsignal_checkin_heartbeat_interval_milliseconds: 10

  config :appsignal, :config,
    otp_app: :appsignal,
    push_api_key: "00000000-0000-0000-0000-000000000000",
    name: "AppSignal test suite app v0",
    env: "test",
    active: true

  config :appsignal,
    ecto_repos: [Appsignal.Test.Repo]

  # The Phoenix application the tests run requests through, when the
  # dependency set includes Phoenix.
  for endpoint <- [
        AppsignalTest.Phoenix.MountingEndpoint,
        AppsignalTest.Phoenix.Endpoint,
        AppsignalTest.Phoenix.BanditEndpoint,
        AppsignalTest.Phoenix.CowboyEndpoint
      ] do
    config :appsignal, endpoint,
      secret_key_base: String.duplicate("appsignal", 8),
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
end
