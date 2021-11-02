# DO NOT EDIT
# This is a generated file by the `rake ship` family of tasks in the
# appsignal-agent repository.
# Modifications to this file will be overwritten with the next agent release.

defmodule Appsignal.Agent do
  def version, do: "09308fb"

  def mirrors do
    [
      "https://appsignal-agent-releases.global.ssl.fastly.net",
      "https://d135dj0rjqvssy.cloudfront.net",
    ]
  end

  def triples do
    %{
      "x86_64-darwin" => %{
        checksum: "72e3e84ce59f4b84287f0d72ec567447a28e42fb758eb27dd7676cd7613eb2e9",
        filename: "appsignal-x86_64-darwin-all-static.tar.gz"
      },
      "universal-darwin" => %{
        checksum: "72e3e84ce59f4b84287f0d72ec567447a28e42fb758eb27dd7676cd7613eb2e9",
        filename: "appsignal-x86_64-darwin-all-static.tar.gz"
      },
      "aarch64-darwin" => %{
        checksum: "446da8ea04b9a23de970332fb30fa7aa44b5aa3da371a8bacc240b3c8dfef3df",
        filename: "appsignal-aarch64-darwin-all-static.tar.gz"
      },
      "arm64-darwin" => %{
        checksum: "446da8ea04b9a23de970332fb30fa7aa44b5aa3da371a8bacc240b3c8dfef3df",
        filename: "appsignal-aarch64-darwin-all-static.tar.gz"
      },
      "arm-darwin" => %{
        checksum: "446da8ea04b9a23de970332fb30fa7aa44b5aa3da371a8bacc240b3c8dfef3df",
        filename: "appsignal-aarch64-darwin-all-static.tar.gz"
      },
      "aarch64-linux" => %{
        checksum: "d14ed2b2ba05b7a0a229eaba8ee710c35ff0c8681084ec5d0650fb53dae7b3d3",
        filename: "appsignal-aarch64-linux-all-static.tar.gz"
      },
      "i686-linux" => %{
        checksum: "18cd5ef04e547dcc522faa0a462a00bac27e9bd221bd4dd8e6e2e934d4afd5b7",
        filename: "appsignal-i686-linux-all-static.tar.gz"
      },
      "x86-linux" => %{
        checksum: "18cd5ef04e547dcc522faa0a462a00bac27e9bd221bd4dd8e6e2e934d4afd5b7",
        filename: "appsignal-i686-linux-all-static.tar.gz"
      },
      "x86_64-linux" => %{
        checksum: "98aaa72590d45b8a6aec3d8222468d1875f8fc798f1d891b6424749102d0b0f0",
        filename: "appsignal-x86_64-linux-all-static.tar.gz"
      },
      "x86_64-linux-musl" => %{
        checksum: "1e2685775d45299e6f6b7439f44586c87fcb6ae14e3eb4f2ed0034b5ffed4d42",
        filename: "appsignal-x86_64-linux-musl-all-static.tar.gz"
      },
      "x86_64-freebsd" => %{
        checksum: "7ffd025a7dccca6f6730df2146faeb541fb0a4659fb802e88587471cd625ca94",
        filename: "appsignal-x86_64-freebsd-all-static.tar.gz"
      },
      "amd64-freebsd" => %{
        checksum: "7ffd025a7dccca6f6730df2146faeb541fb0a4659fb802e88587471cd625ca94",
        filename: "appsignal-x86_64-freebsd-all-static.tar.gz"
      },
    }
  end
end
