# DO NOT EDIT
# This is a generated file by the `rake publish` family of tasks in the
# appsignal-agent repository.
# Modifications to this file will be overwritten with the next agent release.

defmodule Appsignal.Agent do
  def version, do: "0.35.26"

  def mirrors do
    [
      "https://d135dj0rjqvssy.cloudfront.net",
      "https://appsignal-agent-releases.global.ssl.fastly.net",
    ]
  end

  def triples do
    %{
      "x86_64-darwin" => %{
        checksum: "e0b0674dad04528f14048a0941fdacf9cbdb317627116c9b4dd7b786e572caa3",
        filename: "appsignal-x86_64-darwin-all-static.tar.gz"
      },
      "universal-darwin" => %{
        checksum: "e0b0674dad04528f14048a0941fdacf9cbdb317627116c9b4dd7b786e572caa3",
        filename: "appsignal-x86_64-darwin-all-static.tar.gz"
      },
      "aarch64-darwin" => %{
        checksum: "377d6eac5dc10de28275ec88a368f1c5da61438afa41f0767803d6c3a9399717",
        filename: "appsignal-aarch64-darwin-all-static.tar.gz"
      },
      "arm64-darwin" => %{
        checksum: "377d6eac5dc10de28275ec88a368f1c5da61438afa41f0767803d6c3a9399717",
        filename: "appsignal-aarch64-darwin-all-static.tar.gz"
      },
      "arm-darwin" => %{
        checksum: "377d6eac5dc10de28275ec88a368f1c5da61438afa41f0767803d6c3a9399717",
        filename: "appsignal-aarch64-darwin-all-static.tar.gz"
      },
      "aarch64-linux" => %{
        checksum: "67f927b89d9ef65f063c487bcd5bef832051a547d0b0f911589b4f90554c3185",
        filename: "appsignal-aarch64-linux-all-static.tar.gz"
      },
      "i686-linux" => %{
        checksum: "aee4d5a74c0d5a39bf7047b2fb0c1ab0af4151bdf20b23c7095b024d8f34d6eb",
        filename: "appsignal-i686-linux-all-static.tar.gz"
      },
      "x86-linux" => %{
        checksum: "aee4d5a74c0d5a39bf7047b2fb0c1ab0af4151bdf20b23c7095b024d8f34d6eb",
        filename: "appsignal-i686-linux-all-static.tar.gz"
      },
      "x86_64-linux" => %{
        checksum: "595eef52453a179a6c5fde2a5d7206a85e07970a2dbceb631a19af20e05b46db",
        filename: "appsignal-x86_64-linux-all-static.tar.gz"
      },
      "x86_64-linux-musl" => %{
        checksum: "5992db83dc784e4aaec4cc4d4ebbd62a9d68ae7197697c34f3d4d820233c3238",
        filename: "appsignal-x86_64-linux-musl-all-static.tar.gz"
      },
      "aarch64-linux-musl" => %{
        checksum: "f5d35cea12db1d473757d5fbed9c66e2018b6eaf35e0c96b2787f67e08ceae13",
        filename: "appsignal-aarch64-linux-musl-all-static.tar.gz"
      },
      "x86_64-freebsd" => %{
        checksum: "6a696cde1d84fbc56e152d560100bd941276e7b1ddda38de81bc3e985780366a",
        filename: "appsignal-x86_64-freebsd-all-static.tar.gz"
      },
      "amd64-freebsd" => %{
        checksum: "6a696cde1d84fbc56e152d560100bd941276e7b1ddda38de81bc3e985780366a",
        filename: "appsignal-x86_64-freebsd-all-static.tar.gz"
      },
    }
  end
end
