:error_logger.tty(false)
excludes = [String.to_atom("skip_env_#{Mix.env()}"), :skip]
ExUnit.start(exclude: excludes)
{:ok, _} = Application.ensure_all_started(:bypass)
