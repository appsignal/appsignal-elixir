defmodule Appsignal.Instrumentation.Helpers do
  @moduledoc """
  Helper functions and macros to instrument function calls.
  """

  alias Appsignal.Transaction
  @type instrument_arg :: Transaction.t() | Plug.Conn.t() | pid() | nil
  @transaction Application.get_env(:appsignal, :appsignal_transaction, Appsignal.Transaction)

  @doc """
  Execute the given function in start / finish event calls in the current
  transaction. See `instrument/6`.
  """
  @spec instrument(String.t(), String.t(), function) :: any
  def instrument(name, title, function) do
    instrument(self(), name, title, "", function)
  end

  @doc """
  Execute the given function in start / finish event calls. See `instrument/6`.
  """
  @spec instrument(instrument_arg, String.t(), String.t(), function) :: any
  def instrument(arg, name, title, function) do
    instrument(arg, name, title, "", function)
  end

  @doc """
  Execute the given function in start / finish event calls. See `instrument/6`.
  """
  @spec instrument(instrument_arg, String.t(), String.t(), String.t(), function) :: any
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
    result = instrument "net.http", "Some slow backend call", fn() ->
      Backend.get_result()
    end
    json conn, result
  end
  ```

  """
  @spec instrument(
          pid() | Transaction.t() | any(),
          String.t(),
          String.t(),
          String.t(),
          integer,
          function
        ) :: any
  def instrument(pid, name, title, body, body_format, function) when is_pid(pid) do
    pid
    |> Transaction.lookup()
    |> instrument(name, title, body, body_format, function)
  end

  def instrument(%Transaction{} = transaction, name, title, body, body_format, function) do
    @transaction.start_event(transaction)
    result = function.()
    @transaction.finish_event(transaction, name, title, body, body_format)
    result
  end

  def instrument(_transaction, _name, _title, _body, _body_format, function) do
    function.()
  end
end
