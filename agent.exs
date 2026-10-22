# DO NOT EDIT
# This is a generated file by the `rake publish` family of tasks in the
# appsignal-agent repository.
# Modifications to this file will be overwritten with the next agent release.

defmodule Appsignal.Agent do
  def version, do: "0.37.6"

  def mirrors do
    [
      "https://d135dj0rjqvssy.cloudfront.net",
      "https://appsignal-agent-releases.global.ssl.fastly.net",
    ]
  end

  def triples do
    %{
      "x86_64-darwin" => %{
        checksum: "240c2bf0eeaefb6d1f2e2b9ca59e6cbbfd4cd4a37abd7317c56497d60d72cb14",
        filename: "appsignal-x86_64-darwin-all-static.tar.gz"
      },
      "universal-darwin" => %{
        checksum: "240c2bf0eeaefb6d1f2e2b9ca59e6cbbfd4cd4a37abd7317c56497d60d72cb14",
        filename: "appsignal-x86_64-darwin-all-static.tar.gz"
      },
      "aarch64-darwin" => %{
        checksum: "520942a499289859187bc9b5bb1fc40b1594c4012c626338624ffb2f88a743a6",
        filename: "appsignal-aarch64-darwin-all-static.tar.gz"
      },
      "arm64-darwin" => %{
        checksum: "520942a499289859187bc9b5bb1fc40b1594c4012c626338624ffb2f88a743a6",
        filename: "appsignal-aarch64-darwin-all-static.tar.gz"
      },
      "arm-darwin" => %{
        checksum: "520942a499289859187bc9b5bb1fc40b1594c4012c626338624ffb2f88a743a6",
        filename: "appsignal-aarch64-darwin-all-static.tar.gz"
      },
      "aarch64-linux" => %{
        checksum: "3a80cff49dbb1b81e418511b39d3c52ce34483bcb48961d4c831a1ce723d034e",
        filename: "appsignal-aarch64-linux-all-static.tar.gz"
      },
      "i686-linux" => %{
        checksum: "1a427f1d4de7fa53ed1fe08b941f8f9021f20fbd98c25b9f46a4e2470827c994",
        filename: "appsignal-i686-linux-all-static.tar.gz"
      },
      "x86-linux" => %{
        checksum: "1a427f1d4de7fa53ed1fe08b941f8f9021f20fbd98c25b9f46a4e2470827c994",
        filename: "appsignal-i686-linux-all-static.tar.gz"
      },
      "x86_64-linux" => %{
        checksum: "409f408e6bfac651e2321d9af88b1a986fc6cc6f75e6ab232a48e99f2b7d1f63",
        filename: "appsignal-x86_64-linux-all-static.tar.gz"
      },
      "x86_64-linux-musl" => %{
        checksum: "d4f67eff05d93f1ce2117c16c70f8290d6c032bf4ae047c49bf0ef2be41299e4",
        filename: "appsignal-x86_64-linux-musl-all-static.tar.gz"
      },
      "aarch64-linux-musl" => %{
        checksum: "08d2b39f16a87090e14ef187ce1f327768fee448fb14837421cddc92fa2b18b7",
        filename: "appsignal-aarch64-linux-musl-all-static.tar.gz"
      },
      "x86_64-freebsd" => %{
        checksum: "db678f4a4a6de4f98b59c163e01ea6f423a55237ac683f43ecfa6df3a724518e",
        filename: "appsignal-x86_64-freebsd-all-static.tar.gz"
      },
      "amd64-freebsd" => %{
        checksum: "db678f4a4a6de4f98b59c163e01ea6f423a55237ac683f43ecfa6df3a724518e",
        filename: "appsignal-x86_64-freebsd-all-static.tar.gz"
      },
    }
  end
end
