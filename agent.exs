# DO NOT EDIT
# This is a generated file by the `rake ship` family of tasks in the
# appsignal-agent repository.
# Modifications to this file will be overwritten with the next agent release.

defmodule Appsignal.Agent do
  def version, do: "8f31b1a"

  def mirrors do
    [
      "https://appsignal-agent-releases.global.ssl.fastly.net",
      "https://d135dj0rjqvssy.cloudfront.net",
    ]
  end

  def triples do
    %{
      "x86_64-darwin" => %{
        checksum: "b81667a886ef89319a9d177749dc4acf48814d0f834c2974d0d2b4639dd664e6",
        filename: "appsignal-x86_64-darwin-all-static.tar.gz"
      },
      "universal-darwin" => %{
        checksum: "b81667a886ef89319a9d177749dc4acf48814d0f834c2974d0d2b4639dd664e6",
        filename: "appsignal-x86_64-darwin-all-static.tar.gz"
      },
      "aarch64-darwin" => %{
        checksum: "a1b4aa1d7aaf756bcdc7bcec615033002531c6fb44aa7a2d00abda567bd4e9ab",
        filename: "appsignal-aarch64-darwin-all-static.tar.gz"
      },
      "arm64-darwin" => %{
        checksum: "a1b4aa1d7aaf756bcdc7bcec615033002531c6fb44aa7a2d00abda567bd4e9ab",
        filename: "appsignal-aarch64-darwin-all-static.tar.gz"
      },
      "arm-darwin" => %{
        checksum: "a1b4aa1d7aaf756bcdc7bcec615033002531c6fb44aa7a2d00abda567bd4e9ab",
        filename: "appsignal-aarch64-darwin-all-static.tar.gz"
      },
      "aarch64-linux" => %{
        checksum: "ce212c1672c247d1b72b92aee71a256c1270bb1d52ff7e91c5d48da423b6701d",
        filename: "appsignal-aarch64-linux-all-static.tar.gz"
      },
      "i686-linux" => %{
        checksum: "e2a394ee9b9e4d11572e48cb3dd457f077453e87b8520f54e8150b889b4d7d43",
        filename: "appsignal-i686-linux-all-static.tar.gz"
      },
      "x86-linux" => %{
        checksum: "e2a394ee9b9e4d11572e48cb3dd457f077453e87b8520f54e8150b889b4d7d43",
        filename: "appsignal-i686-linux-all-static.tar.gz"
      },
      "x86_64-linux" => %{
        checksum: "0e4152b1b5e0924a70a3a24604d11bfa2c4df8faea43b30546d6e880b41f9a51",
        filename: "appsignal-x86_64-linux-all-static.tar.gz"
      },
      "x86_64-linux-musl" => %{
        checksum: "26c4e0b857efe69b774cfe68a68ab97a91aee58c3c23ffd32955ca16f8c020fa",
        filename: "appsignal-x86_64-linux-musl-all-static.tar.gz"
      },
      "aarch64-linux-musl" => %{
        checksum: "8b39b9180ac16ca7b99eb226e43fe9be74340fb07b2c002fe1054cb6d2e6b010",
        filename: "appsignal-aarch64-linux-musl-all-static.tar.gz"
      },
      "x86_64-freebsd" => %{
        checksum: "2a0456b860c446938aae1d605193e6732578a39ef0df2a1247266335adc019e9",
        filename: "appsignal-x86_64-freebsd-all-static.tar.gz"
      },
      "amd64-freebsd" => %{
        checksum: "2a0456b860c446938aae1d605193e6732578a39ef0df2a1247266335adc019e9",
        filename: "appsignal-x86_64-freebsd-all-static.tar.gz"
      },
    }
  end
end
