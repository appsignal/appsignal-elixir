---
bump: "patch"
type: "change"
---

Improve Ecto transaction instrumentation. Queries performed as part of an
`Ecto.Multi` or an `Ecto.Repo.transaction` were already individually
instrumented, but now they are displayed in the event timeline as child events
of a broader transaction event. An additional event is added at the end of the
transaction, to denote whether the transaction was committed or rolled back.
