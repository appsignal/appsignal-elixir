use Mix.Config

if Mix.env == :test do
  config :appsignal, os: FakeOS
end
