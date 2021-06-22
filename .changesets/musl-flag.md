---
bump: "patch"
---

Update `APPSIGNAL_BUILD_FOR_MUSL` behavior to only listen to the values `1` and `true`. This way `APPSIGNAL_BUILD_FOR_MUSL=false` is not interpreted to install the musl build.
