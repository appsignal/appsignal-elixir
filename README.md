# AppSignal for Elixir

[![Build Status](https://travis-ci.org/appsignal/appsignal-elixir.png?branch=main)](https://travis-ci.org/appsignal/appsignal-elixir)
[![Hex pm](http://img.shields.io/hexpm/v/appsignal.svg?style=flat)](https://hex.pm/packages/appsignal)

AppSignal for Elixir monitors errors, performance and servers for Elixir
applications.

- [AppSignal.com website](https://www.appsignal.com/elixir)
- [AppSignal for Elixir documentation](https://docs.appsignal.com/elixir/)
- [Package documentation](https://hexdocs.pm/appsignal/)
- [Support][contact]

## Installation

Please follow the [installation
guide](https://docs.appsignal.com/elixir/installation.html) on how to install
and use this library.

Then, add custom instrumentation or use one of the framework integrations to
automatically gain performance insights and error notifications. Currently,
AppSignal has framework integrations for
[Plug](https://github.com/appsignal/appsignal-elixir-plug) and
[Phoenix](https://github.com/appsignal/appsignal-elixir-phoenix) and
applications.

## Usage

AppSignal will automatically monitor requests, report any exceptions that are
thrown and any performance issues that might have occurred.

You can also add extra information to requests by adding custom
instrumentation. Read more in our [instrumentation
guide](https://docs.appsignal.com/elixir/instrumentation/).

## Configuration

A complete list of all configurable options for AppSignal for Elixir is
available in [our
documentation](https://docs.appsignal.com/elixir/configuration/).

## Development

### Setup

Before you can start developing on the AppSignal for Elixir project make sure
you have [Elixir installed](http://elixir-lang.org/install.html).

This repository is managed by [mono](https://github.com/appsignal/mono/).
Install mono on your local machine by [following the mono installation
steps](https://github.com/appsignal/mono/#installation).

Then make sure you have all the project's dependencies installed by running the
following command:

    $ mono bootstrap

### Testing

Testing is done with ExUnit and can be run with the `mix test` command. You can
also supply a path to a specific file path you want to test and even a specific
line on which the test you want to run is defined.

    $ mono test
    # The original command can still be used
    $ mix test
    $ mix test test/appsignal/some_test.ex:123

This project has several different test suites defined with different mix
environments. You can run them by specifying the specific type of test suite in
the `MIX_ENV` environment variable.

    # Default
    $ MIX_ENV=test mix test

    # Run the test suite with the NIF inoperational. This will generate errors
    # because the NIF is not active, but should run without failures.
    $ MIX_ENV=test_no_nif mix test

### Benchmarking

This package uses benchee to benchmark code. To run the benchmarker:

    $ MIX_ENV=bench mix run bench/<file>.exs

### AddressSanitizer

A memory testing setup is included to detect memory errors in the NIF.
It's set up in a Docker container to ensure reproducability.

To run the tests, build the container, which will build a version of the NIF with AddressSanitizer enabled.
Then, run it with an `APPSIGNAL_PUSH_API_KEY` and `APPSIGNAL_APP_NAME` set to ensure AppSignal is enabled, and to be able to verify that data appears in AppSignal after running the test:

    docker build --platform linux/amd64 -t appsignal-elixir-asan .
    docker run \
      --env APPSIGNAL_PUSH_API_KEY=00000000-0000-0000-0000-000000000000 \
      --env APPSIGNAL_APP_NAME="appsignal-elixir" \
      --rm \
      -- \
      appsignal-elixir-asan

This test runs `spans.exs`, which is a script that calls most functions in the NIF.

### Branches and versions

The `main` branch corresponds to the current release of the
library. The `develop` branch is used for development of features that
will end up in the next minor release. If you fix a bug open a pull
request on `main`, if it's a new feature on `develop`.

### Making changes

When making changes to the project that require a release, [add a
changeset](https://github.com/appsignal/mono/#changeset-add) that will be used
to update the generated `CHANGELOG.md` file upon
[release](#publishing-new-version).

    $ mono changeset add

### Publishing new versions

1. Merge the `develop` branch to `main` if necessary.
-  Run [`mono publish`](https://github.com/appsignal/mono/#publish) and follow
   the instructions.

### Updating the CI build matrix

1. Update `.semaphore/versions.rb` to add or remove Elixir/OTP versions, or `.semaphore/semaphore.yml.erb`.
2. Run `script/generate_ci_matrix`.

## Contributing

Thinking of contributing to our Elixir package? Awesome! 🚀

Please follow our [Contributing guide][contributing-guide] in our
documentation and follow our [Code of Conduct][coc].

Also, we would be very happy to send you Stroopwafles. Have look at everyone
we send a package to so far on our [Stroopwafles page][waffles-page].

## Support

[Contact us][contact] and speak directly with the engineers working on
AppSignal. They will help you get set up, tweak your code and make sure you get
the most out of using AppSignal.

Also see our [SUPPORT.md file](SUPPORT.md).

## License

The AppSignal for Elixir package source code is released under the MIT License.
Check the [LICENSE](LICENSE) file for more information.

[contact]: mailto:support@appsignal.com
[contributing-guide]: https://docs.appsignal.com/appsignal/contributing.html
[coc]: https://docs.appsignal.com/appsignal/code-of-conduct.html
[waffles-page]: https://appsignal.com/waffles
