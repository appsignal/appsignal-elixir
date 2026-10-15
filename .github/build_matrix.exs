# The Elixir and OTP versions CI tests on, and the dependency sets in
# test/deps it tests each of them with. `elixir script/generate_ci.exs`
# writes .github/workflows/ci.yaml from this file.
[
  # Each Elixir version runs on the newest OTP version it supports, and the
  # newest Elixir, in the first row, on every OTP version it supports.
  # `elixir` is the version as erlef/setup-beam takes it. The lint jobs run
  # on the newest Elixir, with the first OTP version in its row.
  elixir: [
    [elixir: "1.19", otp: ["28", "27", "26"]],
    [elixir: "1.18", otp: ["27"]],
    [elixir: "1.17", otp: ["27"]],
    [elixir: "1.16", otp: ["26"]],
    [elixir: "1.15", otp: ["26"]],
    [elixir: "1.14", otp: ["25"]],
    [elixir: "1.13", otp: ["24"]],
    [elixir: "1.12", otp: ["24"]]
  ],

  # Each dependency set, a file in test/deps other than all.exs, runs on every
  # Elixir and OTP version above, except the ones it excludes here by Elixir
  # or OTP requirement. A set that does not install cleanly on a version is
  # excluded there, rather than capping its dependencies, unless that would
  # leave the set's libraries untested on that version.
  exclude: [
    # Plug 1.20 needs Elixir 1.15.
    plug: [elixir: "< 1.15"],
    # Phoenix 1.8 needs Elixir 1.15.
    phoenix: [elixir: "< 1.15"],
    # Ecto 3.14 needs Elixir 1.14.
    ecto: [elixir: "< 1.14"],
    # Oban's tests use Ecto 3.14, which needs Elixir 1.14.
    oban: [elixir: "< 1.14"],
    # HTTPoison 3 depends on hackney 4, which needs OTP 26.
    httpoison: [otp: "< 26"]
  ]
]
