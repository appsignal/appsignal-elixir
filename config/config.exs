use Mix.Config

if Mix.env == :test do
  config :logger,
    level: :warn,
    handle_otp_reports: false,
    handle_sasl_reports: false
end
