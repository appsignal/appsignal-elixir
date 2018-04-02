defmodule Appsignal.BacktraceTest do
  use ExUnit.Case, async: true
  doctest Appsignal.Backtrace

  @match_line {:elixir_translator, :guard_op, 2, [file: 'src/elixir_translator.erl', line: 317]}

  test "formats stacktrace lines" do
    assert Appsignal.Backtrace.from_stacktrace([@match_line]) == [
      Exception.format_stacktrace_entry(@match_line)
    ]
  end

  test "replaces arguments with arities" do
    stacktrace = [{:erl_internal, :op_type, [:get_stacktrace, 0],
        [file: 'erl_internal.erl', line: 212]}]

    assert Appsignal.Backtrace.from_stacktrace(stacktrace) == [
      "(stdlib) erl_internal.erl:212: :erl_internal.op_type/2"
    ]
  end

  test "handles lists of binaries" do
    stacktrace = ["(elixir) src/elixir_translator.erl:317: :elixir_translator.guard_op/2"]

    assert Appsignal.Backtrace.from_stacktrace(stacktrace) == stacktrace
  end
end
