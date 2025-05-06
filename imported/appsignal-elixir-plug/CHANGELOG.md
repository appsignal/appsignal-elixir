# AppSignal for Elixir Plug changelog

## 2.1.1

_Published on 2025-05-06._

### Fixed

- Restore normal error reporting behavior by removing the default included `Plug.ErrorHandler` in the `Appsignal.Plug` module. It will now longer render a page with HTTP status 500 and the response body "Something went wrong". (patch [cc41da2](https://github.com/appsignal/appsignal-elixir-plug/commit/cc41da2f248b4d21580a47377695b98aec84d1c5))

## 2.1.0

_Published on 2025-03-21._

### Changed

- Remove Hackney dependency. The integration now uses Finch instead. (minor [a517cbe](https://github.com/appsignal/appsignal-elixir-plug/commit/a517cbede9d1c1f3f87a1fd75d5ab0f64c7a3f72))

### Fixed

- Ensure spans in requests with errors aren't double-closed (patch [34b5181](https://github.com/appsignal/appsignal-elixir-plug/commit/34b51817ed4473e70b71361b4295c8fc1133fc25))

## 2.0.15

### Fixed

- [6e922d5](https://github.com/appsignal/appsignal-elixir-plug/commit/6e922d56974e6b6cb9b1e43157dccf1e6dd3c54c) patch - Fix an issue in which sample data is overriden by Plug data when the span closes.

## 2.0.14

### Fixed

- [1af0793](https://github.com/appsignal/appsignal-elixir-plug/commit/1af0793a9cf9e705b8bb6794ea8107ba8314b66b) patch - Fix Logger deprecation warnings on Elixir 1.15

## 2.0.13

### Added

- [13849fa](https://github.com/appsignal/appsignal-elixir-plug/commit/13849fa3ad0a764006eebd6d37e4aaac837bb035) patch - Add metadata functions for Plug/Phoenix apps

## 2.0.12

### Fixed

- [37b1a9c](https://github.com/appsignal/appsignal-elixir-plug/commit/37b1a9c83b5b63af870516747febf2315033d8b9) patch - Fix Appsignal.Logger error on AppSignal for Elixir 1.4.0

## 2.0.11

### Removed

- [6ea5f3a](https://github.com/appsignal/appsignal-elixir-plug/commit/6ea5f3a0e0898a56eede4ff4dad142880dbdeeb8) patch - Remove duplicate session and param filter checks

## 2.0.10

### Fixed

- [3b13393](https://github.com/appsignal/appsignal-elixir-plug/commit/3b133934588362865c9d52f6ad79813bee5ede71) patch - Fix application environment warnings on Elixir 1.14

## 2.0.9

### Changed

- [067ddf6](https://github.com/appsignal/appsignal-elixir-plug/commit/067ddf61e0f2b70041dc8858832bd74537211010) patch - Update the plug integration to listen to the `send_session_data` config option instead of
  `skip_session_data`. The `send_session_data` config option is backwards compatible with
  the `skip_session_data` config option.

## 2.0.8
* Use Appsignal.Logger in Appsignal.Plug. PR #11

## 2.0.7
* Handle conns with nil `request_headers` attributes. PR #10

## 2.0.6
* Fix send_params configuration in Appsignal.Plug. PR #9

## 2.0.5
* Allow :appsignal versions between 2.0.6 and 3.0.0

## 2.0.4
Drop all errors with a plug_status < 500, not just WrapperErrors. PR #7

## 2.0.3
Match on :done instead of true for plug_session_fetch. Commit 8af8836f17db60484fc6d02143666345fe607435

## 2.0.2
Add status and request_id and restore headers in Appsignal.Metadata. PR #5

## 2.0.1
Explicitly ignore return from span functions in Appsignal.Plug. PR #4

## 2.0.0
* Initial release, extracted from appsignal-elixir 🎉
