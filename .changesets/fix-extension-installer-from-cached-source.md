---
bump: "patch"
---

Fix extension installer from cached source in `/tmp` directory. This would cause installation errors of the package if the AppSignal package was reinstalled again on a host that already installed it once.
