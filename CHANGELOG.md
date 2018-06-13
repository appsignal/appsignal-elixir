# 1.7.0 Alpha 4
* Fix reporting of memory host metrics for containerized hosts. PR #353
* Detect Kubernetes containers as containers in probes-rs library.
  Commit c58af6c4d72019427ef209112ad6920a9159c0de.
* Detect Kubernetes containers as containers for `running_in_container`
  config option. Commit c58af6c4d72019427ef209112ad6920a9159c0de.

# 1.6.4
* Overwrite message for Phoenix.ActionClauseError. PR #355

# 1.6.3
* Remove script_name, query_string and peer from Plug.extract_sample_data/1. PR #351

# 1.6.2
* Merge instead of ignore Phoenix's :filter_parameters if also configured in AppSignal. PR #349

# 1.6.1
* Remove request_headers warning and use sane default. PR #346
* Fix metrics format for internal agent metrics. PR #347

# 1.6.0
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

# 1.5.0
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

# 1.4.10
* Fix POST parameters in errors, take the Plug.Conn from Plug.Conn.WrapperErrors (#309)

# 1.4.9
* Add x-real-ip to request header whitelist (#308)
* ErrorHandler doesn't cause warnings for noise over handle_info (#304)

# 1.4.8
* Fix transaction metadata for send_error (#303)
* Use Application.load/1 in diagnose task (#297)
* Fix DataEncoder.encode error (#293)
* Update agent to fix locking issue in diagnose (#300)

# 1.4.7
* Fix compile errors on Elixir 1.6 (#298)

# 1.4.6
* Wrap WrapperError clause in Appsignal.plug? (#291)
* Don't use Plug.ErrorHandler.__catch__/4 in Appsignal.Plug (#287)

# 1.4.5
* Ensure the appsignal application is started when running diagnose (#286)

# 1.4.4
* ErrorHandler unwraps Plug.Conn.WrapperError (#281)
* Fetch request_id in Appsignal.Plug.extract_meta_data/1 (#283)

# 1.4.3
* Fix dialyzer linting violations. (#271)
* Fix logger error on failed installation. (#275)
* Reuse Appsignal.agent module by unloading it after use in `mix.exs`. (#277)

# 1.4.2
* Change log level from info to debug for value comparing failures.
  Commit 76fafebba5e37cfd2c303c286271f4616cf63bd3
* Collect free memory host metric.
  Commit 76fafebba5e37cfd2c303c286271f4616cf63bd3

# 1.4.1
* Use musl build for older systems (#274)

# 1.4.0
* Add separate GNU linux build. PR #265 and
  Commit b9546cae01cd89d597586ad6c7dc4b5213fe2fca
* Add separate FreeBSD build
  Commit b9546cae01cd89d597586ad6c7dc4b5213fe2fca
* Auto restart agent when none is running
  Commit b9546cae01cd89d597586ad6c7dc4b5213fe2fca

# 1.3.6
* Fix crashes when using a transaction from multiple processes in an unsupported way.
  Commit b9546cae01cd89d597586ad6c7dc4b5213fe2fca
* Allow string values in atom config fields (#269)

# 1.3.5
* Allow multiple calls to `send_error` in one Transaction (#260)

# 1.3.4
* Allow configuration of permissions of working directory. (#246)
* Fix locking bug that delayed extension shutdown.
  Commit 1953b2abced8c477af3eb973cc71b98c20761b51
* Log extension start with app revision if present
  Commit 1953b2abced8c477af3eb973cc71b98c20761b51

# 1.3.3
* No channel payloads in the channel_action decorator (#255)
* Add architecture for elixir:alpine Docker image (#256)

# 1.3.2
* Don't crash with unbound channel payloads (#253)

# 1.3.1

* Appsignal.Phoenix.Channel.channel_action/5 includes channel parameters (#251)
* Add files world accessible option to config (#246)

# 1.3.0

* Plug support without Phoenix
* Transaction.set_request_metadata sets path and method
* Add arch mapping for 32bit linux
* Check if curl is installed before calling it
* Add ignore_namespaces option
* Whitelist request headers

# 1.2.3

* Add architecture mappings for 32bit systems. (#229)

# 1.2.2

* Better backtraces for linked processes (#207)
* Backtrace.format_stacktrace handles lists of binaries (#214)

# 1.2.1

* Allow nil transaction in instrumentation (#198)
* ErrorHandler handles errors in tuples (#201)
* Set `env: Mix.env` in generated config.exs (#203)
* Improve registry lookup performance (#205)

# 1.2.0

* Catch and handle errors in the Plug using Plug.ErrorHandler instead of
  in Appsignal.ErrorHandler (#187 & #193)

# 1.1.1
* Fix unpacking agent tar as root (#179)
* Add Instrumentation.Helpers.instrument/3
* Add Appsignal.Backtrace, deprecate ErrorHandler.format_stack/1

# 1.1.0
* Depend on Phoenix >= 1.2.0 instead of ~> 1.2.0 (#167)
* Reload the config in a separate process (#166)
* Add action names to exceptions (#162)

# 1.0.4
* Fix propagation of transaction decorator return value (#164)

# 1.0.3
* Force the agent to run in diagnostics mode even if the app's config doesn't
  have AppSignal marked as active. (#132 and #160)
* Remove duplicate config file linking output in installer (#159)
* Upon install deactive test env if available rather than activate any other
  env (#159)
* Print missing APPSIGNAL_APP_ENV env var in installation instructions. (#161)

# 1.0.2
* Remove extra comma from generated config/appsignal.exs (#158)

# 1.0.1
* Remove (confusing revision logic) (#154)

# 1.0.0
* Bump to 1.0.0 🎉

# 0.13.0
* Send demo samples on install (#136)
* Make mix tasks available in releases (#146)
* Rename Phoenix framework event names (#148)
* Open and close Transactions in Appsignal.Phoenix.Plug.call/2 (#131)

# 0.12.3
* Move package version to a module attribute (#143)

# 0.12.2
* Bump agent to 5464697
* Check agent version in Mix.Appsignal.Helper.ensure_downloaded/1 (#141)

# 0.12.1
* Upgrade HTTPoison and allow more versions

# 0.12.0
* Add mix appsignal.diagnose task (#81)
* Auto activate when push_api_key in env, not always (#89)
* Bump agent to f81fe90
* Implement running_in_container detection.
* Fix DNS issue with musl and resolv.conf using "search" on the first line of configuration.
* Use agent.ex instead of agent.json, drop Poison dependency (#115)
* DataEncoder encodes bignums as strings (#88)
* Remove automatic :running_in_container setting (moved to agent)

# 0.11.6
* Send body->data instead of body to appsignal_finish_event

# 0.11.5
* Bump agent to version with extra null pointer protection

# 0.11.4
* Bump agent (360f06b)

# 0.11.3
* Update musl version to fix DNS search issue (a8e6f23)

# 0.11.2
* Add support for non-strings as map values in DataEncoder.encode/1 (#83)

# 0.11.1
* Add phoenix as optional dependency to :prod (#80)
* Add the module name to the transaction action while using decorators (#79)

# 0.11.0
* Re-initialize Appsignal's config after a hot code upgrade. (#71)
* Send all request headers (#75)
* Add ErrorHandler.normalize_reason (#78)
* Elixir 1.4 compatibility
* Add fix for grabbing filter_parameters from Phoenix (#73)
* Add Alpine linux (#77)
* Add appsignal.demo mix task (#69)
* Drop Phoenix dependency #61

# 0.10.0
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
* Add suport to refs and pids inside payloads (#57)
* Add centos/redhat support for agent installation (#48)

# 0.9.2
* Fix Makefile for spaces in path names
* Set APPSIGNAL_IGNORE_ACTIONS from config (#41)
* Send metadata in Appsignal.ErrorHandler.submit_transaction/6 (#40)
* Add a section suggesting active: false in test env (#35)

# 0.9.1
* Appsignal.Helpers has been moved to Appsignal.Instrumentation.Helpers

# 0.9.0
* Remove instrumentation macros, switch to decorators
* Update channel decorators documentation
* Documentation on instrumentation decorators
* Let Appsignal.{set_gauge, add_distribution_value} accept integers (#31)
* Implement Appsignal.send_error (#29)
* Add documentation for filtered parameters (#28)
* Appsignal.Utils.ParamsEncoder.preprocess/1 handles structs (#30)

# 0.8.0
* Experimental support for channels
* Add instrument_def macro for defining a single instrumented function
* Document that we are using a NIF and how it is used
* Simplified transaction functions no longer raise
* Don't warn about missing config when running tests
* remember original stacktrace in phoenix endpoint (#26)

# 0.7.0
* Allow Phoenix filter parameters and/or OS env variable to be used
* Send Phoenix session information
* Simplify Transaction API: Default to the current process transaction
* Add Transaction.filter_values/2
* Transaction.set_request_metadata/2 filters parameters
* Fix host metrics config key in GettingStarted

