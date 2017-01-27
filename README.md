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

### Branches and versions

The `master` branch corresponds to the current release of the
library. The `develop` branch is used for development of features that
will end up in the next minor release. If you fix a bug open a pull
request on `master`, if it's a new feature on `develop`.

## License

The AppSignal for Elixir package source code is released under the MIT License.
Check the [LICENSE](LICENSE) file for more information.
