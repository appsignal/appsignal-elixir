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

  alias Appsignal.{Transaction, Backtrace}

  @doc """
  Retrieve the last Appsignal.Transaction.t that the error logger picked up
  """
  @spec get_last_transaction :: Transaction.t() | nil
  def get_last_transaction do
    :gen_event.call(:error_logger, Appsignal.ErrorHandler, :get_last_transaction)
  end

  def init(_) do
    # state of the error handler holds the last matched transaction
    {:ok, nil}
  end

  def handle_event(event, state) do
    state =
      case match_event(event) do
        {origin, reason, message, stack, conn} ->
          transaction = Transaction.lookup_or_create_transaction(origin)

          if transaction != nil do
            submit_transaction(transaction, reason, message, stack, %{}, conn)
          end

        :nomatch ->
          state
      end

    {:ok, state}
  end

  def handle_info(_, state) do
    {:ok, state}
  end

  def submit_transaction(transaction, reason, message, stack, metadata, conn \\ nil)

  def submit_transaction(transaction, reason, message, stack, metadata, nil) do
    Transaction.set_error(transaction, reason, message, stack)
    Transaction.set_meta_data(transaction, metadata)
    Transaction.finish(transaction)
    Transaction.complete(transaction)

    Logger.debug(fn ->
      "Submitting #{inspect(transaction)}: #{message}"
    end)

    transaction
  end

  if Appsignal.plug?() do
    def submit_transaction(transaction, reason, message, stack, metadata, conn) do
      if conn do
        Transaction.set_request_metadata(transaction, conn)
      end

      submit_transaction(transaction, reason, message, stack, metadata)
    end
  end

  def handle_call(:get_last_transaction, state) do
    {:ok, state, state}
  end

  @doc false
  @spec match_event(term) :: {pid, term, String.t(), list, %{}} | :nomatch
  def match_event({:error_report, _gleader, {origin, :crash_report, [report | _]}})
      when is_list(report) do
    try do
      {exception, stack} = match_error_info(report[:error_info])

      {reason, message, backtrace} = Appsignal.Error.metadata(exception, stack)
      {origin, reason, message, backtrace, nil}
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

  defp match_error_info({_kind, {exception, maybe_stack}, stack}) do
    if stacktrace?(maybe_stack) do
      {exception, maybe_stack}
    else
      {{exception, maybe_stack}, stack}
    end
  end

  defp match_error_info({_kind, exception, stack}), do: {exception, stack}

  defp stacktrace?(stacktrace) when is_list(stacktrace) do
    Enum.all?(stacktrace, &stacktrace_line?/1)
  end

  defp stacktrace?(_), do: false

  defp stacktrace_line?({_, _, _, [file: _, line: _]}), do: true
  defp stacktrace_line?(_), do: false

  @doc false
  def format_stack(stacktrace) do
    IO.warn(
      "Appsignal.ErrorHandler.format_stack/1 is deprecated. Use Appsignal.Backtrace.from_stacktrace/1 instead."
    )

    Backtrace.from_stacktrace(stacktrace)
  end

  @deprecated "Use Appsignal.Error.metadata/2 instead."
  def extract_reason_and_message(any, prefix) do
    {name, message, _} = Appsignal.Error.metadata(any, [])
    {name, prefixed(prefix, message)}
  end

  defp prefixed(nil, msg), do: msg
  defp prefixed("", msg), do: msg
  defp prefixed(pre, msg), do: pre <> ": " <> msg

  @pid_or_ref_regex ~r/\<(\d+\.)+\d+\>/
  @deprecated "Use Appsignal.Error.metadata/2 instead."
  def normalize_reason(reason) do
    Regex.replace(@pid_or_ref_regex, reason, "<...>")
  end
end
