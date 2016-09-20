# Roadmap

The roadmap looks like this, currently:

## Pre-release version
 - [x] Host metrics
 - [x] API coverage; errors / performance / events

## Alpha version (0.x)
 - [x] Agent installation and compilation
 - [x] Agent Configuration
 - [x] Basic API coverage (Header file)
 - [x] Travis CI
 - [x] Basic Phoenix integration
 - [x] Instrumentation within a request
   - [x] template render (phoenix)
   - [x] Ecto queries

## Release version (1.0, RC)
 - [x] Instrumentation within a request
   - [x] Auto-instrumentation of functions (using macros)
   - [ ] Outgoing HTTP requests (HTTPoison)
   - [ ] Channel instrumentation (one transaction per channel connection)

## Post 1.0
 - [ ] Exometer backend
 - [ ] Erlang VM metrics
