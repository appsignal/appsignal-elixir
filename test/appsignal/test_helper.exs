# Make sure the Appsignal.System module is recompiled in the test environment
# by unloading it first.
# Otherwise, it would use the already compiled Appsignal.System module loaded
# in `mix.exs` and not have FakeOS configured as `@os`.
AppsignalTest.Utils.purge(Appsignal.SystemBehaviour)
AppsignalTest.Utils.purge(Appsignal.System)

:error_logger.tty(false)
excludes = [String.to_atom("skip_env_#{Mix.env()}"), :skip]
ExUnit.start(exclude: excludes)
