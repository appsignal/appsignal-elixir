---
bump: patch
type: security
---

Stop trusting certificates issued under the eMudhra intermediate certificate authorities whose private keys were [compromised in October 2026](https://bugzilla.mozilla.org/show_bug.cgi?id=2083449). The bundled CA certificates no longer include the emSign ECC Root CA - G3 root certificate, which those intermediates chain to.