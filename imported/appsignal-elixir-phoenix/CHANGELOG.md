# 2.0.7

- [af399efc](https://github.com/appsignal/appsignal-elixir-phoenix/commit/af399efc8ad43ab7b93d34f848eb1df6d87c96ad) patch - Handle `root_view`s in phoenix_live_view 0.15.6 and up, which were made private in https://github.com/phoenixframework/phoenix_live_view/commit/8bb6f44554f22bf580048e20562b62dd6b26e2b5.

# 2.0.6
* Use Appsignal.Logger in Appsignal.Phoenix.View and .EventHandler. PR #12

# 2.0.5
* Exposes live_view_action/5 to help instrument handle_params. PR #11

# 2.0.4
* Allow :appsignal_plug versions between 2.0.4 and 3.0.0

# 2.0.3
* Use “live_view” namespace for LiveView samples. PR #10

# 2.0.2
* Explicitly ignore returns from Span functions. PR #7

# 2.0.1
* Add clause for non-binary template names in AppsignalPhoenix.View. PR #6

# 2.0.0
* Initial release, extracted from appsignal-elixir 🎉
