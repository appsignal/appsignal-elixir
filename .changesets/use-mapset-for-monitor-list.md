---
bump: "minor"
---

Use `MapSet`s for `Monitor`'s internal monitor list. As uniqueness is
guaranteed (you can't monitor a particular pid more than once), MapSet is a
better data structure to store this information, since all its operations are
constant-time instead of linear-time.
