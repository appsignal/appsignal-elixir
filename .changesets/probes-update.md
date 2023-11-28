---
bump: "patch"
type: "fix"
---

- Support disk usage reporting (using `df`) on Alpine Linux. This host metric would report an error on Alpine Linux.
- When a disk mountpoint has no inodes usage percentage, skip the mountpoint, and report the inodes information successfully for the inodes that do have an inodes usage percentage.
