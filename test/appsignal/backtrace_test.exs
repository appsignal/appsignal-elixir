defmodule Appsignal.BacktraceTest do
  use ExUnit.Case, async: true
  doctest Appsignal.Backtrace

  test "formats stacktrace lines" do
    assert Appsignal.Backtrace.from_stacktrace([
      {:elixir_translator, :guard_op, 2,
        [file: 'src/elixir_translator.erl', line: 317]}
    ]) == ["(elixir) src/elixir_translator.erl:317: :elixir_translator.guard_op/2"]
  end

  test "removes error lines" do
    assert Appsignal.Backtrace.from_stacktrace([
      {:erl_internal, :op_type, [:get_stacktrace, 0],
        [file: 'erl_internal.erl', line: 212]},
      {:elixir_translator, :guard_op, 2,
        [file: 'src/elixir_translator.erl', line: 317]},
    ]) == ["(elixir) src/elixir_translator.erl:317: :elixir_translator.guard_op/2"]
  end

  test "handles lists of binaries" do
    stacktrace = ["(elixir) src/elixir_translator.erl:317: :elixir_translator.guard_op/2"]

    assert Appsignal.Backtrace.from_stacktrace(stacktrace) == stacktrace
  end
end
