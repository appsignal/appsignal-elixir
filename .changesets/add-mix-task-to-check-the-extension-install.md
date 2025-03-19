---
bump: patch
type: add
---

Add a mix task to check the extension install.

Run `mix appsignal.check_install` to see if the NIF and agent were successfully installed. If not, it will return with exit code 1. Use this in your CI or build step to check if AppSignal was installed correctly before deploying or starting your application.
