# Getting started


## Installation

  1. Add `appsignal` to your list of dependencies in `mix.exs`:

    ```elixir
    def deps do
      [{:appsignal, "~> 0.0"}]
    end
    ```

  2. Ensure `appsignal` is started before your application:

    ```elixir
    def application do
      [applications: [:appsignal]]
    end
    ```

  3. If you use the
     [Phoenix framework](http://www.phoenixframework.org/), *use* the
     `Appsignal.Phoenix` module in your `endpoint.ex` file, just
     *before* the line where your router module gets called
     (which should read something like `plug MyApp.Router`):

     ```elixir
     use Appsignal.Phoenix
     ```

See [Phoenix integration](https://hexdocs.pm/appsignal/phoenix.html)
on how to integrate Appsignal fully into your Phoenix application.

When the AppSignal OTP application starts, it looks for a valid
configuration (e.g. an AppSignal push key), and start the AppSignal agent.

If it can't find a valid configuration, a warning will be logged. See
the "Configuration" section below on how to fully configure the
AppSignal agent.


## Configuration

[Sign up on AppSignal](https://appsignal.com/users/sign_up) and put
the hexadecimal key in your `config.exs`:

    config :appsignal, :config,
      name: :my_first_app,
      push_api_key: "your-hex-appsignal-key"

Alternatively, you can configure the agent using OS environment variables:

    export APPSIGNAL_APP_NAME=my_first_app
    export APPSIGNAL_PUSH_API_KEY=your-hex-appsignal-key


## Running in production: Adding environment and app version

When you are running on a production system you typically want to let
AppSignal know that you do that, and also include the version
(revision) number of your application.  A typical `config/prod.exs`
would thus contain:

    config :appsignal, :config,
      name: :my_first_app,
      push_api_key: "your-hex-appsignal-key",
      env: :prod,
      revision: Mix.Project.config[:version]

## Disable for tests

If you put your entire Appsignal configuration in the `config.exs`
instead of `prod.exs`, (e.g. for having Appsignal enabled during
development), make sure to put `active: false` in your test config
unless you want to submit all your test results:

    config :appsignal, :config,
      active: false

## Filtered parameters

In most apps at least some of the data that might be posted to the app is
sensitive information that should not leave the network. We support two ways of
filtering parameters from being sent to AppSignal.

## Using Phoenix's filter_parameters configuration

You can use Phoenix's parameter filtering, which is used to keep sensitive
information from the logs:

    config :phoenix, :filter_parameters, ["password", "secret"]

If `:filter_parameters` is not set, Phoenix will default to `["password"]`. This
means that a Phoenix app will not send any passwords to AppSignal without any
configuration.

## Using AppSignal's built-in filtering

If you're not using Phoenix, or want to filter parameters without changing the
Phoenix.Logger's configuration, you can set up filtered parameters in the
AppSignal configuration file:

    config :appsignal, :filter_parameters, ["password", "secret"]

## Configuration keys

The full list of variables that can be configured is the following:

 - `APPSIGNAL_ACTIVE` (Elixir config key: `:active`)
 - `APPSIGNAL_PUSH_API_KEY` (Elixir config key: `:push_api_key`)
 - `APPSIGNAL_APP_NAME` (Elixir config key: `:name`)
 - `APP_REVISION` (Elixir config key: `:revision`)
 - `APPSIGNAL_PUSH_API_ENDPOINT` (Elixir config key: `:endpoint`)
 - `APPSIGNAL_FRONTEND_ERROR_CATCHING_PATH` (Elixir config key: `:frontend_error_catching_path`)
 - `APPSIGNAL_APP_ENV` (Elixir config key: `:env`; defaults to `:dev`; other valid values are `:test` and `:prod`)
 - `APPSIGNAL_DEBUG` (Elixir config key: `:debug`)
 - `APPSIGNAL_LOG_PATH` (Elixir config key: `:log_path`)
 - `APPSIGNAL_IGNORE_ERRORS` (Elixir config key: `:ignore_errors`)
 - `APPSIGNAL_IGNORE_ACTIONS` (Elixir config key: `:ignore_actions`)
 - `APPSIGNAL_HTTP_PROXY` (Elixir config key: `:http_proxy`)
 - `APPSIGNAL_RUNNING_IN_CONTAINER` (Elixir config key: `:running_in_container`)
 - `APPSIGNAL_WORKING_DIR_PATH` (Elixir config key: `:working_dir_path`)
 - `APPSIGNAL_ENABLE_HOST_METRICS` (Elixir config key: `:enable_host_metrics`)
 - `APPSIGNAL_FILTER_PARAMETERS` (Elixir config key: `:filter_parameters`)
