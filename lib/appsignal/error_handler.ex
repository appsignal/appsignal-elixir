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

  alias Appsignal.Transaction

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
        {origin, reason, message, stack, metadata} ->
          case supervisor_event?(reason) do
            false ->
              transaction = Transaction.lookup_or_create_transaction(origin)
              if transaction != nil do
                submit_transaction(transaction, reason, message, stack, metadata)
              end
            true ->
              # ignore this event; we have already handled it.
              state
          end
        :nomatch ->
          state
      end
    {:ok, state}
  end

  def submit_transaction(transaction, reason, message, stack, metadata) do
    Transaction.set_error(transaction, reason, message, stack)
    if metadata[:conn] != nil do
      Transaction.set_request_metadata(transaction, metadata[:conn])
    end
    Transaction.set_meta_data(metadata)
    Transaction.finish(transaction)
    Transaction.complete(transaction)
    Logger.debug("Submitting #{inspect transaction}: #{message}")
    transaction
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


  @doc false
  @spec match_event(term) :: {pid, term, String.t, list, Map.t} | :nomatch
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
    case supervisor_event?(reason) do
      false ->
        msg = "Process #{crash_name(pid, name)} terminating"
        {origin, "#{inspect reason}", msg, format_stack(stack), %{}}
      true ->
        :nomatch
    end
  end


  # Match on the various format strings that OTP gives us to extract the
  # error information like stack traces et cetera.
  # TODO: Add crashes caused by gen_event handlers
  defp match_error_format('Error in process ' ++ _, [pid, {reason, stack}]) do
    msg = "Process #{inspect pid} raised an exception"
    {reason, msg} = extract_reason_and_message(reason, msg)
    {pid, reason, msg, format_stack(stack), %{}}
  end

  defp match_error_format('** Generic server ' ++ _, [pid, _last, _state, reason]) do
    {reason, stack} = maybe_extract_stack(reason)
    {reason, msg} = extract_reason_and_message(reason, "GenServer #{inspect pid} terminating")
    {pid, reason, msg, format_stack(stack), %{}}
  end

  defp match_error_format('** Task ' ++ _, [pid, starter, function, args, reason]) do
    {reason, stack} = maybe_extract_stack(reason)
    msg = "Task #{inspect pid} started from #{inspect starter} terminating. Function: #{inspect function}, args: #{inspect args}"
    {reason, msg} = extract_reason_and_message(reason, msg)
    {pid, reason, msg, format_stack(stack), %{}}
  end

  # FIXME add test coverage for this one
  defp match_error_format('Ranch listener ' ++ _, [_, _, pid, {{reason, stack}, initial}]) do
    metadata = case extract_conn(initial) do
                 nil -> %{}
                 c -> %{conn: c}
               end
    msg = "HTTP request #{inspect pid} crashed"
    {reason, msg} = extract_reason_and_message(reason, msg)
    {pid, reason, msg, format_stack(stack), metadata}
  end

  # Format the stack trace as an array of strings
  @doc false
  def format_stack(stacktrace) do
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

  defp extract_conn({_, :call, [%Plug.Conn{} = conn, _params]}), do: conn
  defp extract_conn(_), do: nil


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
  def extract_reason_and_message(%Phoenix.Template.UndefinedError{assigns: %{conn: %{assigns: %{kind: :error, reason: reason}}}}, message) do
    extract_reason_and_message(reason, message)
  end
  def extract_reason_and_message(r = %{}, message) do
    msg = Exception.message(r)
    {"#{inspect r.__struct__}", prefixed(message, msg)}
  end
  def extract_reason_and_message(any, message) do
    # inspect any term; truncate it
    {"#{inspect any}", message}
  end

  defp prefixed(nil, msg), do: msg
  defp prefixed("", msg), do: msg
  defp prefixed(pre, msg), do: pre <> ": " <> msg
end
