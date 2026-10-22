---
bump: patch
type: security
integrations: all
---

When the agent can't open the configured CA file, or can't load the system's CA
certificates, it uses CA certificates built into the agent. Those built-in
certificates no longer include the emSign ECC Root CA - G3 and AAA Certificate
Services root certificates, so the agent stops trusting certificates issued
under the eMudhra intermediate certificate authorities whose private keys were
[compromised in October 2026](https://bugzilla.mozilla.org/show_bug.cgi?id=2083449).
