# DO NOT EDIT
# This is a generated file by the `rake ship` family of tasks in the
# appsignal-agent repository.
# Modifications to this file will be overwritten with the next agent release.

defmodule Appsignal.Agent do
  def version, do: "d886e68"

  def mirrors do
    [
      "https://appsignal-agent-releases.global.ssl.fastly.net",
      "https://d135dj0rjqvssy.cloudfront.net",
    ]
  end

  def triples do
    %{
      "x86_64-darwin" => %{
        checksum: "9f5e66a45103e2dd8a6885db267ae8e99fb9d616afed2bf56e23a36909d84094",
        filename: "appsignal-x86_64-darwin-all-static.tar.gz"
      },
      "universal-darwin" => %{
        checksum: "9f5e66a45103e2dd8a6885db267ae8e99fb9d616afed2bf56e23a36909d84094",
        filename: "appsignal-x86_64-darwin-all-static.tar.gz"
      },
      "aarch64-darwin" => %{
        checksum: "af68a316de086bed25cfefc02eed17f15cc05d5d752ae884c419b935dfd7e2e0",
        filename: "appsignal-aarch64-darwin-all-static.tar.gz"
      },
      "arm64-darwin" => %{
        checksum: "af68a316de086bed25cfefc02eed17f15cc05d5d752ae884c419b935dfd7e2e0",
        filename: "appsignal-aarch64-darwin-all-static.tar.gz"
      },
      "arm-darwin" => %{
        checksum: "af68a316de086bed25cfefc02eed17f15cc05d5d752ae884c419b935dfd7e2e0",
        filename: "appsignal-aarch64-darwin-all-static.tar.gz"
      },
      "aarch64-linux" => %{
        checksum: "ca63907cdd998e7c7f04ac796d96d2caaec066fa1295657212ee65ae6f98e074",
        filename: "appsignal-aarch64-linux-all-static.tar.gz"
      },
      "i686-linux" => %{
        checksum: "4bef68c4cce40d9ef578e3a69f43242348a45eb4dea06683e322c2fccfedd7a4",
        filename: "appsignal-i686-linux-all-static.tar.gz"
      },
      "x86-linux" => %{
        checksum: "4bef68c4cce40d9ef578e3a69f43242348a45eb4dea06683e322c2fccfedd7a4",
        filename: "appsignal-i686-linux-all-static.tar.gz"
      },
      "x86_64-linux" => %{
        checksum: "1c429f3cd8bf1fb75a1c9e6351bff36cfc0aa6a79d3b9dc7f1988535257b3fe0",
        filename: "appsignal-x86_64-linux-all-static.tar.gz"
      },
      "x86_64-linux-musl" => %{
        checksum: "26c3d44fdcbb4947ab5f2a430a12bb70b19d4d7b161294dae7a859215d5ac6a0",
        filename: "appsignal-x86_64-linux-musl-all-static.tar.gz"
      },
      "aarch64-linux-musl" => %{
        checksum: "eb56ab069499cc3e868bad23c6b587b98625fa869744e3de66653e39b8681918",
        filename: "appsignal-aarch64-linux-musl-all-static.tar.gz"
      },
      "x86_64-freebsd" => %{
        checksum: "86d3d9666d4eb1ae16d3addbd72226e97bd1e06f38c11e4870d4ac0e2a375c42",
        filename: "appsignal-x86_64-freebsd-all-static.tar.gz"
      },
      "amd64-freebsd" => %{
        checksum: "86d3d9666d4eb1ae16d3addbd72226e97bd1e06f38c11e4870d4ac0e2a375c42",
        filename: "appsignal-x86_64-freebsd-all-static.tar.gz"
      },
    }
  end
end
