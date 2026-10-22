---
bump: patch
type: security
integrations: all
---

Bump the bundled certificates that the agent uses when it can't open the
configured CA file. They no longer include the emSign ECC Root CA - G3 and AAA
Certificate Services root certificates, which [compromised eMudhra intermediate
certificates](https://bugzilla.mozilla.org/show_bug.cgi?id=2083449) chain to.
