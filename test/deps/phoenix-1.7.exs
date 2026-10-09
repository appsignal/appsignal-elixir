elixir = System.version()

# Hex does not take a dependency's Elixir requirement into account, so cap the
# dependencies that no longer compile on the older Elixir versions this set
# runs on.
plug =
  cond do
    Version.match?(elixir, "< 1.14.0") -> "~> 1.18.0"
    Version.match?(elixir, "< 1.15.0") -> "~> 1.19.0"
    true -> "~> 1.18"
  end

# phoenix_live_view 1.1 depends on lazy_html, which needs Elixir 1.14.
phoenix_live_view =
  case Version.match?(elixir, "< 1.14.0") do
    true -> "~> 1.0.0"
    false -> "~> 1.0"
  end

# phoenix_template 1.1 uses a bitstring pattern that Elixir 1.14 and older
# cannot compile.
phoenix_template =
  case Version.match?(elixir, "< 1.15.0") do
    true -> [{:phoenix_template, "~> 1.0.0"}]
    false -> []
  end

[
  {:plug, plug},
  {:phoenix, "~> 1.7.0"},
  {:phoenix_live_view, phoenix_live_view}
] ++ phoenix_template
