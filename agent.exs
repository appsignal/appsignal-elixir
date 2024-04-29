# DO NOT EDIT
# This is a generated file by the `rake ship` family of tasks in the
# appsignal-agent repository.
# Modifications to this file will be overwritten with the next agent release.

defmodule Appsignal.Agent do
  def version, do: "0.35.5"

  def mirrors do
    [
      "https://appsignal-agent-releases.global.ssl.fastly.net",
      "https://d135dj0rjqvssy.cloudfront.net",
    ]
  end

  def triples do
    %{
      "x86_64-darwin" => %{
        checksum: "3985b53b2a2814d44737182890e6fbe31b4b88361025140477a598e0e41fd948",
        filename: "appsignal-x86_64-darwin-all-static.tar.gz"
      },
      "universal-darwin" => %{
        checksum: "3985b53b2a2814d44737182890e6fbe31b4b88361025140477a598e0e41fd948",
        filename: "appsignal-x86_64-darwin-all-static.tar.gz"
      },
      "aarch64-darwin" => %{
        checksum: "79d22436bfe32dab4661f2a4149c6ab34c71e810c5d808ee3e60cd9f8a1395e4",
        filename: "appsignal-aarch64-darwin-all-static.tar.gz"
      },
      "arm64-darwin" => %{
        checksum: "79d22436bfe32dab4661f2a4149c6ab34c71e810c5d808ee3e60cd9f8a1395e4",
        filename: "appsignal-aarch64-darwin-all-static.tar.gz"
      },
      "arm-darwin" => %{
        checksum: "79d22436bfe32dab4661f2a4149c6ab34c71e810c5d808ee3e60cd9f8a1395e4",
        filename: "appsignal-aarch64-darwin-all-static.tar.gz"
      },
      "aarch64-linux" => %{
        checksum: "4a54587bb61f59d0b60032b2e0c1d14d2e726e20af049353c2ff279d07dd3028",
        filename: "appsignal-aarch64-linux-all-static.tar.gz"
      },
      "i686-linux" => %{
        checksum: "01e2237029c3af23cc6f348fb63f65a92b8caf8f4731b78d014bb4001559aad5",
        filename: "appsignal-i686-linux-all-static.tar.gz"
      },
      "x86-linux" => %{
        checksum: "01e2237029c3af23cc6f348fb63f65a92b8caf8f4731b78d014bb4001559aad5",
        filename: "appsignal-i686-linux-all-static.tar.gz"
      },
      "x86_64-linux" => %{
        checksum: "beae1db2c122eb579f1ccb450177b0c64d65569d774efc7a1ee72c42d3382d39",
        filename: "appsignal-x86_64-linux-all-static.tar.gz"
      },
      "x86_64-linux-musl" => %{
        checksum: "521c4486d10cdafa1f72103cc439d6f0e4f549f1522c4473bf43dc487ec42436",
        filename: "appsignal-x86_64-linux-musl-all-static.tar.gz"
      },
      "aarch64-linux-musl" => %{
        checksum: "c29aab31f4ca59efb1483f48c0cb3c27d799347b81655a28f24c146b55aa7db6",
        filename: "appsignal-aarch64-linux-musl-all-static.tar.gz"
      },
      "x86_64-freebsd" => %{
        checksum: "a3598e9df1b6b5970aabbbccbe4e77c2372d2320cd87bfa20f32fca53b8505e4",
        filename: "appsignal-x86_64-freebsd-all-static.tar.gz"
      },
      "amd64-freebsd" => %{
        checksum: "a3598e9df1b6b5970aabbbccbe4e77c2372d2320cd87bfa20f32fca53b8505e4",
        filename: "appsignal-x86_64-freebsd-all-static.tar.gz"
      },
    }
  end
end
