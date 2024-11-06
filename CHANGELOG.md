# AppSignal for Elixir changelog

## 2.13.1

_Published on 2024-11-06._

### Added

- Add `reported_by` tag to errors reported by the legacy error backend. This makes it easier to understand whether an error is being reported by the error backend. (patch [440e53dd](https://github.com/appsignal/appsignal-elixir/commit/440e53ddc57ad2b6e974f7cda3701b9ca44cf0d1))
- Set the app revision config option for Scalingo deploys automatically. If the `CONTAINER_VERSION` system environment variable is present, it will use used to set the `revision` config option automatically. Overwrite it's value by configuring the `revision` config option for your application. (patch [dc86ad85](https://github.com/appsignal/appsignal-elixir/commit/dc86ad85c96ddab01a44300d9ed2131a68f4cc77))

### Changed

- Change the primary download mirror for integrations. (patch [f3d201c1](https://github.com/appsignal/appsignal-elixir/commit/f3d201c1b8e30fda35898780299509026d29a0af))

### Fixed

- Fix parentheses warning for Tesla on Elixir 1.17.x. (patch [6a62ea1a](https://github.com/appsignal/appsignal-elixir/commit/6a62ea1a86e9b203f13df78e1d1315b8d61f463e))
- Fix an issue where, after a certain amount of time, check-ins would no longer be sent.

  This issue also caused the default Hackney connection pool to be saturated, affecting other code that uses the default Hackney connection pool.

  (patch [7233adfa](https://github.com/appsignal/appsignal-elixir/commit/7233adfa3b7a5fc16e523f00bbd85a42e8cbc148))

## 2.13.0

_Published on 2024-09-26._

### Added

- Add support for heartbeat check-ins.

  Use the `Appsignal.CheckIn.heartbeat` method to send a single heartbeat check-in event from your application. This can be used, for example, in a `GenServer`'s callback:

  ```elixir
  @impl true
  def handle_cast({:process_job, job}, jobs) do
    Appsignal.CheckIn.heartbeat("job_processor")
    {:noreply, [job | jobs], {:continue, :process_job}}
  end
  ```

  Heartbeats are deduplicated and sent asynchronously, without blocking the current thread. Regardless of how often the `.heartbeat` method is called, at most one heartbeat with the same identifier will be sent every ten seconds.

  Pass `continuous: true` as the second argument to send heartbeats continuously during the entire lifetime of the current process. This can be used, for example, during a `GenServer`'s initialisation:

  ```elixir
  @impl true
  def init(_arg) do
    Appsignal.CheckIn.heartbeat("my_genserver", continuous: true)
    {:ok, nil}
  end
  ```

  You can also use `Appsignal.CheckIn.Heartbeat` as a supervisor's child process, in order for heartbeats to be sent continuously during the lifetime of the supervisor. This can be used, for example, during an `Application`'s start:

  ```elixir
  @impl true
  def start(_type, _args) do
    Supervisor.start_link([
      {Appsignal.CheckIn.Heartbeat, "my_application"}
    ], strategy: :one_for_one, name: MyApplication.Supervisor)
  end
  ```

  (minor [7b2ff327](https://github.com/appsignal/appsignal-elixir/commit/7b2ff327b7f915a7245c4ad6f4dfd0f3c6b13ff5))

### Changed

- Send check-ins concurrently. When calling `Appsignal.CheckIn.cron`, instead of blocking the current process while the check-in events are sent, schedule them to be sent in a separate process. (patch [e7cead98](https://github.com/appsignal/appsignal-elixir/commit/e7cead9880d537f384e64f85330db819d1d66148))

## 2.12.3

_Published on 2024-08-26._

### Fixed

- Make `Appsignal.Ecto.Repo`'s `default_options/1` function overridable. If your Ecto repo uses `Appsignal.Ecto.Repo` and implements its own `default_options/1`, it must call `super` to merge its default options with those of `Appsignal.Ecto.Repo`:

  ```elixir
  defmodule MyEctoRepo
    use Appsignal.Ecto.Repo

    def default_options(operation) do
      super(operation) ++ [
        # ... your default options here ...
      ]
    end
  end
  ```

  (patch [3d9634c7](https://github.com/appsignal/appsignal-elixir/commit/3d9634c7a16999f45b8fcb64024f6b29cdaead4d))
- Fix an issue where Ecto transactions in parallel preloads would not be instrumented correctly when using `Appsignal.Ecto.Repo`, causing the query in the Ecto transaction to not be instrumented and the sample to be incorrectly closed as an earlier time. (patch [d5e132e0](https://github.com/appsignal/appsignal-elixir/commit/d5e132e0bdba6ae0256d336ce0c087e29c9efb4e))

## 2.12.2

_Published on 2024-08-14._

### Changed

- Rename heartbeats to cron check-ins. Calls to `Appsignal.heartbeat` and `Appsignal.Heartbeat` should be replaced with calls to `Appsignal.CheckIn.cron` and `Appsignal.CheckIn.Cron`, for example:

  ```elixir
  # Before
  Appsignal.heartbeat("do_something", fn ->
    do_something()
  end)

  # After
  Appsignal.CheckIn.cron("do_something", fn ->
    do_something
  end)
  ```

  (patch [1c3b9c67](https://github.com/appsignal/appsignal-elixir/commit/1c3b9c671544816486b9b1cc69c3400a672c42fb))

### Deprecated

- Calls to `Appsignal.heartbeat` and to methods in `Appsignal.Heartbeat` will emit a deprecation warning at compile-time. (patch [1c3b9c67](https://github.com/appsignal/appsignal-elixir/commit/1c3b9c671544816486b9b1cc69c3400a672c42fb))

## 2.12.1

_Published on 2024-06-25._

### Fixed

- [990f3b26](https://github.com/appsignal/appsignal-elixir/commit/990f3b26817d579c6eb32b1f84a78db529f53181) patch - When running the installation script on Microsoft Windows, some components threw an error. AppSignal doesn't support Windows, so the installation script won't run on Windows anymore. Preventing errors from raising.

## 2.12.0

_Published on 2024-06-05._

### Changed

- [6ce84310](https://github.com/appsignal/appsignal-elixir/commit/6ce843108bd105053eca4ef268caaf9a69ecbc32) minor - Group GraphQL queries by operation names if available. It will no longer group all errors and performance measurements under the same action name. If no operation name is set, it will use the default action name of the HTTP request route, like `POST /graphql`.
  
  If you do not wish to use the operation name, or customize the action name for the GraphQL query request, use the `Appsignal.Span.set_name` in a plug middleware that is called before or after the HTTP request is made:
  
  ```elixir
  Appsignal.Span.set_name(Appsignal.Tracer.root_span(), "MyActionName")
  ```

## 2.11.0

_Published on 2024-06-04._

### Added

- [4508bd10](https://github.com/appsignal/appsignal-elixir/commit/4508bd10f8480fa2a9eea077f0f2f5c3a8dec4eb) patch - Add `Appsignal.Span.set_name_if_nil` helper. This helper can be used to not overwrite previously set span names, and only set the span name if it wasn't set previously. This will used most commonly in AppSignal created integrations with other libraries to allow apps to set custom span names.

### Changed

- [cb7c2e9d](https://github.com/appsignal/appsignal-elixir/commit/cb7c2e9d607a0035a287db5b7e9485c834fde084) minor - Turn error backend off by default. This will prevent errors from being reported without much context. If you're missing errors after this change, set the `enable_error_backend` config option to `true`, and let us know what errors you're missing at [support@appsignal.com](mailto:support@appsignal.com).
- [4b8bbf75](https://github.com/appsignal/appsignal-elixir/commit/4b8bbf75a3b2defc21d2be2fa401f11980c26c1a) patch - Add debug and error logs to probes to better track what it's doing. This is helpful when debugging issues with the minutely probes system.

## 2.10.2

_Published on 2024-05-14._

### Added

- [1a87c94a](https://github.com/appsignal/appsignal-elixir/commit/1a87c94a6f6c1b972aa68507e4a9f1243b9dd570) patch - Support Kamal-based deployments. Read the `KAMAL_VERSION` environment variable, which Kamal exposes within the deployed container, if present, and use it as the application revision if it is not set. This will automatically report deploy markers for applications using Kamal.

### Changed

- [a19671f6](https://github.com/appsignal/appsignal-elixir/commit/a19671f6f165a7957c39516f76a69f08e9e22ab5) patch - Log debug messages when metrics are received for easier debugging.

## 2.10.1

_Published on 2024-04-25._

### Fixed

- [5a7810c8](https://github.com/appsignal/appsignal-elixir/commit/5a7810c81a20961418285b6af8da47694c4b5b16) patch - Fix the Phoenix `filter_parameters` config option support for partial key matches. When configuring `config :phoenix, filter_parameters` with `["key"]` or `{:discard, ["key"]}`, it now also matches partial keys like `"my_key"`, just like Phoenix's logger does.

## 2.10.0

_Published on 2024-04-22._

### Added

- [840e6c0b](https://github.com/appsignal/appsignal-elixir/commit/840e6c0bd9934dba1614f7aae3d60350975f3be3) minor - _Heartbeats are currently only available to beta testers. If you are interested in trying it out, [send an email to support@appsignal.com](mailto:support@appsignal.com?subject=Heartbeat%20beta)!_
  
  ---
  
  Add heartbeats support. You can send heartbeats directly from your code, to track the execution of certain processes:
  
  ```elixir
  def send_invoices do
    # ... your code here ...
    Appsignal.heartbeat("send_invoices")
  end
  ```
  
  You can pass a function to `Appsignal.heartbeat`, to report to AppSignal both when the process starts, and when it finishes, allowing you to see the duration of the process:
  
  ```elixir
  def send_invoices do
    Appsignal.heartbeat("send_invoices", fn ->
      # ... your code here ...
    end)
  end
  ```
  
  If an exception is thrown within the function, the finish event will not be reported to AppSignal, triggering a notification about the missing heartbeat. The exception will bubble outside of the heartbeat function.
- [d56d3ebd](https://github.com/appsignal/appsignal-elixir/commit/d56d3ebd2286ee4e4aa75553aeaf49ec1c312bbe) patch - Implement the `ignore_logs` configuration option, which can also be configured as the `APPSIGNAL_IGNORE_LOGS` environment variable.
  
  The value of `ignore_logs` is a list (comma-separated, when using the environment variable) of log line messages that should be ignored. For example, the value `"start"` will cause any message containing the word "start" to be ignored. Any log line message containing a value in `ignore_logs` will not be reported to AppSignal.
  
  The values can use a small subset of regular expression syntax (specifically, `^`, `$` and `.*`) to narrow or expand the scope of lines that should be matched.
  
  For example, the value `"^start$"` can be used to ignore any message that is _exactly_ the word "start", but not messages that merely contain it, like "Process failed to start". The value `"Task .* succeeded"` can be used to ignore messages about task success regardless of the specific task name.

### Fixed

- [38511da4](https://github.com/appsignal/appsignal-elixir/commit/38511da476be461bbe2d4f97cf58e5d5ba5e828a) patch - Remove broken link about 1.x upgrade

## 2.9.2

_Published on 2024-03-22._

### Fixed

- [4567ce04](https://github.com/appsignal/appsignal-elixir/commit/4567ce04279ebd53570c84870a81bf7168a91091) patch - Drop non-500 Plug errors in add_error/3

## 2.9.1

_Published on 2024-03-20._

### Added

- [c833c8a4](https://github.com/appsignal/appsignal-elixir/commit/c833c8a4bb82febb0a45b1fb8a5fdeff238444be) patch - Implement CPU count configuration option. Use it to override the auto-detected, cgroups-provided number of CPUs that is used to calculate CPU usage percentages.
  
  To set it, use the `cpu_count` configuration option, or the `APPSIGNAL_CPU_COUNT` environment variable.

## 2.9.0

_Published on 2024-03-06._

### Added

- [be785ea9](https://github.com/appsignal/appsignal-elixir/commit/be785ea99d55d04f42639ed7a93b8c5b458240dc) patch - Add histogram support to the OpenTelemetry HTTP server. This allows OpenTelemetry-based instrumentations to report histogram data to AppSignal as distribution metrics.

### Changed

- [2d3130fd](https://github.com/appsignal/appsignal-elixir/commit/2d3130fd5d6bbdcdb91e35f581857e05c8ec292a) minor - **Breaking change**: Normalize CPU metrics for cgroups v1 systems. When we can detect how many CPUs are configured in the container's limits, we will normalize the CPU percentages to a maximum of 100%. This is a breaking change. Triggers for CPU percentages that are configured for a CPU percentage higher than 100% will no longer trigger after this update. Please configure triggers to a percentage with a maximum of 100% CPU percentage.
- [1566a4a8](https://github.com/appsignal/appsignal-elixir/commit/1566a4a8cf0536203027438b01cf1054c4afbf01) patch - Update the Mix config import in the `config/appsignal.exs` file to use `import Config`, rather than the deprecated `use Mix.Config`.
- [2d3130fd](https://github.com/appsignal/appsignal-elixir/commit/2d3130fd5d6bbdcdb91e35f581857e05c8ec292a) patch - Support fractional CPUs for cgroups v2 metrics. Previously a CPU count of 0.5 would be interpreted as 1 CPU. Now it will be correctly seen as half a CPU and calculate CPU percentages accordingly.
- [fb7568ac](https://github.com/appsignal/appsignal-elixir/commit/fb7568aced9ddcf1eb055c590ff1554d603c81a7) patch - Update bundled trusted root certificates.

### Fixed

- [ad0fdb0c](https://github.com/appsignal/appsignal-elixir/commit/ad0fdb0c2142eaf53f0129568164ce4c96dd1337) patch - Fix (sub)traces not being reported in their entirety when the OpenTelemetry exporter sends one trace in multiple export requests. This would be an issue for long running traces, that are exported in several requests.

## 2.8.3

_Published on 2024-02-01._

### Added

- [e685b22f](https://github.com/appsignal/appsignal-elixir/commit/e685b22f1d56beeedd66587002b4e839896ce1c9) patch - Set data on spans with the `custom_on_create_fun` hook. This hook is called upon the creation of every span. This can be useful to add tags to internal traces and otherwise difficult to access traces.
  
  This won't be necessary for most scenarios. We recommend following [our tagging guide](https://docs.appsignal.com/guides/custom-data/tagging-request.html#elixir) instead.
  
  ```elixir
  defmodule MyApp.Appsignal do
    def custom_on_create_fun(_span) do
      Appsignal.Span.set_sample_data(Appsignal.Tracer.root_span, "tags", %{"locale": "en"})
    end
  end
  ```
  
  ```elixir
  # config/config.exs
  config :appsignal, custom_on_create_fun: &MyApp.Appsignal.custom_on_create_fun/1
  ```

### Changed

- [924a3ffa](https://github.com/appsignal/appsignal-elixir/commit/924a3ffa3e0e456234df3c8a56c4a7cea875c214) patch - Make the debug log message for OpenTelemetry spans from libraries we don't automatically recognize more clear. Mention the span id and the instrumentation library.
- [924a3ffa](https://github.com/appsignal/appsignal-elixir/commit/924a3ffa3e0e456234df3c8a56c4a7cea875c214) patch - Fix an issue where queries containing a MySQL leading type indicator would only be partially sanitised.

## 2.8.2

### Added

- [47f4a8df](https://github.com/appsignal/appsignal-elixir/commit/47f4a8df24250b7985178372e59408b3feae0af8) patch - Add `Appsignal.Ecto.Repo` to support parallel preloads.
  
  For AppSignal to be able to instrument parallel preloads, the current instrumentation context needs to be passed from the Elixir process that spawns the preload to the short-lived processes that run each of the parallel queries.
  
  By replacing `use Ecto.Repo` with `use Appsignal.Ecto.Repo`, the appropriate telemetry context will be passed so that AppSignal can correctly instrument these queries:
  
  ```elixir
  defmodule MyApp.Repo do
    # replace `use Ecto.Repo` with `use Appsignal.Ecto.Repo`
    use Appsignal.Ecto.Repo,
      otp_app: :my_app,
      adapter: Ecto.Adapters.Postgres
  end
  ```

## 2.8.1

### Changed

- [40dc85ef](https://github.com/appsignal/appsignal-elixir/commit/40dc85efb1a9ecb5803dc82c88cb37c1c8ccc72d) patch - Fix disk usage returning a Vec with no entries on Alpine Linux when the `df --local` command fails.
- [92d948fa](https://github.com/appsignal/appsignal-elixir/commit/92d948fa1f8db9546a9074789d7e1ff7264aa720) patch - Add support for lists in the sample data as root values on spans, as shown below. Previously we only supported lists as nested objects in maps.
  
  ```elixir
  Appsignal.Span.set_sample_data(
    Appsignal.Tracer.root_span,
    "custom_data",
    [
      "value 1",
      "value 2"
    ]
  )
  ```

### Removed

- [40dc85ef](https://github.com/appsignal/appsignal-elixir/commit/40dc85efb1a9ecb5803dc82c88cb37c1c8ccc72d) patch - Remove the `appsignal_set_host_gauge` and `appsignal_set_process_gauge` extension functions. These functions were already deprecated and did not report any metrics.

### Fixed

- [9ec351a7](https://github.com/appsignal/appsignal-elixir/commit/9ec351a7e4fc77ac2ca1976191235793f625888d) patch - Fix missing error metrics for the error rate and error count graphs in some scenarios, like with Node.js Koa apps.
- [a339fc1d](https://github.com/appsignal/appsignal-elixir/commit/a339fc1d9ef8f8c34c32c5415bd32dbd0cb6b754) patch - Add support for keywords lists in sample data on spans. These would previously be shown an empty list.
  
  ```elixir
  Appsignal.Span.set_sample_data(
    Appsignal.Tracer.root_span,
    "custom_data",
    %{"keyword_list": [foo: "some value", "bar": "other value"]}
  )
  ```

## 2.8.0

### Changed

- [8e8911f0](https://github.com/appsignal/appsignal-elixir/commit/8e8911f0091d5a74633235a5e4371fe0369e405f) minor - Always use Jason to encode JSON. This removes the need to install either Jason or Poison alongside AppSignal, simplifying our installation instructions.
- [9dbf8d82](https://github.com/appsignal/appsignal-elixir/commit/9dbf8d829e5aa4cbb1c73a8c5594cb0b9ab9d31a) patch - Filter more disk mountpoints for disk usage and disk IO stats. This helps reduce noise in the host metrics by focussing on more important mountpoints.
  
  The following mountpoint are ignored. Any mountpoint containing:
  
  - `/etc/hostname`
  - `/etc/hosts`
  - `/etc/resolv.conf`
  - `/snap/`
  - `/proc/`

### Fixed

- [9dbf8d82](https://github.com/appsignal/appsignal-elixir/commit/9dbf8d829e5aa4cbb1c73a8c5594cb0b9ab9d31a) patch - - Support disk usage reporting (using `df`) on Alpine Linux. This host metric would report an error on Alpine Linux.
  - When a disk mountpoint has no inodes usage percentage, skip the mountpoint, and report the inodes information successfully for the inodes that do have an inodes usage percentage.

## 2.7.13

### Changed

- [c883847a](https://github.com/appsignal/appsignal-elixir/commit/c883847aff145d35a4d925e54532648c3616da23) patch - Bump agent to eec7f7b
  
  Updated the probes dependency to 0.5.2. CPU usage is now normalized to the number of CPUs available to the container. This means that a container with 2 CPUs will have its CPU usage reported as 50% when using 1 CPU instead of 100%. This is a breaking change for anyone using the cpu probe.
  
  If you have CPU triggers set up based on the old behaviour, you might need to update those to these new normalized values to get the same behaviour. Note that this is needed only if the AppSignal integration package you're using includes this change.

## 2.7.12

### Changed

- [33f08759](https://github.com/appsignal/appsignal-elixir/commit/33f08759b1e4f00fb929d6c5a7d6bd86516048d3) patch - Improve Ecto transaction instrumentation. Queries performed as part of an
  `Ecto.Multi` or an `Ecto.Repo.transaction` were already individually
  instrumented, but now they are displayed in the event timeline as child events
  of a broader transaction event. An additional event is added at the end of the
  transaction, to denote whether the transaction was committed or rolled back.

## 2.7.11

### Changed

- [dae88280](https://github.com/appsignal/appsignal-elixir/commit/dae8828059cf6fe18a3ff042c23988af56e86006) patch - Bump agent to b604345.
  
  - Add an exponential backoff to the retry sleep time to bind to the StatsD, NGINX and OpenTelemetry exporter ports. This gives the agent a longer time to connect to the ports if they become available within a 4 minute window.
  - Changes to the agent logger:
    - Logs from the agent and extension now use a more consistent format in logs for spans and transactions.
    - Logs that are for more internal use are moved to the trace log level and logs that are useful for debugging most support issues are moved to the debug log level. It should not be necessary to use log level 'trace' as often anymore. The 'debug' log level should be enough.
  - Add `running_in_container` to agent diagnose report, to be used primarily by the Python package as a way to detect if an app's host is a container or not.
- [e6c4c79f](https://github.com/appsignal/appsignal-elixir/commit/e6c4c79f8096fe88c5d7cc3983e91096e3aa946f) patch - Bump agent to 1dd2a18.
  
  - When adding an SQL body attribute via the extension, instead of truncating the body first and sanitising it later, sanitise it first and truncate it later. This prevents an issue where queries containing very big values result in truncated sanitisations.

### Fixed

- [197e3610](https://github.com/appsignal/appsignal-elixir/commit/197e3610d0c4edfaaa61e3715d46b073f56e115e) patch - Avoid reporting an Oban insert job event as a new incident. This should fix an issue where "insert job" events with little information show up in AppSignal as their own incidents when Oban jobs are inserted from an uninstrumented context that has no parent spans.

## 2.7.10

### Added

- [68ec699e](https://github.com/appsignal/appsignal-elixir/commit/68ec699ead0c82dff11c73dc2ec1cf1cd928d4d0) patch - Implement an Erlang :logger handler for sending logs from AppSignal, in
  preparation for the eventual deprecation of Elixir logger backends.
  
  Add a convenience method to configure this logger handler automatically,
  with the right settings for AppSignal:
  
  ```elixir
  Appsignal.Logger.Handler.add("my_app", :plaintext)
  ```
  
  To remove the logging handler, call the `.remove` method:
  
  ```elixir
  Appsignal.Logger.Handler.remove()
  ```

### Changed

- [cc526cb6](https://github.com/appsignal/appsignal-elixir/commit/cc526cb63bb4894cd1e6c2e67f9b0f0fee2b5271) patch - Bump agent to e8207c1.
  
  - Add `memory_in_percentages` and `swap_in_percentages` host metrics that represents metrics in percentages.
  - Ignore `/snap/` disk mountpoints.
  - Fix issue with the open span count in logs being logged as a negative number.
  - Fix agent's TCP server getting stuck when two requests are made within the same fraction of a second.

### Fixed

- [bcbc1c6a](https://github.com/appsignal/appsignal-elixir/commit/bcbc1c6aa3f28c1bcba95866182964da9f10cc4b) patch - Fix configuration options set with atoms. The options `log` and `log_level` can now be set as an Atom, and we'll cast them to a string internally to avoid any `ArgumentError` from the Nif.
- [92a7e886](https://github.com/appsignal/appsignal-elixir/commit/92a7e886449b6bdaa8e553585b1084e6d6b314d5) patch - Fix support for `warning` `log_level`. Only `warn` would work, now `warning` also works as documented.

## 2.7.9

### Fixed

- [ebd39c39](https://github.com/appsignal/appsignal-elixir/commit/ebd39c39553f55249cbb88e21e67c9c3a01fec85) patch - Bump agent to 6133900.
  
  - Fix `disk_inode_usage` metric name format to not be interpreted as a JSON object.

## 2.7.8

### Added

- [489615ae](https://github.com/appsignal/appsignal-elixir/commit/489615aee6f66da503ab57d0a5a6312111532602) patch - Add the `host_role` config option. This config option can be set per host to generate some metrics automatically per host and possibly do things like grouping in the future.

### Changed

- [7b3875b2](https://github.com/appsignal/appsignal-elixir/commit/7b3875b2c223114dd98dd9fbf55eb1e762d8984b) patch - Bump agent to 6bec691.
  
  - Upgrade `sql_lexer` to v0.9.5. It adds sanitization support for the `THEN` and `ELSE` logical operators.
- [7781f405](https://github.com/appsignal/appsignal-elixir/commit/7781f40579750386525b301ae7c1a3c475ca8b54) patch - Bump agent to version d789895.
  
  - Increase short data truncation from 2000 to 10000 characters.

## 2.7.7

### Added

- [75e70db2](https://github.com/appsignal/appsignal-elixir/commit/75e70db27ec8f84faaf647522fb3027cc41b2f9c) patch - Use `RENDER_GIT_COMMIT` environment variable as revision if no revision is specified.
- [7c3103ae](https://github.com/appsignal/appsignal-elixir/commit/7c3103aef9b3621f562ee7bccaf1f591ba5cb91c) patch - Allow JSON and Logfmt log messages
- [2b3eab1d](https://github.com/appsignal/appsignal-elixir/commit/2b3eab1dd06bf212547f18f9732b7d091f2cd76a) patch - Allow configuration of the agent's TCP and UDP servers using the `bind_address` config option. This is by default set to `127.0.0.1`, which only makes it accessible from the same host. If you want it to be accessible from other machines, use `0.0.0.0` or a specific IP address.
- [08aedeef](https://github.com/appsignal/appsignal-elixir/commit/08aedeefe8715b963587798bbacc4ab1d1f043dd) patch - Report total CPU usage host metric for VMs. This change adds another `state` tag value on the `cpu` metric called `total_usage`, which reports the VM's total CPU usage in percentages.

### Changed

- [ece48144](https://github.com/appsignal/appsignal-elixir/commit/ece481440c571ce792ee4bab86a297ce7eb3a1bf) patch - Bump agent to 32590eb.
  
  - Only ignore disk metrics that start with "loop", not all mounted disks that end with a number to report metrics for more disks.

### Fixed

- [b7089a8e](https://github.com/appsignal/appsignal-elixir/commit/b7089a8e1ea9340ed28692e75d7976e653edf891) patch - Handle atoms for categories in transaction_event decorator

## 2.7.6

### Added

- [be411435](https://github.com/appsignal/appsignal-elixir/commit/be41143553a8d6a37e2af12e688f5625cb1d3de8) patch - Add `set_sample_data_if_nil` function to `Appsignal.Span`, allowing for parameters to be set only if they would not override other parameters.
- [be411435](https://github.com/appsignal/appsignal-elixir/commit/be41143553a8d6a37e2af12e688f5625cb1d3de8) patch - Use `RENDER_GIT_COMMIT` environment variable as revision if no revision is specified.

## 2.7.5

### Changed

- [5e5918f5](https://github.com/appsignal/appsignal-elixir/commit/5e5918f5938ce1a673659c26663f74becdb0425e) patch - Improve argument cleaning.
  
  The output should appear in a more familiar format for Elixir developers. Potentially personally identifiable data is removed and the output is truncated to make it easier to understand, while attempting to provide enough information to differentiate between different function clauses.

### Fixed

- [af402113](https://github.com/appsignal/appsignal-elixir/commit/af4021135602263d7285050a1f298c8a145b7401) patch - Improve Tracer performance by removing duplicate runtime configuration and storage checks

## 2.7.4

### Fixed

- [dcdac33e](https://github.com/appsignal/appsignal-elixir/commit/dcdac33e3ab25bf9e003507579201e3e34174dc4) patch - Add handling for cowboy error edge cases to prevent error backend crashes

## 2.7.3

### Added

- [37810e11](https://github.com/appsignal/appsignal-elixir/commit/37810e1179cf05b295dbba4c01aac3a0cb9ba80c) patch - Allow configuration of the agent's StatsD server port through the `statsd_port` option.
- [0caf8330](https://github.com/appsignal/appsignal-elixir/commit/0caf833097f7d44a310d314083050634938ab583) patch - Add automatic instrumentation for Tesla.

### Changed

- [7e7c097d](https://github.com/appsignal/appsignal-elixir/commit/7e7c097d70b2c41466f64c1f531451a60652b087) patch - Bump agent to fd8ee9e.
  
  - Rely on APPSIGNAL_RUNNING_IN_CONTAINER config option value before other environment factors to determine if the app is running in a container.
  - Fix container detection for hosts running Docker itself.
  - Add APPSIGNAL_STATSD_PORT config option.

## 2.7.2

### Changed

- [49467767](https://github.com/appsignal/appsignal-elixir/commit/4946776794013bd8dc381e5dce2b665157fbb3cf) patch - Update agent to v-f9b0c15
  
  - Add more span API logging.

## 2.7.1

### Fixed

- [8b8d06fa](https://github.com/appsignal/appsignal-elixir/commit/8b8d06fad959f9cc313844455434e0e8f483e77f) patch - Trim SQL attributes in spans. This fixes an issue where very big payloads are sent from the Elixir integration.

## 2.7.0

### Changed

- [885c3618](https://github.com/appsignal/appsignal-elixir/commit/885c36183c76f39811b20fa14460c197d601848f) patch - Update agent to version 6f29190.
  
  - Log revision config in boot debug log.
  - Update internal agent CLI start command.
  - Rename internal `_APPSIGNAL_ENVIRONMENT` variable to `_APPSIGNAL_APP_ENV` to be consistent with the public version.
- [87946896](https://github.com/appsignal/appsignal-elixir/commit/87946896499f19702136129fc1502332648fa3a9) patch - Update bundled trusted root certificates.
- [704da7a9](https://github.com/appsignal/appsignal-elixir/commit/704da7a95ad98b2f3cce1f32eddb1cbf5ed0702f) patch - Bump agent to 4a0a036. Fix a transmission requeueing problem with queued payloads.

## 2.7.0-beta.1

### Added

- [45deeedd](https://github.com/appsignal/appsignal-elixir/commit/45deeedd82273df88812fd96e25260dab9f71a00) minor - Add Absinthe instrumentation

## 2.6.1

### Fixed

- [2bc1346f](https://github.com/appsignal/appsignal-elixir/commit/2bc1346f2cf6657e60df5e173c02cdd979c51217) patch - Handle unexpected events in Logger backend

## 2.6.0

### Added

- [6462f802](https://github.com/appsignal/appsignal-elixir/commit/6462f802ae1724e075b404e476272a11e0cbc0f3) minor - Add Logger backend to redirect Elixir logs to AppSignal.

### Changed

- [2d424448](https://github.com/appsignal/appsignal-elixir/commit/2d42444884f74b459a97a97d268cdc576c152705) patch - Bump agent to 8d042e2.
  
  - Support multiple log formats.
- [a886a2b7](https://github.com/appsignal/appsignal-elixir/commit/a886a2b7788602cbe5b95d17a0259013e7e9630b) patch - Bump agent to dee4fcb.
  
  - Support cgroups v2. Used by newer Docker engines to report host metrics. Upgrade if you receive no host metrics for Docker containers.
  - Remove trailing comments in SQL queries, ensuring queries are grouped consistently.

## 2.5.3

### Changed

- [a4a23ded](https://github.com/appsignal/appsignal-elixir/commit/a4a23dedc53f19262a83ced76c69bf8597fde7e3) patch - Bump agent to 0d593d5
  
  - Report shared memory metric state.

## 2.5.2

### Added

- [63adf596](https://github.com/appsignal/appsignal-elixir/commit/63adf596bd56f2da8bd2e843086d283f5137c24e) patch - Add NGINX metrics support. See [our documentation](https://docs.appsignal.com/metrics/nginx.html) for details.

## 2.5.1

### Added

- [837e0285](https://github.com/appsignal/appsignal-elixir/commit/837e0285a336854646967567d939a0277473c1a4) patch - Add config options to disable automatic Ecto, Finch and Oban instrumentations.
  Set `instrument_ecto`, `instrument_finch` or `instrument_oban` to `false` in
  order to disable that instrumentation.
- [b3a77a73](https://github.com/appsignal/appsignal-elixir/commit/b3a77a73c5f8a136d0333c1c64154b3350cec28f) patch - Add a `report_oban_errors` config option to decide when to report Oban errors. When set to `"all"`, all errors will be reported; when set to `"none"`, no errors will be reported. Set it to `"discard"` to only report errors when the job is discarded due to the error and won't be re-attempted.
- [e52997c8](https://github.com/appsignal/appsignal-elixir/commit/e52997c8dfa081822da840dd84d28e9bf6148259) patch - Add metadata functions for Plug/Phoenix apps

### Fixed

- [837e0285](https://github.com/appsignal/appsignal-elixir/commit/837e0285a336854646967567d939a0277473c1a4) patch - Fix the default value of `enable_error_backend` so it defaults to `true` when
  the config option is not set.

## 2.5.0

### Added

- [bc14f302](https://github.com/appsignal/appsignal-elixir/commit/bc14f30275cbdedb773835cc908f1d4b0c3161fa) minor - Add Oban instrumentation. Jobs processed by your Oban workers will now be instrumented with AppSignal, and job insertions will appear as events in your performance samples' event timelines.
- [65107c60](https://github.com/appsignal/appsignal-elixir/commit/65107c60f46db7fe004f031c0b737dd71628d3d6) patch - Track the Operating System release/distro in the diagnose report. This helps us with debugging what exact version of Linux an app is running on, for example.

## 2.4.3

### Fixed

- [1b69bf4e](https://github.com/appsignal/appsignal-elixir/commit/1b69bf4e784850b35125003c67f2aaaae4504e8d) patch - Fix an issue where user configuration enabling metrics for Hackney would cause the AppSignal Agent installation to fail.

## 2.4.2

### Fixed

- [a5c810d4](https://github.com/appsignal/appsignal-elixir/commit/a5c810d44b0ec1273cf1b4c7d4081371d6d74826) patch - Fix an issue where reporting an exception for a function call whose arguments contain a map of PID would raise a second exception instead.

## 2.4.1

### Changed

- [4473ffee](https://github.com/appsignal/appsignal-elixir/commit/4473ffeecb424d589aad59e5ec988bb37968e816) patch - Add enable_error_backend configuration option

## 2.4.0

### Added

- [beb0c43b](https://github.com/appsignal/appsignal-elixir/commit/beb0c43b16b5f1efb9ba43c0449b682efd302375) minor - Support log collection from Elixir apps using the new AppSignal Logging feature. Learn more about [AppSignal's Logging on our docs](https://docs.appsignal.com/logging/platforms/integrations/nodejs.html).

### Changed

- [b2dddb11](https://github.com/appsignal/appsignal-elixir/commit/b2dddb111d80bfaa66eee5df35590432a6e50786) patch - Replace arguments in stack traces with sanitized versions instead of stripping them out completely

## 2.3.1

### Fixed

- [5a9b4b6c](https://github.com/appsignal/appsignal-elixir/commit/5a9b4b6ced14470e0af7c5111923673798d624d8) patch - Fix FunctionClauseError for old Finch versions. This change explicitly ignores events from old Finch versions, meaning only Finch versions 0.12 and above will be instrumented, but using Finch versions 0.11 and below won't cause an event handler crash.

## 2.3.0

### Added

- [2aaf55be](https://github.com/appsignal/appsignal-elixir/commit/2aaf55bea35b339276aa7d5c1933f20f861ecb95) minor - Add Finch integration. HTTP requests performed with Finch will show up as events in the sample view.

## 2.2.19

### Fixed

- [be7825e1](https://github.com/appsignal/appsignal-elixir/commit/be7825e13bdcdb4a8c1100dd39a4afa990ea04fa) patch - Fix extension linking on Alpine Linux ARM64 systems.

## 2.2.18

### Fixed

- [05f59d31](https://github.com/appsignal/appsignal-elixir/commit/05f59d312b2c093296e2eba8182d81deff2ecdbf) patch - Fix compile-time error about symbol names starting with a comma. Updated the linking script to not include the comma.

## 2.2.17

### Fixed

- [b600e85a](https://github.com/appsignal/appsignal-elixir/commit/b600e85a3940fce6df899e0e78f110d4ceb512cd) patch - Fix compile-time warning about an unused funtion in the extension. The `_set_span_attribute_sql_string` function wasn't hooked up, which didn't produce any issues since the SQL queries coming from Ecto don't need to be sanitized any further (sensitive data is already stripped out). This patch still runs them through AppSignal's SQL sanitizer to fix the warning and behave as promised, theoretically.
- [910ad1dd](https://github.com/appsignal/appsignal-elixir/commit/910ad1dd956d8c9a2adf526cf21584d0c90a0d98) patch - Fix compile-time error that broke linking on macOS 12.6, more specifically the latest Xcode at this time (version 14.0 14A309).

## 2.2.16

### Changed

- [03b8306a](https://github.com/appsignal/appsignal-elixir/commit/03b8306a1a78ce4c29b5b90cd19656e4cb0f0a6e) patch - Bump agent to 06391fb
  
  - Accept "warning" value for the `log_level` config option.
  - Add aarch64 Linux musl build.
  - Improve debug logging from the extension.
  - Fix high CPU issue for appsignal-agent when nothing could be read from the socket.

### Fixed

- [4d72d791](https://github.com/appsignal/appsignal-elixir/commit/4d72d791401a6b70432eecd5d85a7f6afeec322a) patch - Always return :ok from Appsignal.config_change/3
- [914f013b](https://github.com/appsignal/appsignal-elixir/commit/914f013b3d6ff865a6067409518e67aafdaf1ae5) patch - Always return the Span from span setter functions, to allow for chaining setter calls with optional values

## 2.2.15

### Changed

- [ab876253](https://github.com/appsignal/appsignal-elixir/commit/ab876253936838369654f11bbcd387a7c52c3994) patch - Bump agent to v-d573c9b
  
  - Clean up payload storage before sending. Should fix issues with locally queued payloads blocking data from being sent.
  - Add OpenTelemetry support for the Span API. Not currently implemented in this package's extension.

### Fixed

- [d66ad2d8](https://github.com/appsignal/appsignal-elixir/commit/d66ad2d84192d4c6e5e20b489023f8c0264c7c56) patch - Always return the Span from Span.set_attribute/3, making it easier to chain this function call.

## 2.2.14

### Fixed

- [ffb3ab29](https://github.com/appsignal/appsignal-elixir/commit/ffb3ab299e2b7a09ab19cdb6ba60ab0accfe4496) patch - Fix compile-time error with empty configurations
- [c3599ae9](https://github.com/appsignal/appsignal-elixir/commit/c3599ae9e496f15ca17eb536019223ade3bb0a8f) patch - Improve the error message on extension load failure. The error message will now print more details about the installed and expected architecture when they mismatch. This is most common on apps mounted on a container after first being installed on the host with a different architecture than the container.
- [4ac415f1](https://github.com/appsignal/appsignal-elixir/commit/4ac415f19b4cb1a8344e23c3de74effc86ef7eb0) patch - Don't crash at compile time when AppSignal is not configured

## 2.2.13

### Fixed

- [26be6e58](https://github.com/appsignal/appsignal-elixir/commit/26be6e58443fab533206f230743da65c66d3bc89) patch - Fix session data by reverting the sample data key change

## 2.2.12

### Added

- [65c5d716](https://github.com/appsignal/appsignal-elixir/commit/65c5d71648a6e25dc91e3e310483e6ce5079cd53) patch - Don't set session data when the send_session_data configuration is set to false

## 2.2.11

### Added

- [e287e58c](https://github.com/appsignal/appsignal-elixir/commit/e287e58cd8baf3234ee7a2c4e9ded33c6f0fd719) patch - Allow ignoring specific pids through Tracer.ignore/1
- [c325114a](https://github.com/appsignal/appsignal-elixir/commit/c325114aa6278d8b4f4cf9587cb288345f5c492f) patch - Log messages are now sent through a centralised logger, defaulting to logging
  to the `/tmp/appsignal.log` file.
  To log to standard output instead, set the `log` config property to `"stdout"`.
- [96c60363](https://github.com/appsignal/appsignal-elixir/commit/96c60363b06f64ed43b1f8a88484ecde45c1710a) patch - Don't set parameters when the send_params configuration is set to false

### Changed

- [bb6c7a65](https://github.com/appsignal/appsignal-elixir/commit/bb6c7a6514261a21d4ce44b9556db4d7ea77f9fb) patch - Add the config "override" source to better communicate and help debug when certain config options are set. This is used by the diagnose report. The override source is used to set the new config option value when a config option has been renamed, like `send_session_data`.
- [003a2edd](https://github.com/appsignal/appsignal-elixir/commit/003a2eddf5f4fe376caf75d044beddb5f70f5037) patch - The extension installation will no longer fail when the CA certificate file is not accessible.
- [db97b2f6](https://github.com/appsignal/appsignal-elixir/commit/db97b2f6593696de577da7971198afb1c4e6b83a) patch - Bump agent to v-bbc830a
  
  - Support batched statsd messages
  - Set start times for spans with traceparents
  - Check duration in transactions for negative and too high values
- [709224ad](https://github.com/appsignal/appsignal-elixir/commit/709224ad62326f7ede0b86497fe9df87c3713a6d) patch - Bump agent to v-f57e6cb
  
  - Enable process metrics on Heroku and Dokku

## 2.2.10

### Added

- [0469f4b2](https://github.com/appsignal/appsignal-elixir/commit/0469f4b2bd80822debd7e5163db13f46ee13e051) patch - Add `send_session_data` option to configure if session data is automatically included in
  spans. By default this is turned on. It can be disabled by configuring
  `send_session_data` to `false`.

### Changed

- [ffe65216](https://github.com/appsignal/appsignal-elixir/commit/ffe652167bb3bfe69b031e2d932ef95ab730a389) patch - Remove Ruby exclusive headers from request_headers defaults.
- [c0a98928](https://github.com/appsignal/appsignal-elixir/commit/c0a98928fb331436f01b7b41212decf7ab949ed1) patch - Bump AppSignal agent version to 15ee07b. Add internal tracking of transmission duration.
- [8c14f827](https://github.com/appsignal/appsignal-elixir/commit/8c14f82737381798a3c230275c99c4333f635238) patch - The diagnose library report now reports the agent version from the committed agent file,
  rather than the downloaded version, which is reported in the installation report.

### Deprecated

- [0469f4b2](https://github.com/appsignal/appsignal-elixir/commit/0469f4b2bd80822debd7e5163db13f46ee13e051) patch - Deprecate `skip_session_data` option in favor of the newly introduced `send_session_data` option.
  If it is configured, it will print a warning on AppSignal load, but will also retain its
  functionality until the config option is fully removed in the next major release.

### Fixed

- [e4ec8e68](https://github.com/appsignal/appsignal-elixir/commit/e4ec8e68abb1d625a0a4a0241e52b167a98a9f3d) patch - Prefer the value of the `log_level` config option, instead of the deprecated `debug` config option, when deciding whether to log a debug message. If `log_level` does not have a value, or its value is invalid, the values of the deprecated `debug` and `transaction_debug_mode` config options are taken into account.

## 2.2.9

### Fixed

- [2b78e1e2](https://github.com/appsignal/appsignal-elixir/commit/2b78e1e2dfed237bfed38705411d837f1211c4b4) patch - Fix debug and transaction_debug_mode log options. If set, previously the log_level would remain "info", since version 2.2.8.

## 2.2.8

### Added

- [4a9bcca3](https://github.com/appsignal/appsignal-elixir/commit/4a9bcca39e20370cc59560ba526618f5cb829ea4) patch - Add "log_level" config option. This new option allows you to select the type of messages
  AppSignal's logger will log and up. The "debug" option will log all "debug", "info", "warning"
  and "error" log messages. The default value is: "info"
  
  The allowed values are:
  - error
  - warning
  - info
  - debug
- [10078177](https://github.com/appsignal/appsignal-elixir/commit/1007817782db6c59377eb7c61f24e884b200affb) patch - Add `send_environment_metadata` config option to configure the environment metadata collection. For more information, see our [environment metadata docs](https://docs.appsignal.com/application/environment-metadata.html).
- [10078177](https://github.com/appsignal/appsignal-elixir/commit/1007817782db6c59377eb7c61f24e884b200affb) patch - Add the Erlang scheduler utilization to the metrics reported by the minutely probes. The metric is reported as a percentage value with the name `erlang_scheduler_utilization`, with the tag `type` set to `"normal"` and the tag `id` set to the ID of the scheduler in the Erlang VM.

### Changed

- [10078177](https://github.com/appsignal/appsignal-elixir/commit/1007817782db6c59377eb7c61f24e884b200affb) patch - Bump agent to v-5b63505
  
  - Only filter parameters with the `filter_parameters` config option.
  - Only filter session data with the `filter_session_data` config option.
- [10078177](https://github.com/appsignal/appsignal-elixir/commit/1007817782db6c59377eb7c61f24e884b200affb) patch - Remove the `valid` key from the diagnose output. It's not a configuration option that
  can be configured, but an internal state check if the configuration was considered valid.
- [10078177](https://github.com/appsignal/appsignal-elixir/commit/1007817782db6c59377eb7c61f24e884b200affb) patch - Print the extension installation dependencies and flags in the diagnose report output.
- [10078177](https://github.com/appsignal/appsignal-elixir/commit/1007817782db6c59377eb7c61f24e884b200affb) patch - Standardize diagnose validation failure message. Explain the diagnose request failed and why.
- [f3bb8546](https://github.com/appsignal/appsignal-elixir/commit/f3bb854629c9e075056a68fcfe52072f96752dc0) patch - Bump agent to v-0db01c2
  
  - Add `log_level` config option in extension.
  - Deprecate `debug` and `transaction_debug_mode` option in extension.

### Deprecated

- [4a9bcca3](https://github.com/appsignal/appsignal-elixir/commit/4a9bcca39e20370cc59560ba526618f5cb829ea4) patch - Deprecate "debug" and "transaction_debug_mode" config options in favor of the new "log_level"
  config option.

### Removed

- [f40ead99](https://github.com/appsignal/appsignal-elixir/commit/f40ead993de3dc80a825ef821eb481f2eb3ecd66) patch - Remove the unused allocation tracking config option.

### Fixed

- [10078177](https://github.com/appsignal/appsignal-elixir/commit/1007817782db6c59377eb7c61f24e884b200affb) patch - Fix a bug where setting the `:phoenix, :filter_parameters` configuration key to an allow-list of the form `{:keep, [keys]}` would apply this filtering to all sample data maps. The filtering is now only applied to the params sample data map.
- [10078177](https://github.com/appsignal/appsignal-elixir/commit/1007817782db6c59377eb7c61f24e884b200affb) patch - Fix the Push API key validator request query params encoding.
- [10078177](https://github.com/appsignal/appsignal-elixir/commit/1007817782db6c59377eb7c61f24e884b200affb) patch - When the Push API key config option value is an empty string,
  or a string with only whitespace characters, it is not considered valid anymore.
- [10078177](https://github.com/appsignal/appsignal-elixir/commit/1007817782db6c59377eb7c61f24e884b200affb) patch - Transmit the path file modes in the diagnose report as an octal number. Previously it send values like `33188` and now it transmits `100644`, which is a bit more human readable.
- [10078177](https://github.com/appsignal/appsignal-elixir/commit/1007817782db6c59377eb7c61f24e884b200affb) patch - Improve parameter and session data filtering options. Previously all filtering was done with one combined denylist of parameters and session data. Now `filter_parameters` only applies to parameters, and `filter_session_data` only applies to session data.
- [10078177](https://github.com/appsignal/appsignal-elixir/commit/1007817782db6c59377eb7c61f24e884b200affb) patch - Fix the download of the agent during installation when Erlang is
  using an OpenSSL version that does not support TLS 1.3, such as versions below OpenSSL 1.1.1.
- [ad0b00f1](https://github.com/appsignal/appsignal-elixir/commit/ad0b00f1030d5b80910a9dd7c73b80512762f27d) patch - Suppress a warning emitted by Telemetry 1.0.0, regarding the performance penalty of using local functions as event handlers, by specifying the module of the captured function.

## 2.2.7

- [f07f9cf9](https://github.com/appsignal/appsignal-elixir/commit/f07f9cf9c1d0d9696ee1a226630238dc75162fd7) patch - Bump agent to 09308fb.
  
  - Update sql_lexer dependency with support for reversed operators in queries.
  - Add debug level logging to custom metrics in transaction_debug_mode.
  - Add hostname config option to standalone agent.

## 2.2.6

- [acb7295](https://github.com/appsignal/appsignal-elixir/commit/acb7295f1b876659f4ac8535c4c50592c77c336d) patch - Print String values in the diagnose report surrounded by quotes, and booleans as "true" and "false", rather than "yes" and "no". Makes it more clear that it's a value and not a label we print.
- [e71792f](https://github.com/appsignal/appsignal-elixir/commit/e71792f9377a5ce98d338a63f2b0093a5ccee065) patch - Fix diagnose output rendering an additional empty line for the `appsignal.log` file. It appeared that only 9 lines were printed instead of the 10 expected lines.
- [422cbd1](https://github.com/appsignal/appsignal-elixir/commit/422cbd128ecfc24ad6891cc39f889f1d1c531602) patch - Render the install report errors in the diagnose CLI output fewer times. A missing download and/or install report could sometimes be displayed up to two times, in total four errors.
- [f7c0b1e](https://github.com/appsignal/appsignal-elixir/commit/f7c0b1e3f301e8eed72cadecdd9bf892c529173c) patch - Support mix task diagnose arguments. When an app is released with `mix release` CLI arguments cannot normally be passed to the diagnose task. Use the `eval` command pass along the CLI arguments as function arguments.
  
  ```
  mix format
  # Without arguments
  bin/your_app eval ':appsignal_tasks.diagnose()'
  # With arguments
  bin/your_app eval ':appsignal_tasks.diagnose(["--send-report"])'
  ```
- [c51c065](https://github.com/appsignal/appsignal-elixir/commit/c51c065c71e08c4876b94680659b96062b5273b3) patch - Update diagnose output labels to be similar to our other language integrations.
- [9d3e253](https://github.com/appsignal/appsignal-elixir/commit/9d3e25342cdf11ad8b6fb025209629552f816b1e) patch - Add new config option to enable/disable StatsD server in the AppSignal agent. This new config option is called `enable_statsd` and is set to `false` by default. If set to `true`, the AppSignal agent will start a StatsD server on port 8125 on the host.

## 2.2.5

- [e7d676a9](https://github.com/appsignal/appsignal-elixir/commit/e7d676a9832192f745bb331f2382857226768e36) patch - Update SSL configuration for OTP 23 and newer to fix the Cloudfront mirror download during installation.
- [7ccf75ce](https://github.com/appsignal/appsignal-elixir/commit/7ccf75cea16b634eca4140ed785508b82baa19b8) patch - Fix install result message to no longer show a success message when an installation failure occurred.

## 2.2.4

- [787684bf](https://github.com/appsignal/appsignal-elixir/commit/787684bf61dfdfca65bbb4bc70706942302dd80e) patch - Installation report improved for download errors. Download errors are more descriptive in the installation result of the diagnose report.

## 2.2.3

- [b89ab7bc](https://github.com/appsignal/appsignal-elixir/commit/b89ab7bc7958319e60c9ee1e7edf5664d8fc8973) patch - Bump agent to 7376537
  
  - Support JSON PostgreSQL operator in sql_lexer.
  - Do not strip comments from SQL queries.

## 2.2.2

- [c6772da3](https://github.com/appsignal/appsignal-elixir/commit/c6772da3dca036c020864303044aa4f265c6b18e) patch - Fix extension installer from cached source in `/tmp` directory. This would cause installation errors of the package if the AppSignal package was reinstalled again on a host that already installed it once.

## 2.2.1

- [a7987f3](https://github.com/appsignal/appsignal-elixir/commit/a7987f31d110893e10255f4593b9137328245f34) patch - Add mirrors to download the agent

## 2.2.0

- [1d7b7a3](https://github.com/appsignal/appsignal-elixir/commit/1d7b7a3f560321a2056126be1ebbb3715ac823b5) minor - Use underscores instead of slashes in spans created from decorators. This will change action naming from `Module.function/1` to `Module.function_1`.
- [7927a3f](https://github.com/appsignal/appsignal-elixir/commit/7927a3fc6e2f3ce4f1ca150d2dd6123d08e40967) patch - Bump agent to v-0318770.
  
  - Improve Dokku platform detection. Do not disable host metrics on
    Dokku.
  - Report CPU steal metric.

## 2.1.15

- [325c985](https://github.com/appsignal/appsignal-elixir/commit/325c98540407fe29d757c0438066ca265ce70502) patch - Add support for telemetry 1.0.0

## 2.1.14

- [231abb13](https://github.com/appsignal/appsignal-elixir/commit/231abb135f962bd3fb8c18c781325bf04d07e9f5) patch - Bump agent to 0f40689
  
  - Add Apple Darwin ARM alias.
  - Improve appsignal.h documentation.
  - Improve transaction debug log for errors.
  - Fix agent zombie/defunct issue on containers without process reaping.

## 2.1.13

- [2531288d](https://github.com/appsignal/appsignal-elixir/commit/2531288dd6e8b5e76572b8d83045bbb4118fadfa) patch - Fix Apple ARM detection. It wasn't properly detected as an Apple ARM host because the installer did not account for an architecture String a without 32/64-bit indicator.

## 2.1.12

- [0e2cd629](https://github.com/appsignal/appsignal-elixir/commit/0e2cd6290abf284672582c9ecaf033e764ad7165) patch - Only create root spans from transaction and channel action decorators, as they're meant to only be used when no span exists yet.

## 2.1.11

- [4ba38f9](https://github.com/appsignal/appsignal-elixir/commit/4ba38f90cbc762114649c02ed01a5740381d184b) patch - Bump agent to v-891c6b0. Add experimental Apple Silicon M1 ARM64 build.

## 2.1.10

- [523e229e](https://github.com/appsignal/appsignal-elixir/commit/523e229e7dee8ea76bfc46d43898f5a8667368ad) patch - Bump agent to version that is compatible with different error grouping
  types.

## 2.1.9

- [76a31400](https://github.com/appsignal/appsignal-elixir/commit/76a314002321bc9a2df00fff66b549c61262f691) patch - Add Linux ARM override value to diagnose report. This was omitted from the original implementation of the `APPSIGNAL_BUILD_FOR_LINUX_ARM` flag.
- [07d1ea17](https://github.com/appsignal/appsignal-elixir/commit/07d1ea17cc76e3407ae7dc81da030c9362122eca) patch - Bump agent to c2024bf with appsignal-agent diagnose timing issue fix when reading the report and improved filtering for HTTP request transmission logs.

## 2.1.8

- [b2c888dc](https://github.com/appsignal/appsignal-elixir/commit/b2c888dc3a0c18ccde5e496995204a2ca1854b57) patch - Update `APPSIGNAL_BUILD_FOR_MUSL` behavior to only listen to the values `1` and `true`. This way `APPSIGNAL_BUILD_FOR_MUSL=false` is not interpreted to install the musl build.
- [f467daf9](https://github.com/appsignal/appsignal-elixir/commit/f467daf9f8da435139a6b5e0d232b17927c07675) patch - Add Linux ARM 64-bit experimental build, available behind a feature flag. To test this set the `APPSIGNAL_BUILD_FOR_LINUX_ARM` flag before compiling your apps: `export APPSIGNAL_BUILD_FOR_LINUX_ARM=1 <command>`. Please be aware this is an experimental build. Please report any issue you may encounter at our [support email](mailto:support@appsignal.com).
- [b8075176](https://github.com/appsignal/appsignal-elixir/commit/b8075176ed5fc4afac90ab2b788ba6397b41a814) patch - Use `MapSet`s for `Monitor`'s internal monitor list. As uniqueness is guaranteed (you can't monitor a particular pid more than once), MapSet is a better data structure to store this information, since all its operations are constant-time instead of linear-time.
- Track `erlang_atoms` gauge in erlang probe. This reports the `atom_limit` and `atom_count` metrics. PR #651

## 2.1.7
- Keep internal list of monitors in Appsignal.Monitor process. PR 648

## 2.1.6
- Fix `Appsignal.logger` debug level issue on no config present. PR #644
- Bump agent to d08ae6c. PR #645. Fix span API related issues with empty events
  for error samples and missing incidents.

## 2.1.5
- Add `Appsignal.Logger` to only log debug messages when the `:debug` configuration is turned on. PR #642

## 2.1.4
- Ensure the `:request_headers` config returns an empty list by default. PR #637

## 2.1.3
- Use pid from conn in Error.Backend if available. PR #631

## 2.1.2
- Make sure Appsignal.se(nd|t)_error is properly delegated. PR #629

## 2.1.1
- Probes.handle_info/2 handles non-exception errors. PR #626

## 2.1.0
- Pass functions to set error  PR #622
- Pass Elixir exceptions to `Appsignal.Instrumentation.se(t|nd)_error/2`. PR #620

## 2.0.8
- Clear warnings. PR #623

## 2.0.7
- Let set error use root span. PR (#611)
- Bump agent to v-44e4d97
  - Implement ignore namespaces for spans. PR #645

## 2.0.6
- Monitor all registered spans. PR #608
- Switch to reference-based child Span API, fixes memory leak when using
  child spans. PR #607

## 2.0.5
- Don't register query spans without parents. PR #600

## 2.0.4
- Bump agent to v-c55fb2c
  - Fix ignore actions and spans without names bugs. PR #639

## 2.0.3
- Bump agent to v-f9d2b57
  - Add error counts to map for spans. PR #638

## 2.0.2
- Use "channel" namespace in channel_action decorator. PR #596

## 2.0.1
- Ignore unhandled info, code_change and terminate in Error.Backend. PR #594
- Explicitly ignore returns from Span functions. PR #593

## 2.0.0
- Set categories from `transaction_event/3` decorator fallback. PR #583
- Remove Plug and Phoenix fallbacks in favour of post-install message. PR #582
- Bump agent to v-881e3b3
  - Agent writes diagnose to file, extension reads from file. PR #628
  - Ignore actions when creating span payload. PR #630
  - Update Cargo.lock after bumping probes-rs and running cargo update. PR #633
- Bump agent to v-5b16a75
  - Fixed a version mismatch issue in the agent which caused no samples to be processed
- Bump agent to v-38010f3
  - Use Rust 1.46.0 and spawn agent without waiting for it. PR #618
- Set category names in demo command
  Commit dd5a4c019f403a5c55be0f4f07bda8d85385aef4
- Add Repo configuration. PR #578
- Link AppSignal config when config/config.exs does not exist. PR #577
- Set category from Appsignal.Instrumentation.instrument/3
  Commit  c8a789e9ff5dfe0d5a522448a923f94a1f54b63d
- Add debug log lines on handler attachment
  Commit 44f594dc6c4fa00b0ecb329aea16907cb106a67a
  Commit 23a9cd0bf063e96c9b87ca2b2cf797ab96d4f96b
  Commit a0ac8566f1d200152748b98f938ba78813767f9e
- Bump agent to v-c8f8185. PR #575
- Implement _set_span_namespace. PR #576
- Tracer handles registry being down
  Commit 86e433e42ebfd080d5a1f8450f9a29784ef2d4d9
- Handle nil-spans in span.set_namespace/2
  Commit d0f5d9d96890f0caaa80c58c7a34a343b722591e
- Restore Appsignal.send_error/3 and Appsignal.set_error/3. PR #574
- Remove unused module attributes from Appsignal module
- Switch to span-based API
- Reimplement error handling
- Reimplement Ecto integration
- Split out Plug integration into separate library
- Split out Phoenix integration into separate library
- Bump agent to v-a21a12a

## 1.13.5
- Bump agent to v-20f7d0d
  - Spawn agent without waiting for it. PR #618
  - Agent writes diagnose to file, extension reads from file. PR #628

## 1.13.4
- Bump agent to v-4548c88
  - Fix issue with host metrics values being reported as "Infinity". PR #572

## 1.13.3
- Add callback for `TransactionBehaviour.set_sample_data/2`. PR #560
- Use tls 1.3 cipher suites on OTP 23. PR #571

## 1.13.2
- Handle non-string-non-atom-non-iteger values in Transaction.to_s/1
  Commit 772cb943b6d545942a50042a268d441973adab23

## 1.13.1
- Use `__STACKTRACE__ /0` on Elixir >= 1.7. PR 559
- Relax live_view dependency to allow versions over 0.9. PR #558
- Bump agent to v-96b684b
  - Check if queued payloads are for correct app and not expired

## 1.13.0
- Add LiveView instrumentation helpers. PR #549
- Fix typespec for Appsignal.Phoenix.Channel.channel_action/4. PR #553
- Add record event callback to TransactionBehaviour. PR #555

## 1.12.1
- EventHandler handles router_dispatch events with plug_opts #547

## 1.12.0
- Add explicit error handling for Phoenix channels. PR #527
- Add Phoenix Telemetry event handler to add Phoenix 1.5 instrumentation. PR #528 & #538

  Before version Phoenix version 1.5. AppSignal’s Phoenix instrumentation
  depended on data from the Phoenix instrumenter, and the installation
  instructions included a step to attach AppSignal’s instrumenter to your
  application in your app’s configuration:

      config :appsignal_phoenix_example, AppsignalPhoenixExampleWeb.Endpoint,
        #...
        instrumenters: [Appsignal.Phoenix.Instrumenter]

  From Phoenix 1.5 on, the old Phoenix instrumentation is deprecated and
  removed in favor of the new Telemetry-based instrumentation. When upgrading
  to Phoenix 1.5, you’ll see a warning during compilation when using the old
  instrumenters:

      [warn] :instrumenters configuration for
      AppsignalPhoenixExampleWeb.Endpoint is deprecated and has no effect

  To switch to the new instrumentation, make sure you're running version 1.12.0
  of the AppSignal integration or higher.  Then, remove the instrumenters
  configuration option from your endpoint configuration.  The new
  instrumentation should appear automatically in your samples as an event named
  call.phoenix_endpoint.

## 1.11.8
- Reduce calls to pids_and_monitor_references/1 and :ets.match/1 #543. PR #543

## 1.11.7
- Return the Ecto.LogEntry even if the transaction is nil. PR #542

## 1.11.6
- Call pids_and_monitor_references/1 from TransactionRegistry. PR #541

## 1.11.5
- Use a complete set of ssl_options for Hackney. PR #534

## 1.11.4
- Add transaction_debug configuration option. PR #526
- Bump agent to v-c348132
  - Improve transmitter logging on timeout
  - Improve queued payloads transmitter. Should prevent payloads being
    sent multiple times.
  - Add transaction debug mode
  - Wrap Option in Mutex in TransactionInProgess

## 1.11.3
- Transaction.set_action/2 returns the Transaction on failure. commit 16e5ecbc90aece993177da7e1b2486fa477e25e8
- Don't match on :ok on Appsignal.Plug.finish_with_conn/2. commit ebc7dd968a9bbeff3447e8f84dab181205f976ed

## 1.11.2
- Run receiver monitors in receiver process. PR #525.
- Move action nil-check to `Appsignal.Transaction.set_action/2`. PR #523.

## 1.11.1
- Don't match on return from `Transaction.complete/1`. PR #521

## 1.11.0
- Convert time units for all Ecto callbacks. PR #481
- Deactivate AppSignal when not active. PR #478
- Fix FreeBSD compilation. PR #484
- Extract ETS and Receiver logic from TransactionRegistry. PR #505
- Add support for both Jason and Poison. PR #506
- Add Erlang Run Queue length metric. PR #492
- Filter structs in MapFilter. PR #507

## 1.10.13
- OTP 22.1 hackney workaround for honor_cipher_order. PR #516
- Bump agent to v-690f4b8 - commit 5245f919d975135d553a89b019c421e1fe27edd3
  - Validate transmission_interval option.

## 1.10.12
- Bump agent to v-e1c9363
  - Better detect zombie/defunct processes on containers and consider the
    processes dead. This should improve the appsignal-agent start behavior.
  - Detect revision from Heroku dynos automatically when Dyno Metadata is
    turned on.

## 1.10.11
- Bump agent to v-a718022
  - Fix container CPU runtime metrics.
    See https://github.com/appsignal/probes-rs/pull/38 for more information.
  - Improve host metrics calculations accuracy for counter metrics.
    See https://github.com/appsignal/probes-rs/pull/40 for more information.
  - Support Kernel 4.18+ format of /proc/diskstats file parsing.
    See https://github.com/appsignal/probes-rs/pull/39 for more information.

## 1.10.10
- Restore get_filter_(parameters|session_data) to patch backwards compatibility. PR #500

## 1.10.9
- Support parameter filtering with {:keep, params}. PR #499

## 1.10.8
- Handle non-maps in Config.active?/0. PR #495
- Use Phoenix >= 1.2.0 and < 1.4.0 on Elixir 1.3. PR #496

## 1.10.7
- Fix musl detection on installation. PR #493

## 1.10.6
- Use the bundled certificate and ciphers when downloading agent (#491)
- Explicitly set ciphers in hackney https requests (#489)
- Remove log statements from TransactionRegisty (#490)
- Improve ldd version error handling (#487)

## 1.10.5
- Remove explicit ignore check in TransactionRegistry. PR #480
- Handle errors in Mix.Appsignal.Helper.uid/0. PR #479

## 1.10.4
- Handle atom keys in MapFilter.filter_values/2. PR #475

## 1.10.3
- Track memory metrics of the current process. PR #473

## 1.10.2
- Fix memory leak in custom metrics key names.
  Commit 91c65e51cc949e66b3f504444f3570858a598352

## 1.10.1
* Add enable_minutely_probes config option. PR #470
* Tag hostnames in ErlangProbe. PR #469
* Don't use fetch_env!/2 in ErlangProbe. PR #471

## 1.10.0
* Store extension installation details in report. PR #433
* Fail AppSignal extension installation on warnings
  Commit 7b17a0b86f87ea7097315d1247ccd52c78be8e97
* Rescue `make` command errors
  Commit 69efc629eaa0a3f3a3e2d8c3871f3c7bba86c151
* Add response status codes to Plug samples. PR #453
* Use :logger instead of :error_logger on OTP >= 21. PR #454
* Allow Appsignal.Plug.call/2 to be overridden. PR #464
* Use proxy from system environment when downloading agent. PR #458
* Bump agent to 4a275d3
  Commit 0635e043d4b299d7ec838f89ca4d36c3ed3792ce
  - Support container CPU host metrics.
  - Support StatsD server in agent.
  - Fix samples being reported for multiple namespaces.
  - Report memory and swap usage in percent using the memory_usage and
    swap_usage metrics.
* Add Erlang Probe. PR #466
* Minutely Probing for Custom Metrics. PR #461

## 1.9.4
- Update Ecto integration to support both Telemetry 0.3.x and 0.4.x. PR #459

## 1.9.3
- Support send_params option. PR #456

## 1.9.2
- Fix multi user permission issue for agent directories and files.
  Commit fdd650097b702a8aa60ee90ee93ad4e3e3365d81

## 1.9.1
* Block on ignoring PIDs in TransactionRegistry. PR #448

## 1.9.0
* Add missing host OS field to diagnose report. PR #418
* Link back to AppSignal diagnose report page. PR #420
* Add `Error.metadata/2` to extract error metadata. PR #423
* Format values printed in the diagnose. PR #426
* Update diagnose paths section. PR #427
* Add unified ErrorHandler. PR #425
* Fix appsignal.log default path. PR #429
* Support container memory host metrics better. PR #431
* Change files_world_accessible permissions to not make files executable. PR #431
* Make agent debug logging for disk IO metrics more robust. PR #431

## 1.8.2
* Add Appsignal.Ecto.handle_event/4 to support Ecto 3. PR #416
* Add diagnose command --[no-]send-report option. PR #414
* Group extension and agent tests in diagnose output. PR #413
* Add new agent & extension diagnose report keys. PR #412
* Pretty print lists in diagnose output. PR #408
* Add :poison to :applications. PR #404
* Add :hackney to :applications. PR #403
* Allow Appsignal.send_error/1-7 to be called without a stack trace. PR #400
* Use `Mix.shell.info` instead of `Logger.info` in mix helpers. PR #399

## 1.8.1
* Fix linking issues on multi-stage build setups. PR #406

## 1.8.0
* Add working_directory_path config option. PR #363
* Use doubles values in custom metrics functions. PR #384
* Support Elixir 1.7. PR #386

## 1.7.2
* Ensure ca_file_path is written to agent env. PR #381
* Use gmake over make when gmake executable exists. PR #382

## 1.7.1
* Fix absolute path to CA certificate file. PR #380

## 1.7.0
* Bundle CA certificate. PR #364
* Add Appsignal.Transaction.set_namespace/1-2. PR #361
* Use :hackney instead of cURL to download agent. PR #359

## 1.6.7
* Revert container memory metrics fixes. PR #370
* Fix _APP_REVISION read logic in extension. PR #370
* Fix _APPSIGNAL_PROCESS_NAME read logic in extension. PR #370

## 1.6.6
* Add container memory metrics fixes.
* Use local agent environment instead of system environment. PR #368

## 1.6.5
* Allow calling `Transaction.register/1` and `Transaction.complete/1` when the Registry is not alive. PR #356

## 1.6.4
* Overwrite message for Phoenix.ActionClauseError. PR #355

## 1.6.3
* Remove script_name, query_string and peer from Plug.extract_sample_data/1. PR #351

## 1.6.2
* Merge instead of ignore Phoenix's :filter_parameters if also configured in AppSignal. PR #349

## 1.6.1
* Remove request_headers warning and use sane default. PR #346
* Fix metrics format for internal agent metrics. PR #347

## 1.6.0
* Explicit header whitelist in configuration (#336)
* Add filter_session_data config option (#343)
* Log with :info level instead of :warn when AppSignal is disabled (#340)
* Remove default hostname (#339)
* Remove filter_parameters config for extension (#337)
* Demonitor processes when the transaction completes (#333)
* Hard-remove transactions from the Registry (#332)
* Accept tags for (custom) metrics (#331)
* Don't register Transactions created by `Appsignal.send_error/7`  (#330)
* Remove transaction when calling `Transaction.complete` (#329)
* Add :request_headers and APPSIGNAL_REQUEST_HEADERS configuration (#327)
* Filter arguments in backtraces (#326)
* Relax :httpoison dependency to allow ~> 1.0 (#322)

## 1.5.0
* Add agent.exs file to package in mix.exs (#323)
* Restore :revision config (#315)
* Underscored environment variables are always overwritten (#316)
* Move compilation helper functions to mix_helpers.exs (#314)
* Use "unknown" as action for Plug-only transactions, set action before `call/2` (#311)
* Bump agent to ca32965 (#310, #315)
  - Underscore `_APP_REVISION` environment variable.
  - Unset revision config option when the APP_REVISION environment
    variable only contains an empty string.
  - Fix locking issue on diagnose mode run
  - Increase stored length of error messages

## 1.4.10
* Fix POST parameters in errors, take the Plug.Conn from Plug.Conn.WrapperErrors (#309)

## 1.4.9
* Add x-real-ip to request header whitelist (#308)
* ErrorHandler doesn't cause warnings for noise over handle_info (#304)

## 1.4.8
* Fix transaction metadata for send_error (#303)
* Use Application.load/1 in diagnose task (#297)
* Fix DataEncoder.encode error (#293)
* Update agent to fix locking issue in diagnose (#300)

## 1.4.7
* Fix compile errors on Elixir 1.6 (#298)

## 1.4.6
* Wrap WrapperError clause in Appsignal.plug? (#291)
* Don't use Plug.ErrorHandler.__catch__/4 in Appsignal.Plug (#287)

## 1.4.5
* Ensure the appsignal application is started when running diagnose (#286)

## 1.4.4
* ErrorHandler unwraps Plug.Conn.WrapperError (#281)
* Fetch request_id in Appsignal.Plug.extract_meta_data/1 (#283)

## 1.4.3
* Fix dialyzer linting violations. (#271)
* Fix logger error on failed installation. (#275)
* Reuse Appsignal.agent module by unloading it after use in `mix.exs`. (#277)

## 1.4.2
* Change log level from info to debug for value comparing failures.
  Commit 76fafebba5e37cfd2c303c286271f4616cf63bd3
* Collect free memory host metric.
  Commit 76fafebba5e37cfd2c303c286271f4616cf63bd3

## 1.4.1
* Use musl build for older systems (#274)

## 1.4.0
* Add separate GNU linux build. PR #265 and
  Commit b9546cae01cd89d597586ad6c7dc4b5213fe2fca
* Add separate FreeBSD build
  Commit b9546cae01cd89d597586ad6c7dc4b5213fe2fca
* Auto restart agent when none is running
  Commit b9546cae01cd89d597586ad6c7dc4b5213fe2fca

## 1.3.6
* Fix crashes when using a transaction from multiple processes in an unsupported way.
  Commit b9546cae01cd89d597586ad6c7dc4b5213fe2fca
* Allow string values in atom config fields (#269)

## 1.3.5
* Allow multiple calls to `send_error` in one Transaction (#260)

## 1.3.4
* Allow configuration of permissions of working directory. (#246)
* Fix locking bug that delayed extension shutdown.
  Commit 1953b2abced8c477af3eb973cc71b98c20761b51
* Log extension start with app revision if present
  Commit 1953b2abced8c477af3eb973cc71b98c20761b51

## 1.3.3
* No channel payloads in the channel_action decorator (#255)
* Add architecture for elixir:alpine Docker image (#256)

## 1.3.2
* Don't crash with unbound channel payloads (#253)

## 1.3.1

* Appsignal.Phoenix.Channel.channel_action/5 includes channel parameters (#251)
* Add files world accessible option to config (#246)

## 1.3.0

* Plug support without Phoenix
* Transaction.set_request_metadata sets path and method
* Add arch mapping for 32bit linux
* Check if curl is installed before calling it
* Add ignore_namespaces option
* Whitelist request headers

## 1.2.3

* Add architecture mappings for 32bit systems. (#229)

## 1.2.2

* Better backtraces for linked processes (#207)
* Backtrace.format_stacktrace handles lists of binaries (#214)

## 1.2.1

* Allow nil transaction in instrumentation (#198)
* ErrorHandler handles errors in tuples (#201)
* Set `env: Mix.env` in generated config.exs (#203)
* Improve registry lookup performance (#205)

## 1.2.0

* Catch and handle errors in the Plug using Plug.ErrorHandler instead of
  in Appsignal.ErrorHandler (#187 & #193)

## 1.1.1
* Fix unpacking agent tar as root (#179)
* Add Instrumentation.Helpers.instrument/3
* Add Appsignal.Backtrace, deprecate ErrorHandler.format_stack/1

## 1.1.0
* Depend on Phoenix >= 1.2.0 instead of ~> 1.2.0 (#167)
* Reload the config in a separate process (#166)
* Add action names to exceptions (#162)

## 1.0.4
* Fix propagation of transaction decorator return value (#164)

## 1.0.3
* Force the agent to run in diagnostics mode even if the app's config doesn't
  have AppSignal marked as active. (#132 and #160)
* Remove duplicate config file linking output in installer (#159)
* Upon install deactivate test env if available rather than activate any other
  env (#159)
* Print missing APPSIGNAL_APP_ENV env var in installation instructions. (#161)

## 1.0.2
* Remove extra comma from generated config/appsignal.exs (#158)

## 1.0.1
* Remove (confusing revision logic) (#154)

## 1.0.0
* Bump to 1.0.0 🎉

## 0.13.0
* Send demo samples on install (#136)
* Make mix tasks available in releases (#146)
* Rename Phoenix framework event names (#148)
* Open and close Transactions in Appsignal.Phoenix.Plug.call/2 (#131)

## 0.12.3
* Move package version to a module attribute (#143)

## 0.12.2
* Bump agent to 5464697
* Check agent version in Mix.Appsignal.Helper.ensure_downloaded/1 (#141)

## 0.12.1
* Upgrade HTTPoison and allow more versions

## 0.12.0
* Add mix appsignal.diagnose task (#81)
* Auto activate when push_api_key in env, not always (#89)
* Bump agent to f81fe90
* Implement running_in_container detection.
* Fix DNS issue with musl and resolv.conf using "search" on the first line of configuration.
* Use agent.ex instead of agent.json, drop Poison dependency (#115)
* DataEncoder encodes bignums as strings (#88)
* Remove automatic :running_in_container setting (moved to agent)

## 0.11.6
* Send body->data instead of body to appsignal_finish_event

## 0.11.5
* Bump agent to version with extra null pointer protection

## 0.11.4
* Bump agent (360f06b)

## 0.11.3
* Update musl version to fix DNS search issue (a8e6f23)

## 0.11.2
* Add support for non-strings as map values in DataEncoder.encode/1 (#83)

## 0.11.1
* Add phoenix as optional dependency to :prod (#80)
* Add the module name to the transaction action while using decorators (#79)

## 0.11.0
* Re-initialize Appsignal's config after a hot code upgrade. (#71)
* Send all request headers (#75)
* Add ErrorHandler.normalize_reason (#78)
* Elixir 1.4 compatibility
* Add fix for grabbing filter_parameters from Phoenix (#73)
* Add Alpine linux (#77)
* Add appsignal.demo mix task (#69)
* Drop Phoenix dependency #61

## 0.10.0
* Check Appsignal.started?/1 in TransactionRegistry.lookup/2 (#54)
* Various configuration fixes (#55)
* Use APPSIGNAL_APP_ENV instead of APPSIGNAL_ENVIRONMENT (#56)
* The agent logs to STDOUT on Heroku (#60)
* Add a transcation decorator (#62)
* Update agent to 5f0c552 (#64)
* Enable host metrics by default (#66)
* DataEncoder.encode/2 handles tuples (#68)
* Registry.register/1 returns nil if Appsignal is not started (#70)
* Appsignal.Transaction.set_error/4 handles unformatted stacktraces (#72)
* Fix missing paren warnings in Elixir 1.4 (#59)
* Add support to refs and pids inside payloads (#57)
* Add centos/redhat support for agent installation (#48)

## 0.9.2
* Fix Makefile for spaces in path names
* Set APPSIGNAL_IGNORE_ACTIONS from config (#41)
* Send metadata in Appsignal.ErrorHandler.submit_transaction/6 (#40)
* Add a section suggesting active: false in test env (#35)

## 0.9.1
* Appsignal.Helpers has been moved to Appsignal.Instrumentation.Helpers

## 0.9.0
* Remove instrumentation macros, switch to decorators
* Update channel decorators documentation
* Documentation on instrumentation decorators
* Let Appsignal.{set_gauge, add_distribution_value} accept integers (#31)
* Implement Appsignal.send_error (#29)
* Add documentation for filtered parameters (#28)
* Appsignal.Utils.ParamsEncoder.preprocess/1 handles structs (#30)

## 0.8.0
* Experimental support for channels
* Add instrument_def macro for defining a single instrumented function
* Document that we are using a NIF and how it is used
* Simplified transaction functions no longer raise
* Don't warn about missing config when running tests
* remember original stacktrace in phoenix endpoint (#26)

## 0.7.0
* Allow Phoenix filter parameters and/or OS env variable to be used
* Send Phoenix session information
* Simplify Transaction API: Default to the current process transaction
* Add Transaction.filter_values/2
* Transaction.set_request_metadata/2 filters parameters
* Fix host metrics config key in GettingStarted
