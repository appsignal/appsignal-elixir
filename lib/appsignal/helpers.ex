defmodule Appsignal.Helpers do
  @moduledoc """
  Helper functions and macros to instrument function calls.
  """

  alias Appsignal.{Transaction, TransactionRegistry}
  alias Plug.Conn

  @type instrument_arg :: Transaction.t | Conn.t | pid()

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
    import Appsignal.Helpers, only: [instrument: 4]

    def index(conn, _params) do
      result = instrument(conn, "net.http", "Some slow backend call", fn() ->
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

  def instrument(%Conn{} = conn, name, title, body, body_format, function) do
    instrument(conn.assigns.appsignal_transaction, name, title, body, body_format, function)
  end

  def instrument(%Transaction{} = transaction, name, title, body, body_format, function) do
    Transaction.start_event(transaction)
    result = function.()
    Transaction.finish_event(transaction, name, title, body, body_format)
    result
  end

  @doc """
  Automatically instrument all function definitions in the nested block using a given category

  All `def` statements that are passed in into the macro are
  transformed to call `Appsignal.Helpers.instrument/6` automatically.

  ```
  defmodule MyInstrumentedModule do
    import Appsignal.Helpers

    instrumented do

      def bar(arg) do
        # code to be instrumented
      end

      # more functions...
    end
  end
  ```

  Whenever `MyInstrumentedModule.bar()` is called now, it will be
  using `instrument/6` to record an Appsignal event. The name of the
  event is the same as the function name. When a category (atom) is
  given, the category is postfixed to the function name, so given the
  following code:

  ```
    instrumented :http do

      def load_data(arg) do
        # code to be instrumented
      end
    end
  ```

  events will be recorded under the event name `load_data.http` whenever `load_data()` is called.

  """
  defmacro instrumented(category, code) do
    expand_instrumented(".#{category}", code)
  end

  @doc """
  Automatically instrument all function definitions in the nested block

  See `instrumented/2`
  """
  defmacro instrumented(code) do
    expand_instrumented("", code)
  end


  defp expand_instrumented(postfix, [do: {tag, _meta, _rest} = deftuple]) when tag in [:def, :defp] do
    [do: instrument_def(deftuple, postfix)]
  end

  defp expand_instrumented(postfix, [do: {:__block__, arg, tuples}]) do
    [do: {:__block__, arg, tuples |> Enum.map(&(instrument_def(&1, postfix)))}]
  end

  defp instrument_def({tag, defmeta, [{name, _, _}=defname, [do: doblock]]}, postfix) when tag in [:def, :defp] do
    name = Atom.to_string(name)
    {tag,
     defmeta,
     [defname,
      [do: quote do
         Appsignal.Helpers.instrument(self(), unquote(name) <> unquote(postfix), Atom.to_string(__MODULE__) <> "." <> unquote(name), fn() -> unquote(doblock) end)
       end]]}
  end
  defp instrument_def(code, _postfix) do
    code
  end


end
