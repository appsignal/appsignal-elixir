---
bump: "patch"
---

Allow for minutely probes to be defined as GenServer processes. This change
allows for probes to keep state between invocations.

To register a process as a probe, you can now pass a module name, or a
supervisor child spec of the form `{module, args}`, as the second argument
to the `Appsignal.Probes.register/2` function.

The process must handle a cast with the request value `:probe` and invoke
`Appsignal.set_gauge/3` to send metrics.

Stateless probes can still be defined as functions, and registered by
passing the function as the second argument to `Appsignal.Probes.register/2`.
