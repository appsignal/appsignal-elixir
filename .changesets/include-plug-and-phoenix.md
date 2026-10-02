---
bump: major
type: change
---

Include the Plug and Phoenix integrations in the `appsignal` package. Remove `appsignal_plug` and `appsignal_phoenix` from your application's dependencies, and depend on `{:appsignal, "~> 3.0"}` instead. The integrations' modules keep their names, so `use Appsignal.Plug`, `Appsignal.Phoenix.LiveView.attach/0` and `Appsignal.Phoenix.Channel.instrument/5` keep working as they are.
