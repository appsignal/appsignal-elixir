:error_logger.tty(false)
ExUnit.configure(exclude: [pending: true])
ExUnit.start()
{:ok, _} = Application.ensure_all_started(:bypass)
