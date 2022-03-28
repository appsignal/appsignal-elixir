# AppSignal for Elixir Phoenix changelog

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
