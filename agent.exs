# DO NOT EDIT
# This is a generated file by the `rake ship` family of tasks in the
# appsignal-agent repository.
# Modifications to this file will be overwritten with the next agent release.

defmodule Appsignal.Agent do
  def version, do: "b5fe1ad"

  def mirrors do
    [
      "https://appsignal-agent-releases.global.ssl.fastly.net",
      "https://d135dj0rjqvssy.cloudfront.net",
    ]
  end

  def triples do
    %{
      "x86_64-darwin" => %{
        checksum: "972b26f9b555706ec0663a6fdc520574db26eafa878ade20e58414c64b2ec6fe",
        filename: "appsignal-x86_64-darwin-all-static.tar.gz"
      },
      "universal-darwin" => %{
        checksum: "972b26f9b555706ec0663a6fdc520574db26eafa878ade20e58414c64b2ec6fe",
        filename: "appsignal-x86_64-darwin-all-static.tar.gz"
      },
      "aarch64-darwin" => %{
        checksum: "6ca2ae0644fd9bb6ba48226f23862187ba4c449fe4ba78ad90556f373a5e63d1",
        filename: "appsignal-aarch64-darwin-all-static.tar.gz"
      },
      "arm64-darwin" => %{
        checksum: "6ca2ae0644fd9bb6ba48226f23862187ba4c449fe4ba78ad90556f373a5e63d1",
        filename: "appsignal-aarch64-darwin-all-static.tar.gz"
      },
      "arm-darwin" => %{
        checksum: "6ca2ae0644fd9bb6ba48226f23862187ba4c449fe4ba78ad90556f373a5e63d1",
        filename: "appsignal-aarch64-darwin-all-static.tar.gz"
      },
      "aarch64-linux" => %{
        checksum: "1c80e4d09f8ffb6e8dc279b3174ce64f764689c4696acf73858f6bcc5bd17d1f",
        filename: "appsignal-aarch64-linux-all-static.tar.gz"
      },
      "i686-linux" => %{
        checksum: "4974d598e22bc7446b0687916e08d03fbd6269407eb5d8be586a80d74020842b",
        filename: "appsignal-i686-linux-all-static.tar.gz"
      },
      "x86-linux" => %{
        checksum: "4974d598e22bc7446b0687916e08d03fbd6269407eb5d8be586a80d74020842b",
        filename: "appsignal-i686-linux-all-static.tar.gz"
      },
      "x86_64-linux" => %{
        checksum: "928d57d8a55e90432884ae86e8711c73b49cc76e486320526d54dc466b37070d",
        filename: "appsignal-x86_64-linux-all-static.tar.gz"
      },
      "x86_64-linux-musl" => %{
        checksum: "7bdb2a2c78e3d0bc5c97c0ab393a1009bf2f7f8b5596605b044c2e6adb822be4",
        filename: "appsignal-x86_64-linux-musl-all-static.tar.gz"
      },
      "aarch64-linux-musl" => %{
        checksum: "54344c422743ae92194956efd962b56b0fb5b9536d54e701ff2e82806898aa0f",
        filename: "appsignal-aarch64-linux-musl-all-static.tar.gz"
      },
      "x86_64-freebsd" => %{
        checksum: "aaee1c86f0b16579a6a14914249b5c2d0e0328c26a5df0b2f704199600f3d93f",
        filename: "appsignal-x86_64-freebsd-all-static.tar.gz"
      },
      "amd64-freebsd" => %{
        checksum: "aaee1c86f0b16579a6a14914249b5c2d0e0328c26a5df0b2f704199600f3d93f",
        filename: "appsignal-x86_64-freebsd-all-static.tar.gz"
      },
    }
  end
end
