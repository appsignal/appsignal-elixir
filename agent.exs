# DO NOT EDIT
# This is a generated file by the `rake ship` family of tasks in the
# appsignal-agent repository.
# Modifications to this file will be overwritten with the next agent release.

defmodule Appsignal.Agent do
  def version, do: "5b63505"

  def mirrors do
    [
      "https://appsignal-agent-releases.global.ssl.fastly.net",
      "https://d135dj0rjqvssy.cloudfront.net",
    ]
  end

  def triples do
    %{
      "x86_64-darwin" => %{
        checksum: "122bbf4a5931f850644853a80b3fc929db93e18d32c2c75d487f5dc6a17358f7",
        filename: "appsignal-x86_64-darwin-all-static.tar.gz"
      },
      "universal-darwin" => %{
        checksum: "122bbf4a5931f850644853a80b3fc929db93e18d32c2c75d487f5dc6a17358f7",
        filename: "appsignal-x86_64-darwin-all-static.tar.gz"
      },
      "aarch64-darwin" => %{
        checksum: "b881d9cb9517c4717c7d9180109068d0283d674b161f4827ced05a0a7f884c7c",
        filename: "appsignal-aarch64-darwin-all-static.tar.gz"
      },
      "arm64-darwin" => %{
        checksum: "b881d9cb9517c4717c7d9180109068d0283d674b161f4827ced05a0a7f884c7c",
        filename: "appsignal-aarch64-darwin-all-static.tar.gz"
      },
      "arm-darwin" => %{
        checksum: "b881d9cb9517c4717c7d9180109068d0283d674b161f4827ced05a0a7f884c7c",
        filename: "appsignal-aarch64-darwin-all-static.tar.gz"
      },
      "aarch64-linux" => %{
        checksum: "d2eeac3b67e6629b43965f5056131b79dc9dd5ac3767951c79c9e2d8f7aca8c3",
        filename: "appsignal-aarch64-linux-all-static.tar.gz"
      },
      "i686-linux" => %{
        checksum: "5a292e5a14e737a0a3756573b264ab749f211ff370717b80f9812e837e09392d",
        filename: "appsignal-i686-linux-all-static.tar.gz"
      },
      "x86-linux" => %{
        checksum: "5a292e5a14e737a0a3756573b264ab749f211ff370717b80f9812e837e09392d",
        filename: "appsignal-i686-linux-all-static.tar.gz"
      },
      "x86_64-linux" => %{
        checksum: "3a2688cf0e645d1d881f535ffbcf9602f626d7cc426591c605d89eeabd66d5f7",
        filename: "appsignal-x86_64-linux-all-static.tar.gz"
      },
      "x86_64-linux-musl" => %{
        checksum: "0cab0c9dadd9a9d48df0e35a8e8e1896edad1678d04bb7b5742d571c5fbff4f9",
        filename: "appsignal-x86_64-linux-musl-all-static.tar.gz"
      },
      "x86_64-freebsd" => %{
        checksum: "3f470aaeb68fca7a7e2a7d36f557f23c72056807efc429f2ceef8922e73e8ca2",
        filename: "appsignal-x86_64-freebsd-all-static.tar.gz"
      },
      "amd64-freebsd" => %{
        checksum: "3f470aaeb68fca7a7e2a7d36f557f23c72056807efc429f2ceef8922e73e8ca2",
        filename: "appsignal-x86_64-freebsd-all-static.tar.gz"
      },
    }
  end
end
