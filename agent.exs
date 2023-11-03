# DO NOT EDIT
# This is a generated file by the `rake ship` family of tasks in the
# appsignal-agent repository.
# Modifications to this file will be overwritten with the next agent release.

defmodule Appsignal.Agent do
  def version, do: "1dd2a18"

  def mirrors do
    [
      "https://appsignal-agent-releases.global.ssl.fastly.net",
      "https://d135dj0rjqvssy.cloudfront.net",
    ]
  end

  def triples do
    %{
      "x86_64-darwin" => %{
        checksum: "86b4362f8d9a671c91cd8b2996aa61e9b9b0938010594039084efbead7b1adc4",
        filename: "appsignal-x86_64-darwin-all-static.tar.gz"
      },
      "universal-darwin" => %{
        checksum: "86b4362f8d9a671c91cd8b2996aa61e9b9b0938010594039084efbead7b1adc4",
        filename: "appsignal-x86_64-darwin-all-static.tar.gz"
      },
      "aarch64-darwin" => %{
        checksum: "b3543d971d1a8958635dbc188cbdc26d3cb2bcf5aace9eccca539ea3396084c0",
        filename: "appsignal-aarch64-darwin-all-static.tar.gz"
      },
      "arm64-darwin" => %{
        checksum: "b3543d971d1a8958635dbc188cbdc26d3cb2bcf5aace9eccca539ea3396084c0",
        filename: "appsignal-aarch64-darwin-all-static.tar.gz"
      },
      "arm-darwin" => %{
        checksum: "b3543d971d1a8958635dbc188cbdc26d3cb2bcf5aace9eccca539ea3396084c0",
        filename: "appsignal-aarch64-darwin-all-static.tar.gz"
      },
      "aarch64-linux" => %{
        checksum: "095d8158d821952b323d6c4daf90dde0d26a1282fb2fd5f9f258bc6cba7b0f68",
        filename: "appsignal-aarch64-linux-all-static.tar.gz"
      },
      "i686-linux" => %{
        checksum: "429587080a69e5db4b01dd666113c280d70bd7bd66bd63c5b93deda497b7bd0e",
        filename: "appsignal-i686-linux-all-static.tar.gz"
      },
      "x86-linux" => %{
        checksum: "429587080a69e5db4b01dd666113c280d70bd7bd66bd63c5b93deda497b7bd0e",
        filename: "appsignal-i686-linux-all-static.tar.gz"
      },
      "x86_64-linux" => %{
        checksum: "484b7d9e10798700e63ffa9b96fd43f8f244b1da18f32eb0d0fd9999a8e37351",
        filename: "appsignal-x86_64-linux-all-static.tar.gz"
      },
      "x86_64-linux-musl" => %{
        checksum: "9e64cdf5d43e6ddeee70d82c60418e02a42c01b2b0a6abc64efe19f40fa4b7e7",
        filename: "appsignal-x86_64-linux-musl-all-static.tar.gz"
      },
      "aarch64-linux-musl" => %{
        checksum: "1f915b9b40421e0fa5cc7773f0970345b2afa807d578a5dc3f0167340c3ac30f",
        filename: "appsignal-aarch64-linux-musl-all-static.tar.gz"
      },
      "x86_64-freebsd" => %{
        checksum: "39fd2d83a2ec1a16e6e441cb4a846bd82b7087be707c9ca86570499e77e09179",
        filename: "appsignal-x86_64-freebsd-all-static.tar.gz"
      },
      "amd64-freebsd" => %{
        checksum: "39fd2d83a2ec1a16e6e441cb4a846bd82b7087be707c9ca86570499e77e09179",
        filename: "appsignal-x86_64-freebsd-all-static.tar.gz"
      },
    }
  end
end
