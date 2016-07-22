defmodule Appsignal.ErrorHandler do
  @moduledoc """
  Error handler which sends all crash reports to the Appsignal backend.

  When you add `:appsignal` to your application's dependencies, this
  error logger will automatically be installed. All processes that are
  supervised, like GenServers, Tasks, Agents, Supervisored will be
  monitored for crashes. In the case of a crash, the Appsignal error
  handler collects error information and sends it to the backend.

  """

  use GenEvent

  require Logger

  alias Appsignal.{Transaction,TransactionRegistry}

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
        {origin, reason, message, stack} ->
          #IO.inspect "==> ErrorHandler event: #{inspect reason}"
          case supervisor_event?(reason) do
            false ->
              lookup_or_create_transaction(origin)
              |> submit_transaction(reason, message, stack)
            true ->
              # ignore this event; we have already handled it.
              state
          end
        :nomatch ->
          state
      end
    {:ok, state}
  end

  defp lookup_or_create_transaction(origin) do
    case TransactionRegistry.lookup(origin) do
      nil ->
        # could not find a linked transaction; start new transaction
        Transaction.start(generate_id(), :background_job)
      t ->
        t
    end
  end

  defp submit_transaction(transaction, reason, message, stack) do
    Transaction.set_error(transaction, "#{inspect reason}", message, stack)
    Transaction.finish(transaction)
    Transaction.complete(transaction)
    Logger.debug("Submitting #{inspect transaction}: #{message}")
    transaction
  end

  # Generate a transaction id for crashed processed that have no
  # associated transaction. Prefixed with '_' to indicate a new transaction was createdk.
  defp generate_id do
    "_" <> Transaction.generate_id()
  end

  # inspect the 'reason' argument to see if it is a supervisor
  # event. if so, we skip submitting it, because the original event
  # has already been processed.
  defp supervisor_event?({:exit, {_reason, [entry|_]}}) do
    case entry do
      {_,_,_} -> true
      {_,_,_,_} -> true
      _ -> false
    end
  end
  defp supervisor_event?(_) do
    false
  end


  def handle_call(:get_last_transaction, state) do
    {:ok, state, state}
  end


  @doc """
  Given an error report, retrieve the reason and the stack trace.
  """
  @spec match_event(term) :: {pid, atom, list} | :nomatch
  def match_event({:error, _gleader, {_pid, format, data}}) do
    match_error_format(format, data)
  end
  def match_event({:error_report, _gleader, {origin, :crash_report, report}}) do
    match_error_report(origin, report)
  end
  def match_event(_event) do
    :nomatch
  end

  defp match_error_report(origin, [[{:initial_call, _},
                                    {:pid, pid},
                                    {:registered_name, name},
                                    {:error_info, {kind, exception, stack}} | _], _linked]) do
    reason = {kind, exception}
    msg = "Process #{crash_name(pid, name)} terminating"
    {origin, reason, msg, format_stack(stack)}
  end


  # Match on the various format strings that OTP gives us to extract the
  # error information like stack traces et cetera.
  # TODO: Add crashes caused by gen_event handlers
  defp match_error_format('Error in process ' ++ _, [pid, {reason, stack}]) do
    msg = "Process #{inspect pid} raised an exception"
    {pid, reason, msg, format_stack(stack)}
  end

  defp match_error_format('** Generic server ' ++ _, [pid, _last, _state, reason]) do
    {reason, stack} = maybe_extract_stack(reason)
    msg = "GenServer #{inspect pid} terminating"
    {pid, reason, msg, format_stack(stack)}
  end

  defp match_error_format('** Task ' ++ _, [pid, starter, function, args, reason]) do
    {reason, stack} = maybe_extract_stack(reason)
    msg = "Task #{inspect pid} started from #{inspect starter} terminating. Function: #{inspect function}, args: #{inspect args}"
    {pid, reason, msg, format_stack(stack)}
  end

  # FIXME add test coverage for this one
  defp match_error_format('Ranch listener ' ++ _, [_, _, pid, {{reason, stack}, _}]) do
    msg = "HTTP request #{inspect pid} crashed"
    {pid, reason, msg, format_stack(stack)}
  end

  # Format the stack trace as an array of strings
  defp format_stack(stacktrace) do
    for entry <- stacktrace do
      Exception.format_stacktrace_entry(entry)
    end
  end

  # Extract stack trace from GenServer crash report reason
  defp maybe_extract_stack({maybe_exception, [_ | _ ] = maybe_stacktrace} = reason) do
    try do
      {maybe_exception, maybe_stacktrace}
    catch
      :error, _ ->
        {reason, []}
    end
  end

  defp maybe_extract_stack(reason) do
    {reason, []}
  end

  defp crash_name(pid, []), do: inspect(pid)
  defp crash_name(pid, name), do: "#{inspect(name)} (#{inspect(pid)})"

end
