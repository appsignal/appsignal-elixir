# AppSignal for Elixir Phoenix changelog

## 2.7.0

_Published on 2025-03-24._

### Changed

- Remove the Hackney dependency. It is no longer used since AppSignal package 2.15.0. (minor [ca33981](https://github.com/appsignal/appsignal-elixir-phoenix/commit/ca33981694dec8aa76677f4ef401dc47d167bef4))

### Fixed

- Update `appsignal_plug` dependency requirement. This fixes an issue with spans being closed double, which led to inaccurate reporting. (patch [7516c42](https://github.com/appsignal/appsignal-elixir-phoenix/commit/7516c4275c67b7dc3c941e4a7e93a914d0588d98))

## 2.6.0

_Published on 2024-12-03._

### Added

- Handle live component update events (minor [24b9d94](https://github.com/appsignal/appsignal-elixir-phoenix/commit/24b9d949f2d0478d1c170f225bdb53ca3b3e5535))

## 2.5.1

_Published on 2024-11-06._

### Added

- Set render metadata as tags on render error. When a template rendering error is reported, its backtrace is limited to the Elixir process that is spawned to render the template. Add information about the template and view being rendered as tags, to provide additional context about the error. (patch [8d27329](https://github.com/appsignal/appsignal-elixir-phoenix/commit/8d27329d4862630e5f213162ca5fbd58c7a47e2c))

## 2.5.0

_Published on 2024-09-02._

### Added

- Record request information as metadata like the request path, request method and response status. (minor [6e7444a](https://github.com/appsignal/appsignal-elixir-phoenix/commit/6e7444a3ccffb4faf8eccf529596d1c0958e9757))

## 2.4.1

_Published on 2024-08-22._

### Fixed

- Set request metadata in :router_dispatch events to support Phoenix apps that don't fire :endpoint events. (patch [53ffd75](https://github.com/appsignal/appsignal-elixir-phoenix/commit/53ffd75f516bcd82e35903a6be985292e0fcf17c))

## 2.4.0

_Published on 2024-07-03._

### Added

- Add endpoint events to Phoenix request traces to instrument more events of the request lifetime. (minor [9e24eef](https://github.com/appsignal/appsignal-elixir-phoenix/commit/9e24eefe782dba6fdd423a82850c948e0c3de9d0))
- Add LiveView 1.x in the allowed list of versions in the dependencies. (patch [e7f2b16](https://github.com/appsignal/appsignal-elixir-phoenix/commit/e7f2b169344569beb44d4ac0a4b99462effcc154))

## 2.3.9

_Published on 2024-06-05._

### Changed

- [4bce402](https://github.com/appsignal/appsignal-elixir-phoenix/commit/4bce402d17de206b4a44d496f969b70a810d3088) patch - Allow custom action names to be set in Phoenix routes. For example, in a plug middleware or the controller:
  
  ```elixir
  Appsignal.Tracer.root_span()
  |> Appsignal.Span.set_name("CustomActionName")
  ```

## 2.3.8

### Added

- [18d4840](https://github.com/appsignal/appsignal-elixir-phoenix/commit/18d484021ff3c5fe55c7fb2ed785db6ec5ec5d4f) patch - Handle live_view :render messages received through :telemetry.

## 2.3.7

_Published on 2024-04-26._

### Fixed

- [5e10a3d](https://github.com/appsignal/appsignal-elixir-phoenix/commit/5e10a3d24169acaeee63c894bf73bb563081c76a) patch - Fix unused variables warnings introduced in the previous release.

## 2.3.6

_Published on 2024-04-25._

### Changed

- [745fc21](https://github.com/appsignal/appsignal-elixir-phoenix/commit/745fc2111ad81b1396f8ae3a5168a62a7148b230) patch - Set an action name for Phoenix.ActionClauseError errors. It will now group these errors per controller-action combination for more convenient grouping.

## 2.3.5

### Fixed

- [a08fbf9](https://github.com/appsignal/appsignal-elixir-phoenix/commit/a08fbf94675be8088763fe4403ad7529523e2977) patch - Allow the `phoenix_html` dependency to use version 4.0 or above.
- [a08fbf9](https://github.com/appsignal/appsignal-elixir-phoenix/commit/a08fbf94675be8088763fe4403ad7529523e2977) patch - Fix warning on Elixir 1.16 calling current_span() as a function

## 2.3.4

### Fixed

- [48d61a6](https://github.com/appsignal/appsignal-elixir-phoenix/commit/48d61a65f02c63d2f55ec80a98552fd3bf782bef) patch - Fix an issue in which sample data is overriden by Phoenix data when the span closes.

## 2.3.3

### Fixed

- [dcb0832](https://github.com/appsignal/appsignal-elixir-phoenix/commit/dcb08325f8bb7d170a910813db0282e040a04187) patch - Fix Logger deprecation warnings on Elixir 1.15

## 2.3.2

### Changed

- [5496ad2](https://github.com/appsignal/appsignal-elixir-phoenix/commit/5496ad23398e12216f184c6e9913459c3a31f7f1) patch - Switch to router_dispatch events for root spans

## 2.3.1

### Fixed

- [4e4e422](https://github.com/appsignal/appsignal-elixir-phoenix/commit/4e4e422dd9194ba0d8e3afccc955c227eacae9fb) patch - Fix exception handling for unwrapped Phoenix errors

## 2.3.0

### Added

- [2fe4d48](https://github.com/appsignal/appsignal-elixir-phoenix/commit/2fe4d489149e7a343463eb87e3e64be74a4599c1) minor - Add :telemetry-only Phoenix instrumentation to remove the need for includes in Phoenix application endpoints

## 2.2.1

### Fixed

- [25bc948](https://github.com/appsignal/appsignal-elixir-phoenix/commit/25bc948c620c24a2efe330ec76c657d945f25fce) patch - Fix metadata issue for template telemetry

## 2.2.0

### Added

- [3207e18](https://github.com/appsignal/appsignal-elixir-phoenix/commit/3207e18fe98f4dd08c843304590039acda1e3db5) minor - Add automatic template instrumentation for Phoenix 1.7. Phoenix's upcoming release adds telemetry to templates, so using Appsignal.Phoenix.View is no longer needed.

## 2.1.3

### Fixed

- [916db4b](https://github.com/appsignal/appsignal-elixir-phoenix/commit/916db4be845a8f46f293106776a2bf32683e5043) patch - Fix Appsignal.Logger error on AppSignal for Elixir 1.4.0

## 2.1.2

### Added

- [c915a34](https://github.com/appsignal/appsignal-elixir-phoenix/commit/c915a349fc4507c5266bb59130a118b2ca1e3270) patch - Handle live_component events in LiveView integration

## 2.1.1

### Added

- [fcfba2d](https://github.com/appsignal/appsignal-elixir-phoenix/commit/fcfba2dc1457176fc4998259b2d3e0ead86d0729) patch - Add event names to LiveView events

## 2.1.0

### Added

- [108d9dd](https://github.com/appsignal/appsignal-elixir-phoenix/commit/108d9dd33cc9f5465aac63d720f3d445577b9849) minor - Semi-automatic LiveView instrumentation

## 2.0.14

### Fixed

- [42b2cdd](https://github.com/appsignal/appsignal-elixir-phoenix/commit/42b2cdd816b3b54627cd77bdb3a6e87b20d5d38f) patch - Fix application environment warnings on Elixir 1.14

## 2.0.13

- [31a29c2](https://github.com/appsignal/appsignal-elixir-phoenix/commit/31a29c229211ab9e84fec5a5383fae6044c3c628) patch - Fix Telemetry 1.x warning caused by the Phoenix EventHandler

## 2.0.12

- [bd9b88d](https://github.com/appsignal/appsignal-elixir-phoenix/commit/bd9b88d4db6776a631ca59060a5412832c771dbe) patch - Remove unneeded telemetry dependency

## 2.0.11

- [aaa3146](https://github.com/appsignal/appsignal-elixir-phoenix/commit/aaa31460c4120873e45be2da61d64bf5f87ecd47) patch - Allow using phoenix_html 3.0.0 and up

## 2.0.10

- [8a219f9](https://github.com/appsignal/appsignal-elixir-phoenix/commit/8a219f9c213baaaab9cc66471f9307941b586f44) patch - Resolve duplicate view clause warnings from Appsignal.View

## 2.0.9

- [097eeaf](https://github.com/appsignal/appsignal-elixir-phoenix/commit/097eeafc66319771dc300a7bfd5b923947647e9d) patch - `Appsignal.View` returns templates when AppSignal's view instrumentation is disabled.

## 2.0.8

- [af399ef](https://github.com/appsignal/appsignal-elixir-phoenix/commit/af399efc8ad43ab7b93d34f848eb1df6d87c96ad) patch - Handle `root_view`s in phoenix_live_view 0.15.6 and up, which were made private
  in
  https://github.com/phoenixframework/phoenix_live_view/commit/8bb6f44554f22bf580048e20562b62dd6b26e2b5.
- [c19e006](https://github.com/appsignal/appsignal-elixir-phoenix/commit/c19e00695c45c5c50269fa568e550ed95e437408) patch - Don't track Phoenix render template events without root spans. For live view a lot of template events were tracked as separate incidents, causing a lot noise on the incidents overview for an app. This patch makes sure `Appsignal.View` doesn't create root spans anymore, skipping any template renders that can't be added to any existing trace.

## 2.0.7
- [af399efc](https://github.com/appsignal/appsignal-elixir-phoenix/commit/af399efc8ad43ab7b93d34f848eb1df6d87c96ad) patch - Handle `root_view`s in phoenix_live_view 0.15.6 and up, which were made private in https://github.com/phoenixframework/phoenix_live_view/commit/8bb6f44554f22bf580048e20562b62dd6b26e2b5.

## 2.0.6
* Use Appsignal.Logger in Appsignal.Phoenix.View and .EventHandler. PR #12

## 2.0.5
* Exposes live_view_action/5 to help instrument handle_params. PR #11

## 2.0.4
* Allow :appsignal_plug versions between 2.0.4 and 3.0.0

## 2.0.3
* Use “live_view” namespace for LiveView samples. PR #10

## 2.0.2
* Explicitly ignore returns from Span functions. PR #7

## 2.0.1
* Add clause for non-binary template names in AppsignalPhoenix.View. PR #6

## 2.0.0
* Initial release, extracted from appsignal-elixir 🎉
