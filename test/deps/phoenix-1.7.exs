elixir = System.version()
otp = String.to_integer(System.otp_release())

# Hex does not take a dependency's Elixir requirement into account, so cap the
# dependencies that no longer compile on the older Elixir versions this set
# runs on.
plug =
  cond do
    Version.match?(elixir, "< 1.14.0") -> "~> 1.18.0"
    Version.match?(elixir, "< 1.15.0") -> "~> 1.19.0"
    true -> "~> 1.18"
  end

# phoenix_template 1.1 uses a bitstring pattern that Elixir 1.14 and older
# cannot compile.
phoenix_template =
  case Version.match?(elixir, "< 1.15.0") do
    true -> [{:phoenix_template, "~> 1.0.0"}]
    false -> []
  end

live_view = [{:phoenix_live_view, "~> 1.0"}, {:lazy_html, "~> 0.1"}]

# Bandit needs Elixir 1.15. Cowboy 2.19 and newer need cowlib 2.20, and
# ranch 2.3 needs OTP 27, as does cowlib 2.20.
bandit =
  case Version.match?(elixir, "< 1.15.0") do
    true -> []
    false -> [{:bandit, "~> 1.0"}]
  end

cowboy =
  case otp < 27 do
    true ->
      [
        {:cowboy, "< 2.19.0", override: true},
        {:cowlib, "< 2.20.0", override: true},
        {:ranch, "< 2.3.0", override: true}
      ]

    false ->
      []
  end

servers = [{:plug_cowboy, "~> 2.6"}] ++ bandit ++ cowboy

[
  {:plug, plug},
  {:phoenix, "~> 1.7.0"},
  {:phoenix_view, "~> 2.0"}
] ++ live_view ++ phoenix_template ++ servers
