:error_logger.tty(false)
excludes = [String.to_atom("skip_env_#{Mix.env}"), pending: true]
ExUnit.start(exclude: excludes)
{:ok, _} = Application.ensure_all_started(:bypass)
