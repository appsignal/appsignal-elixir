---
bump: "patch"
type: "add"
---

Report total CPU usage host metric for VMs. This change adds another `state` tag value on the `cpu` metric called `total_usage`, which reports the VM's total CPU usage in percentages.
