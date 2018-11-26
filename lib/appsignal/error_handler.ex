defmodule Appsignal.ErrorHandler do
  @moduledoc """
  Error handler which sends all crash reports to the AppSignal backend.

  When you add `:appsignal` to your application's dependencies, this
  error logger will automatically be installed. All processes that are
  supervised, like GenServers, Tasks, Agents, Supervisored will be
  monitored for crashes. In the case of a crash, the AppSignal error
  handler collects error information and sends it to the backend.

  """

  require Logger

  alias Appsignal.{Backtrace, Error, TransactionRegistry}

  @transaction Application.get_env(
                 :appsignal,
                 :appsignal_transaction,
                 Appsignal.Transaction
               )

  def init(state) do
    {:ok, state}
  end

  def handle_event(event, state) do
    case match_event(event) do
      {origin, exception, stacktrace, conn} ->
        transaction =
          unless TransactionRegistry.ignored?(origin) do
            @transaction.lookup_or_create_transaction(origin)
          end

        if transaction != nil do
          handle_error(transaction, exception, stacktrace, conn)
        end

      _ ->
        :ok
    end

    {:ok, state}
  end

  def handle_info(_, state) do
    {:ok, state}
  end

  @spec handle_error(Appsignal.Transaction.t(), Exception.t(), Exception.stacktrace(), map()) ::
          :ok
  def handle_error(_, %{plug_status: status}, _, _) when status < 500, do: :ok

  def handle_error(transaction, exception, stack, conn) do
    {reason, message} = Appsignal.Error.metadata(exception)
    backtrace = Backtrace.from_stacktrace(stack)

    @transaction.set_error(transaction, reason, message, backtrace)

    if @transaction.finish(transaction) == :sample do
      @transaction.set_request_metadata(transaction, conn)
    end

    @transaction.complete(transaction)
  end

  def submit_transaction(transaction, reason, message, stack, metadata, conn \\ nil)

  def submit_transaction(transaction, reason, message, stack, metadata, nil) do
    @transaction.set_error(transaction, reason, message, stack)
    @transaction.set_meta_data(transaction, metadata)
    @transaction.finish(transaction)
    @transaction.complete(transaction)

    Logger.debug(fn ->
      "Submitting #{inspect(transaction)}: #{message}"
    end)

    transaction
  end

  if Appsignal.plug?() do
    def submit_transaction(transaction, reason, message, stack, metadata, conn) do
      if conn do
        @transaction.set_request_metadata(transaction, conn)
      end

      submit_transaction(transaction, reason, message, stack, metadata)
    end
  end

  @doc false
  @spec match_event(term) :: {pid, term, String.t(), list, %{}} | :nomatch
  def match_event({:error_report, _gleader, {origin, :crash_report, [report | _]}})
      when is_list(report) do
    try do
      {_kind, error, stack} = report[:error_info]
      {exception, backtrace} = Appsignal.Error.normalize(error, stack)
      {origin, exception, backtrace, %{}}
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

  def match_event(_event) do
    :nomatch
  end

  @doc false
  @deprecated "Use Appsignal.Backtrace.from_stacktrace/1 instead."
  def format_stack(stacktrace) do
    Backtrace.from_stacktrace(stacktrace)
  end

  @deprecated "Use Appsignal.Error.metadata/1 instead."
  def extract_reason_and_message(any, prefix) do
    {exception, _} = Error.normalize(any, [])
    {name, message} = Error.metadata(exception)
    {name, prefixed(prefix, message)}
  end

  defp prefixed(nil, msg), do: msg
  defp prefixed("", msg), do: msg
  defp prefixed(pre, msg), do: pre <> ": " <> msg

  @pid_or_ref_regex ~r/\<(\d+\.)+\d+\>/
  @deprecated "Use Appsignal.Error.metadata/1 instead."
  def normalize_reason(reason) do
    Regex.replace(@pid_or_ref_regex, reason, "<...>")
  end
end
