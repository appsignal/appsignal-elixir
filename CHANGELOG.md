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

