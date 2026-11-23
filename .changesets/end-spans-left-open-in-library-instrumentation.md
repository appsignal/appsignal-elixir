---
bump: major
type: change
---

End the spans left open inside a Finch or Tesla request, an Oban job, a Broadway message or batch of messages, an Absinthe operation or an Ecto transaction when that request, job, message, operation or transaction ends. They no longer stay open and become the parent of later work in the same process.
