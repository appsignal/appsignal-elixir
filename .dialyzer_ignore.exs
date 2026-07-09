# HTTPoison 3.0's `HTTPoison.Base` macro generates a `stream_next/1` that calls
# `:hackney.stream_next/1`. hackney 4.0 narrowed that function's typespec, so
# dialyzer treats the error clause as dead code and flags the generated spec and
# callback. The code is HTTPoison's, injected into `Appsignal.HTTPoison` through
# `use`, so we ignore these rather than work around a third-party type change.
[
  {"deps/httpoison/lib/httpoison/base.ex", :callback_arg_type_mismatch},
  {"deps/httpoison/lib/httpoison/base.ex", :callback_type_mismatch},
  {"deps/httpoison/lib/httpoison/base.ex", :pattern_match_cov},
  {"lib/appsignal/httpoison.ex", :invalid_contract}
]
