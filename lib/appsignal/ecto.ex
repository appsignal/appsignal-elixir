defmodule Appsignal.Ecto do
  @moduledoc """
  Integration for logging Ecto queries

  To add query logging, add the following to you Repo configuration in `config.exs`:

  ```
  config :my_app, MyApp.Repo,
    loggers: [Appsignal.Ecto]
  ```

  """

  require Logger

  @micro_seconds :erlang.convert_time_unit(1, :micro_seconds, :native)


  def log(entry) do
    t = entry.query_time / @micro_seconds
    Logger.info "Ecto log: #{entry.query}, #{t}"
    entry
  end

end
