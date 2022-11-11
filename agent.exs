# DO NOT EDIT
# This is a generated file by the `rake ship` family of tasks in the
# appsignal-agent repository.
# Modifications to this file will be overwritten with the next agent release.

defmodule Appsignal.Agent do
  def version, do: "9b62288"

  def mirrors do
    [
      "https://appsignal-agent-releases.global.ssl.fastly.net",
      "https://d135dj0rjqvssy.cloudfront.net",
    ]
  end

  def triples do
    %{
      "x86_64-darwin" => %{
        checksum: "5ff2ec4f16f5089e15188670b2c43866c76ab5db2ac07d72878a9816e63171ca",
        filename: "appsignal-x86_64-darwin-all-static.tar.gz"
      },
      "universal-darwin" => %{
        checksum: "5ff2ec4f16f5089e15188670b2c43866c76ab5db2ac07d72878a9816e63171ca",
        filename: "appsignal-x86_64-darwin-all-static.tar.gz"
      },
      "aarch64-darwin" => %{
        checksum: "9dfdfd6697b3eeeb80a30356fdc1d03a79b8601f18cedd1b2c1442e512d2ed6a",
        filename: "appsignal-aarch64-darwin-all-static.tar.gz"
      },
      "arm64-darwin" => %{
        checksum: "9dfdfd6697b3eeeb80a30356fdc1d03a79b8601f18cedd1b2c1442e512d2ed6a",
        filename: "appsignal-aarch64-darwin-all-static.tar.gz"
      },
      "arm-darwin" => %{
        checksum: "9dfdfd6697b3eeeb80a30356fdc1d03a79b8601f18cedd1b2c1442e512d2ed6a",
        filename: "appsignal-aarch64-darwin-all-static.tar.gz"
      },
      "aarch64-linux" => %{
        checksum: "0e5d89aeda1e883c912ff069bb76029a1e3cad69f493865d877ffaffa2b45142",
        filename: "appsignal-aarch64-linux-all-static.tar.gz"
      },
      "i686-linux" => %{
        checksum: "ff3cffb1204afd846ba0bb33c50b03f8ada8305527a5908ccfebed6fdcce0e61",
        filename: "appsignal-i686-linux-all-static.tar.gz"
      },
      "x86-linux" => %{
        checksum: "ff3cffb1204afd846ba0bb33c50b03f8ada8305527a5908ccfebed6fdcce0e61",
        filename: "appsignal-i686-linux-all-static.tar.gz"
      },
      "x86_64-linux" => %{
        checksum: "0b6fe4b343461a1a906fc73edb44bc5b12c75214d21fc81ed26d3eb88588003e",
        filename: "appsignal-x86_64-linux-all-static.tar.gz"
      },
      "x86_64-linux-musl" => %{
        checksum: "b3f52d7a7a1f4ae8095dd5b1207270dc1797766820d925aca0d09133983c9163",
        filename: "appsignal-x86_64-linux-musl-all-static.tar.gz"
      },
      "aarch64-linux-musl" => %{
        checksum: "d306c50cc9f1bc8ea3339b4185b2a60a1c27f17d9067a529b1889d74c6c0a8d6",
        filename: "appsignal-aarch64-linux-musl-all-static.tar.gz"
      },
      "x86_64-freebsd" => %{
        checksum: "135d2ff898f30b15721eca36569d1a0a5deaaee7b4787937d0888ed49f25019b",
        filename: "appsignal-x86_64-freebsd-all-static.tar.gz"
      },
      "amd64-freebsd" => %{
        checksum: "135d2ff898f30b15721eca36569d1a0a5deaaee7b4787937d0888ed49f25019b",
        filename: "appsignal-x86_64-freebsd-all-static.tar.gz"
      },
    }
  end
end
