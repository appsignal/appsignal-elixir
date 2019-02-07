defmodule Appsignal.ErrorLoggerHandler do
  require Logger
  alias Appsignal.{TransactionRegistry, ErrorHandler}

  @transaction Application.get_env(
                 :appsignal,
                 :appsignal_transaction,
                 Appsignal.Transaction
               )

  def init(state) do
    {:ok, state}
  end

  def handle_event({:error_report, _gleader, {origin, :crash_report, [report | _]}}, state) do
    case match_report(report) do
      {error, stack} ->
        transaction =
          unless TransactionRegistry.ignored?(origin) do
            @transaction.lookup_or_create_transaction(origin)
          end

        if transaction != nil do
          ErrorHandler.handle_error(transaction, error, stack, %{})
        end

      _ ->
        :ok
    end

    {:ok, state}
  end

  def handle_event(_event, state) do
    {:ok, state}
  end

  def handle_info(_, state) do
    {:ok, state}
  end

  defp match_report(report) do
    try do
      {_kind, error, stack} = report[:error_info]
      {error, stack}
    rescue
      exception ->
        Logger.warn(fn ->
          """
          AppSignal: Failed to match error report: #{Exception.message(exception)}
          #{inspect(report[:error_info])}
          """
        end)

        :nomatch
    end
  end
end
