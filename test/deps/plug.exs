otp = String.to_integer(System.otp_release())

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

[
  {:plug, "~> 1.18"},
  {:bandit, "~> 1.0"},
  {:plug_cowboy, "~> 2.6"}
] ++ cowboy
