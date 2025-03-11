---
bump: patch
type: change
integrations:
  - elixir
  - nodejs
  - ruby
---

Delay and eventually halt agent reboots by the extension.

The AppSignal extension is responsible for booting the AppSignal agent. If communication with the agent is lost, the extension is responsible for rebooting it.

In certain scenarios, such as when several processes with different AppSignal configurations are misconfigured to share the same working directory, the processes' extensions can enter a loop of rebooting and killing each others' agents. These short-lived agents may then attempt to repeatedly send pending payloads to AppSignal in quick succession.

This change causes the extension to delay each reboot of its agent by one additional second, and to no longer attempt to reboot the agent after the tenth reboot, slowing down and eventually breaking this loop.
