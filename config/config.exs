use Mix.Config

if Mix.env in [:test, :test_phoenix] do
  config :logger,
    level: :warn,
    handle_otp_reports: false,
    handle_sasl_reports: false
end
