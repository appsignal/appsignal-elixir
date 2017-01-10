if Appsignal.phoenix? do
  defmodule Appsignal.Phoenix.InstrumenterDSL do
    @moduledoc false

    @doc false
    defmacro instrumenter(name) do
      quote do
        alias Appsignal.Phoenix.Instrumenter

        @doc false
        def unquote(name)(:start, _compiled, args) do
          Instrumenter.maybe_transaction_start_event(args, Instrumenter.cleanup_args(args))
        end

        @doc false
        def unquote(name)(:stop, _diff, res) do
          Instrumenter.maybe_transaction_finish_event(Atom.to_string(unquote(name)), res)
        end
      end
    end
  end
end
