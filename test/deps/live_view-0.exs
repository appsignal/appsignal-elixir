{deps, _binding} = Code.eval_file("phoenix-1.7.exs", __DIR__)

# Floki needs Elixir 1.15 from 0.38.2.
floki =
  case Version.match?(System.version(), "< 1.15.0") do
    true -> ">= 0.30.0 and < 0.38.2"
    false -> ">= 0.30.0"
  end

deps
|> Enum.reject(&(elem(&1, 0) in [:phoenix_live_view, :lazy_html, :floki]))
|> Kernel.++([{:phoenix_live_view, "~> 0.20.0"}, {:floki, floki}])
