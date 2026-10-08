defmodule Appsignal.Error.Reported do
  @moduledoc false

  # Errors reported through `Appsignal.Span.add_error`, by process and stack
  # trace, so that the error backend skips the crash report that follows.
  # The stack trace is the part of an error that reaches the backend unchanged:
  # Plug and Phoenix re-raise errors wrapped, and Broadway logs them normalised.
  # A crash report can arrive after its process has died, or long after the
  # error in a process that keeps running, so entries expire by age.

  alias Appsignal.{Config, Span}

  @table __MODULE__
  @expiry Application.compile_env(:appsignal, :deletion_delay, 5_000)

  def new do
    :ets.new(@table, [:named_table, :public, :set])
  end

  def record(%Span{pid: pid}, [_ | _] = stacktrace) do
    if Config.error_backend_enabled?() do
      try do
        :ets.insert(@table, {{pid, :erlang.phash2(stacktrace)}, now()})
      rescue
        ArgumentError -> false
      end
    end
  end

  def record(_span, _stacktrace), do: nil

  def reported?(pid, [_ | _] = stacktrace) do
    case lookup({pid, :erlang.phash2(stacktrace)}) do
      [{_key, recorded_at}] -> now() - recorded_at <= @expiry
      [] -> false
    end
  end

  def reported?(_pid, _stacktrace), do: false

  def sweep do
    expired = now() - @expiry

    try do
      :ets.select_delete(@table, [{{:_, :"$1"}, [{:<, :"$1", expired}], [true]}])
    rescue
      ArgumentError -> 0
    end
  end

  defp lookup(key) do
    try do
      :ets.lookup(@table, key)
    rescue
      ArgumentError -> []
    end
  end

  defp now, do: System.monotonic_time(:millisecond)
end
