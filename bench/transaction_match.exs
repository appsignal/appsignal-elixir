alias Appsignal.{Transaction}

1..100_000
|> Enum.each(fn _ ->
  Transaction.generate_id()
  |> Transaction.start(:benchmark)
end)

Benchee.run(%{
  "match" => fn ->
    Transaction.generate_id()
    |> Transaction.start(:benchmark)
    |> Transaction.complete()
  end
})
