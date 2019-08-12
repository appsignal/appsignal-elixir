alias Appsignal.Transaction

fibonacci =
  Enum.map([2, 3, 5, 8, 13, 21, 34, 55, 89, 144, 233, 377, 610, 987, 1597, 2584, 4181, 6765, 10946, 17711], fn range ->
    1
    |> Range.new(range)
    |> Enum.reduce([], &([&1 | &2]))
  end)

Benchee.run(
  %{
    "registry" => fn ->
      Enum.each(fibonacci, fn list ->
        list
        |> Task.async_stream(fn index ->
          index
          |> to_string()
          |> Transaction.start(:benchmark)
          |> Transaction.complete()
        end, ordered: false, max_concurrency: Enum.count(list))
        |> Stream.run()
      end)
    end
  }
)
