use Mix.Config

if Mix.env == :test do
  config :appsignal, :config,
    env: :test
end
