defmodule Appsignal.Backtrace do
  @doc ~S"""
  Parses the given stacktrace into a backtrace list.

  ## Examples

      iex> [{:erl_internal, :op_type, [:get_stacktrace, 0],
      ...>  [file: 'erl_internal.erl', line: 212]},
      ...>  {:elixir_translator, :guard_op, 2,
      ...>  [file: 'src/elixir_translator.erl', line: 317]},
      ...>  {:elixir_translator, :translate, 2,
      ...>  [file: 'src/elixir_translator.erl', line: 280]}]
      ...>  |> Appsignal.Backtrace.from_stacktrace
      ["(stdlib) erl_internal.erl:212: :erl_internal.op_type(:get_stacktrace, 0)",
       "(elixir) src/elixir_translator.erl:317: :elixir_translator.guard_op/2",
       "(elixir) src/elixir_translator.erl:280: :elixir_translator.translate/2"]
  """
  def from_stacktrace(stacktrace) do
    Enum.map(stacktrace, &Exception.format_stacktrace_entry(&1))
  end
end
