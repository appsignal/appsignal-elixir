---
bump: patch
type: fix
---

Close the span of an Ecto transaction, and any span left open inside it, when the transaction ends. When code in the transaction left a span open, the commit or rollback was recorded inside that span, which was closed in place of the transaction's span, and the transaction's span was never reported.
