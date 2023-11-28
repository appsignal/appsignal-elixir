---
bump: "patch"
type: "change"
---

Filter more disk mountpoints for disk usage and disk IO stats. This helps reduce noise in the host metrics by focussing on more important mountpoints.

The following mountpoint are ignored. Any mountpoint containing:

- `/etc/hostname`
- `/etc/hosts`
- `/etc/resolv.conf`
- `/snap/`
- `/proc/`
