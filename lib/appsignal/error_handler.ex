defmodule Appsignal.ErrorHandler do
  @moduledoc """
  Error handler which sends all crash reports to the AppSignal backend.

  When you add `:appsignal` to your application's dependencies, this
  error logger will automatically be installed. All processes that are
  supervised, like GenServers, Tasks, Agents, Supervisored will be
  monitored for crashes. In the case of a crash, the AppSignal error
  handler collects error information and sends it to the backend.

  """

  use GenEvent

  require Logger

  alias Appsignal.{Transaction, Backtrace}

  @doc """
  Retrieve the last Appsignal.Transaction.t that the error logger picked up
  """
  @spec get_last_transaction :: Transaction.t | nil
  def get_last_transaction do
    GenEvent.call(:error_logger, Appsignal.ErrorHandler, :get_last_transaction)
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
            submit_transaction(transaction, normalize_reason(reason), message, stack, %{}, conn)
          end
        :nomatch ->
          state
      end
    {:ok, state}
  end

  def submit_transaction(transaction, reason, message, stack, metadata, conn \\ nil)
  def submit_transaction(transaction, reason, message, stack, metadata, nil) do
    Transaction.set_error(transaction, reason, message, stack)
    Transaction.set_meta_data(metadata)
    Transaction.finish(transaction)
    Transaction.complete(transaction)
    Logger.debug("Submitting #{inspect transaction}: #{message}")
    transaction
  end
  if Appsignal.phoenix? do
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
  @spec match_event(term) :: {pid, term, String.t, list, Map.t} | :nomatch
  def match_event({:error_report, _gleader, {origin, :crash_report, report}}) do
    match_error_report(origin, report)
  end
  def match_event(_event) do
    :nomatch
  end

  defp match_error_report(origin, [[{:initial_call, _},
                                    {:pid, pid},
                                    {:registered_name, name},
                                    {:error_info, {_kind, exception, stack}} | _], _linked]) do
    msg = "Process #{crash_name(pid, name)} terminating"
    stacktrace = extract_stacktrace(exception) || stack
    {reason, message} = extract_reason_and_message(exception, msg)
    {origin, reason, message, Backtrace.from_stacktrace(stacktrace), nil}
  end

  defp extract_stacktrace({_, stacktrace}) do
    case stacktrace?(stacktrace) do
      true -> stacktrace
      false -> nil
    end
  end
  defp extract_stacktrace(_), do: nil

  defp stacktrace?(stacktrace) when is_list(stacktrace) do
    Enum.all?(stacktrace, &stacktrace_line?/1)
  end
  defp stacktrace?(_), do: false

  defp stacktrace_line?({_,_,_,[file: _, line: _]}), do: true
  defp stacktrace_line?(_), do: false

  @doc false
  def format_stack(stacktrace) do
    IO.warn "Appsignal.ErrorHandler.format_stack/1 is deprecated. Use Appsignal.Backtrace.from_stacktrace/1 instead."
    Backtrace.from_stacktrace(stacktrace)
  end

  defp crash_name(pid, []), do: inspect(pid)
  defp crash_name(pid, name), do: "#{inspect(name)} (#{inspect(pid)})"

  @doc """
  Extract a consise reason from the given error reason, stripping it from long stack traces and the like.
  Also returns a 'message' which is supposed to contain extra error information.
  """
  @spec extract_reason_and_message(any(), binary()) :: {any(), binary()}
  def extract_reason_and_message(reason, message) when is_binary(reason) do
    {reason, message}
  end
  def extract_reason_and_message(reason, message) when is_atom(reason) do
    try do
      {Exception.message(reason.exception([])), message}
    rescue
      UndefinedFunctionError -> {"#{inspect reason}", message}
    end
  end
  def extract_reason_and_message(%Protocol.UndefinedError{value: {:error, {error = %{}, _stack}}}, message) do
    extract_reason_and_message(error, message)
  end

  if Appsignal.phoenix? do
    def extract_reason_and_message(%Phoenix.Template.UndefinedError{assigns: %{conn: %{assigns: %{kind: :error, reason: reason}}}}, message) do
      extract_reason_and_message(reason, message)
    end
  end
  def extract_reason_and_message(r = %{}, message) do
    msg = Exception.message(r)
    {"#{inspect r.__struct__}", prefixed(message, msg)}
  end
  def extract_reason_and_message({r = %{}, _}, message) do
    extract_reason_and_message(r, message)
  end
  def extract_reason_and_message({kind, _} = reason, message) do
    {inspect(kind), prefixed(message, inspect(reason))}
  end
  def extract_reason_and_message(any, message) do
    # inspect any term; truncate it
    {"#{inspect any}", message}
  end

  defp prefixed(nil, msg), do: msg
  defp prefixed("", msg), do: msg
  defp prefixed(pre, msg), do: pre <> ": " <> msg

  @pid_or_ref_regex ~r/\<(\d+\.)+\d+\>/
  def normalize_reason(reason) do
    Regex.replace(@pid_or_ref_regex, reason, "<...>")
  end
end
