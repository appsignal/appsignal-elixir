---
bump: patch
type: fix
---

When running the installation script on Microsoft Windows, some components threw an error. AppSignal doesn't support Windows, so the installation script won't run on Windows anymore. Preventing errors from raising.
