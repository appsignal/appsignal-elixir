---
bump: patch
type: fix
---

Close the spans of a Broadway message and its processor, and any span left open inside them, when they end. When `handle_message/3` left a span open, that span was closed in the message's place, the processor's attributes were set on the message's span, which was closed in the processor's place, and the processor's span was never reported.
