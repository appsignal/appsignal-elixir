# The libraries AppsignalTest.HTTPServer runs on, for the dependency sets of
# the HTTP client integrations. Evaluated by those sets; not a set itself.
elixir = System.version()
otp = String.to_integer(System.otp_release())

# Hex does not take a dependency's Elixir requirement into account, so cap
# Plug where its newer releases no longer compile.
plug =
  cond do
    Version.match?(elixir, "< 1.14.0") -> "~> 1.18.0"
    Version.match?(elixir, "< 1.15.0") -> "~> 1.19.0"
    true -> "~> 1.18"
  end

# Cowboy 2.19 and newer need cowlib 2.20, and ranch 2.3 needs OTP 27, as does
# cowlib 2.20.
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

[{:plug, plug}, {:plug_cowboy, "~> 2.6"}] ++ cowboy
