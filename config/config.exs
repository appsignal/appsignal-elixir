use Mix.Config

if Mix.env in [:test, :test_phoenix, :test_no_nif] do
  config :logger,
    level: :warn,
    handle_otp_reports: false,
    handle_sasl_reports: false

  config :appsignal, appsignal_system: Appsignal.FakeSystem
  config :appsignal, appsignal_nif: Appsignal.FakeNif
end

import_config "agent.exs"
