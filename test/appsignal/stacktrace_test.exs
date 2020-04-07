defmodule Appsignal.StacktraceTest do
  use ExUnit.Case
  alias Appsignal.Stacktrace

  test "formats stacktrace lines" do
    stacktrace =
      [line] = [
        {:elixir_translator, :guard_op, 2, [file: 'src/elixir_translator.erl', line: 317]}
      ]

    assert Stacktrace.format(stacktrace) == [
             Exception.format_stacktrace_entry(line)
           ]
  end

  test "replaces arguments with arities" do
    stacktrace = [
      {:erl_internal, :op_type, [:get_stacktrace, 0], [file: 'erl_internal.erl', line: 212]}
    ]

    [line] = Stacktrace.format(stacktrace)
    assert line =~ ~r{\(stdlib( [\w.-]+)?\) erl_internal.erl:212: :erl_internal.op_type/2}
  end

  test "handles lists of binaries" do
    stacktrace = ["(elixir) src/elixir_translator.erl:317: :elixir_translator.guard_op/2"]

    assert Stacktrace.format(stacktrace) == stacktrace
  end
end
