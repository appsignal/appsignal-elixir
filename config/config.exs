use Mix.Config

if Mix.env in [:test, :test_phoenix, :test_no_nif] do
  config :logger,
    level: :warn,
    handle_otp_reports: false,
    handle_sasl_reports: false

  config :appsignal, os: FakeOS
  config :appsignal, appsignal_system: Appsignal.FakeSystem
  config :appsignal, appsignal_nif: Appsignal.FakeNif
  config :appsignal, appsignal_demo: Appsignal.FakeDemo
  config :appsignal, appsignal_transaction: Appsignal.FakeTransaction
  config :appsignal, appsignal_diagnose_report: Appsignal.Diagnose.FakeReport
end
