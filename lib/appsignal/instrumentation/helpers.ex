defmodule Appsignal.Instrumentation.Helpers do
  @moduledoc """
  Helper functions and macros to instrument function calls.
  """

  alias Appsignal.{Transaction, TransactionRegistry}

  @type instrument_arg :: Transaction.t | Plug.Conn.t | pid()

  @doc """
  Execute the given function in start / finish event calls. See `instrument/6`.
  """
  @spec instrument(instrument_arg, String.t, String.t, function) :: any
  def instrument(arg, name, title, function) do
    instrument(arg, name, title, "", function)
  end

  @doc """
  Execute the given function in start / finish event calls. See `instrument/6`.
  """
  @spec instrument(instrument_arg, String.t, String.t, String.t, function) :: any
  def instrument(arg, name, title, body, function) do
    instrument(arg, name, title, body, 0, function)
  end

  @doc """
  Execute the given function in start / finish event calls.

  The result of the function's execution is returned. For example, to
  instrument a backend HTTP call in a Phoenix controller, do the
  following:

  ```
  import Appsignal.Instrumentation.Helpers, only: [instrument: 4]

  def index(conn, _params) do
    result = instrument conn, "net.http", "Some slow backend call", fn() ->
      Backend.get_result()
    end
    json conn, result
  end
  ```

  """
  @spec instrument(instrument_arg, String.t, String.t, String.t, integer, function) :: any
  def instrument(pid, name, title, body, body_format, function) when is_pid(pid) do
    case TransactionRegistry.lookup(pid) do
      nil ->
        function.()
      t = %Transaction{} ->
        instrument(t, name, title, body, body_format, function)
    end
  end

  if Appsignal.phoenix? do
    def instrument(%Plug.Conn{} = conn, name, title, body, body_format, function) do
      instrument(conn.assigns.appsignal_transaction, name, title, body, body_format, function)
    end
  end

  def instrument(%Transaction{} = transaction, name, title, body, body_format, function) do
    Transaction.start_event(transaction)
    result = function.()
    Transaction.finish_event(transaction, name, title, body, body_format)
    result
  end

end
