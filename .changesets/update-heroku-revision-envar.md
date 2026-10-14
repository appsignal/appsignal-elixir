---
bump: patch
type: add
integrations: all
---

Automatically detect the application's revision from the `HEROKU_BUILD_COMMIT`
environment variable, which is set by Heroku at build time [when the
`runtime-dyno-build-metadata` Heroku Labs
feature](https://devcenter.heroku.com/articles/dyno-metadata) is enabled.
