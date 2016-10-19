# Roadmap

The roadmap looks like this, currently:

## Planned features for 1.0
 - [x] Agent installation and compilation
 - [x] Agent Configuration
 - [x] Host metrics
 - [x] API coverage; errors / performance / events
 - [x] Basic API coverage (Header file)
 - [x] Travis CI
 - [x] Basic Phoenix integration
 - [x] Instrumentation within a request
   - [x] template render (phoenix)
   - [x] Ecto queries
   - [x] Auto-instrumentation of functions (using macros)
 - [x] Channel instrumentation (one transaction per incoming event)


## Features planned after 1.0 release
 - [ ] Exometer backend
 - [ ] Erlang VM metrics
 - [ ] Channel instrumentation (one transaction per channel connection)
 - [ ] Instrumentation of popular libraries
   - [ ] Outgoing HTTP requests (HTTPoison, Tesla)
