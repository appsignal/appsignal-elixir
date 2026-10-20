# Every library the other sets test against, for the checks that need them
# installed at once. When sets require different versions of a library, the
# requirement that reaches the newest version is kept.
deps =
  __DIR__
  |> Path.join("*.exs")
  |> Path.wildcard()
  |> Enum.reject(&(Path.basename(&1) == "all.exs"))
  |> Enum.flat_map(fn path -> path |> Code.eval_file() |> elem(0) end)

# The versions just around every version a requirement names: one of them is
# the newest that requirement allows, if it has an upper bound.
candidates = fn requirements ->
  for requirement <- requirements,
      [version] <- Regex.scan(~r/\d+(?:\.\d+){0,2}/, requirement),
      [major, minor, patch] =
        version
        |> String.split(".")
        |> Enum.map(&String.to_integer/1)
        |> Kernel.++([0, 0])
        |> Enum.take(3),
      {major, minor, patch} <- [
        {major, minor, patch},
        {major, minor, patch + 1},
        {major, minor + 1, 0},
        {major + 1, 0, 0}
      ] do
    Version.parse!("#{major}.#{minor}.#{patch}")
  end
end

deps
|> Enum.group_by(&elem(&1, 0))
|> Enum.map(fn {_app, versions} ->
  candidates = versions |> Enum.map(&elem(&1, 1)) |> candidates.()

  Enum.max_by(
    versions,
    fn dep ->
      candidates
      |> Enum.filter(&Version.match?(&1, elem(dep, 1)))
      |> Enum.max(Version, fn -> Version.parse!("0.0.0") end)
    end,
    Version
  )
end)
