Integrating into Phoenix
========================



## Incoming HTTP requests

To start logging HTTP requests in your Phoenix app, *use* the
`Appsignal.Phoenix` module in your `endpoint.ex` file, just *before*
the line where your router module gets called (which should read
something like `plug PhoenixApp.Router`):

```
use Appsignal.Phoenix
```

This will record a transaction for every HTTP request which is
performed on the endpoint.



## Phoenix instrumenter hooks

Phoenix comes with instrumentation hooks built in. To send Phoenix'
default instrumentation events to Appsignal, add the following to your
`config.exs` (adjusting for your app's name!):

```
config :phoenix_app, PhoenixApp.Endpoint,
  instrumenters: [Appsignal.Phoenix.Instrumenter]
```

For more custom configuration, see the
`Appsignal.Phoenix.Instrumenter` documentation.

## Template renders

To instrument how much time it takes to render each template in your
Phoenix application, including subtemplates (partials), you need to
register the Appsignal template renderers which augment the compiled templates with instrumentation hooks.

Put the following in your `config.exs`:

```
config :phoenix, :template_engines,
  eex: Appsignal.Phoenix.Template.EExEngine,
  exs: Appsignal.Phoenix.Template.ExsEngine
```

## Queries

To add query logging, add the following to you Repo configuration in `config.exs`:

```
config :my_app, MyApp.Repo,
  loggers: [Appsignal.Ecto]
```

Note that this is not Phoenix-specific but works for all Ecto
queries. However, the process that performs the query must have been
associated with an `Appsignal.Transaction`, otherwise no event will be
logged.


## Channels

Currently, channels do not have hooks for instrumentation yet. This is on the roadmap.
