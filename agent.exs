# DO NOT EDIT
# This is a generated file by the `rake ship` family of tasks in the
# appsignal-agent repository.
# Modifications to this file will be overwritten with the next agent release.

defmodule Appsignal.Agent do
  def version, do: "0.33.0"

  def mirrors do
    [
      "https://appsignal-agent-releases.global.ssl.fastly.net",
      "https://d135dj0rjqvssy.cloudfront.net",
    ]
  end

  def triples do
    %{
      "x86_64-darwin" => %{
        checksum: "aa026c58c6b13e09eaede5c362472e86f25c896ce9d33e6928a967372f0894be",
        filename: "appsignal-x86_64-darwin-all-static.tar.gz"
      },
      "universal-darwin" => %{
        checksum: "aa026c58c6b13e09eaede5c362472e86f25c896ce9d33e6928a967372f0894be",
        filename: "appsignal-x86_64-darwin-all-static.tar.gz"
      },
      "aarch64-darwin" => %{
        checksum: "4318b13bba02f8a98226e9d747a42267f790932a0893b451567b7611fb09961b",
        filename: "appsignal-aarch64-darwin-all-static.tar.gz"
      },
      "arm64-darwin" => %{
        checksum: "4318b13bba02f8a98226e9d747a42267f790932a0893b451567b7611fb09961b",
        filename: "appsignal-aarch64-darwin-all-static.tar.gz"
      },
      "arm-darwin" => %{
        checksum: "4318b13bba02f8a98226e9d747a42267f790932a0893b451567b7611fb09961b",
        filename: "appsignal-aarch64-darwin-all-static.tar.gz"
      },
      "aarch64-linux" => %{
        checksum: "0eecbb8469d87a632a70c3c551e07b3c77e084c41438c9c165f6a439fe9f2b4f",
        filename: "appsignal-aarch64-linux-all-static.tar.gz"
      },
      "i686-linux" => %{
        checksum: "75780f506b51be891e85e12e8d51023b82ec8300f8fc293396beeee41f0d357b",
        filename: "appsignal-i686-linux-all-static.tar.gz"
      },
      "x86-linux" => %{
        checksum: "75780f506b51be891e85e12e8d51023b82ec8300f8fc293396beeee41f0d357b",
        filename: "appsignal-i686-linux-all-static.tar.gz"
      },
      "x86_64-linux" => %{
        checksum: "6b15d0110ed9c13b6446bebdaa19e41810f0b2cb9da37b7c1a62a4876147de47",
        filename: "appsignal-x86_64-linux-all-static.tar.gz"
      },
      "x86_64-linux-musl" => %{
        checksum: "d4805021560de3971622a95af0dfb06b3f1c69fab3f8ae1bf3c40f1204a076fb",
        filename: "appsignal-x86_64-linux-musl-all-static.tar.gz"
      },
      "aarch64-linux-musl" => %{
        checksum: "28881989d5f3d3691f9dd96b04298aa6fcd34292a2d304b251617bfbd05b214e",
        filename: "appsignal-aarch64-linux-musl-all-static.tar.gz"
      },
      "x86_64-freebsd" => %{
        checksum: "490f61a8b36e31dc21fd9e96975b75428f7d83f0842bb29a02c36f9f3745b07e",
        filename: "appsignal-x86_64-freebsd-all-static.tar.gz"
      },
      "amd64-freebsd" => %{
        checksum: "490f61a8b36e31dc21fd9e96975b75428f7d83f0842bb29a02c36f9f3745b07e",
        filename: "appsignal-x86_64-freebsd-all-static.tar.gz"
      },
    }
  end
end
