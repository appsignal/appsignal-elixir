:error_logger.tty(false)
excludes = [String.to_atom("skip_env_#{Mix.env}")]
ExUnit.start(exclude: excludes)
