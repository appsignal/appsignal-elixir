# AppSignal agent for Elixir / Phoenix

[![Build Status](https://travis-ci.org/appsignal/appsignal-elixir.png?branch=master)](https://travis-ci.org/appsignal/appsignal-elixir)
[![Hex pm](http://img.shields.io/hexpm/v/appsignal.svg?style=flat)](https://hex.pm/packages/appsignal)

AppSignal solves all your Elixir monitoring needs in a single tool. You and your
team can focus on writing code and we'll provide the alerts if your app has any
issues.

**NOTE: This library is beta software, and still under development. API changes
might still occur without notice. Please refer to the [Roadmap](Roadmap.md)
document for more information.*

- [AppSignal.com website](https://appsignal.com/)
- [AppSignal for Elixir documentation](http://docs.appsignal.com/elixir/)
- [Package documentation](https://hexdocs.pm/appsignal/)
- [Support](support@appsignal.com)

## Description

The AppSignal for Elixir package collects exceptions and performance data from
your Elixir applications and sends it to AppSignal for analysis. Get alerted
when an error occurs or an endpoint is responding very slowly.

## Installation

Please follow the [installation
guide](http://docs.appsignal.com/elixir/installation.html) on how to install
and use this library.

If you're using the Phoenix framework, please also follow the [integration guide
for Phoenix](http://docs.appsignal.com/elixir/integrations/phoenix.html).

## Usage

AppSignal will automatically monitor requests, report any exceptions that are
thrown and any performance issues that might have occurred.

You can also add extra information to requests by adding custom
instrumentation. Read more in our [instrumentation
guide](http://docs.appsignal.com/elixir/instrumentation/).

## Configuration

A complete list of all configurable options for AppSignal for Elixr is
available in [our
documentation](http://docs.appsignal.com/elixir/configuration/).

## Development

### Setup

Before you can start developing on the AppSignal for Elixir project make sure
you have [Elixir installed](http://elixir-lang.org/install.html).

Then make sure you have all the project's dependencies installed by running the
following command:

```
mix deps.get
```

### Testing

Testing is done with ExUnit and can be run with the `mix test` command. You can
also supply a path to a specific file path you want to test and even a specific
line on which the test you want to run is defined.

```
mix test
mix test test/appsignal/some_test.ex:123
```

This project has several different test suites defined with different mix
environments. You can run them by specifying the specific type of test suite in
the `MIX_ENV` environment variable.

```
# Default
MIX_ENV=test mix test

# Test Phoenix framework integration
MIX_ENV=test_phoenix mix test

# Run the test suite with the NIF inoperational
# This will generate errors that the NIF is not active, but should run
# without failures.
MIX_ENV=test_no_nif mix test
```

### Branches and versions

The `master` branch corresponds to the current release of the
library. The `develop` branch is used for development of features that
will end up in the next minor release. If you fix a bug open a pull
request on `master`, if it's a new feature on `develop`.

### Publishing new versions

1. Merge the `develop` branch to `master` if necessary.
-  Update the version number in `mix.exs`, e.g. `1.2.3`
-  Commit the change.
-  Tag the commit with the version number: `git tag 1.2.3`
-  Push the changes: `git push master 1.2.3`
-  Publish the package: `mix hex.publish`

## License

The AppSignal for Elixir package source code is released under the MIT License.
Check the [LICENSE](LICENSE) file for more information.
