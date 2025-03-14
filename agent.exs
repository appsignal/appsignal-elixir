# DO NOT EDIT
# This is a generated file by the `rake publish` family of tasks in the
# appsignal-agent repository.
# Modifications to this file will be overwritten with the next agent release.

defmodule Appsignal.Agent do
  def version, do: "0.36.2"

  def mirrors do
    [
      "https://d135dj0rjqvssy.cloudfront.net",
      "https://appsignal-agent-releases.global.ssl.fastly.net",
    ]
  end

  def triples do
    %{
      "x86_64-darwin" => %{
        checksum: "838d9a9e3f90933dcd1a7764e8d65bc3510915fcf987bebacfa97700b38fde72",
        filename: "appsignal-x86_64-darwin-all-static.tar.gz"
      },
      "universal-darwin" => %{
        checksum: "838d9a9e3f90933dcd1a7764e8d65bc3510915fcf987bebacfa97700b38fde72",
        filename: "appsignal-x86_64-darwin-all-static.tar.gz"
      },
      "aarch64-darwin" => %{
        checksum: "c18a2e088c059a105a7f74a598a71f2916fea52a24eaf70693badf45f5f50c17",
        filename: "appsignal-aarch64-darwin-all-static.tar.gz"
      },
      "arm64-darwin" => %{
        checksum: "c18a2e088c059a105a7f74a598a71f2916fea52a24eaf70693badf45f5f50c17",
        filename: "appsignal-aarch64-darwin-all-static.tar.gz"
      },
      "arm-darwin" => %{
        checksum: "c18a2e088c059a105a7f74a598a71f2916fea52a24eaf70693badf45f5f50c17",
        filename: "appsignal-aarch64-darwin-all-static.tar.gz"
      },
      "aarch64-linux" => %{
        checksum: "8008e7ca60e301e6dd4a7ec18ce68f1dedff4e40c6029af368a9f35ac95c4e70",
        filename: "appsignal-aarch64-linux-all-static.tar.gz"
      },
      "i686-linux" => %{
        checksum: "cc52418f2e828ce9d5ab908e5691fdd4e5ad20264af19a7f00de1678bea57711",
        filename: "appsignal-i686-linux-all-static.tar.gz"
      },
      "x86-linux" => %{
        checksum: "cc52418f2e828ce9d5ab908e5691fdd4e5ad20264af19a7f00de1678bea57711",
        filename: "appsignal-i686-linux-all-static.tar.gz"
      },
      "x86_64-linux" => %{
        checksum: "93465fd24205f2d1576d7318d6cc8da06e5f474236bc6ac3038468d3c5146c9c",
        filename: "appsignal-x86_64-linux-all-static.tar.gz"
      },
      "x86_64-linux-musl" => %{
        checksum: "21478e01005635987df8bc35375d6f363d03ea46feda0fa88da714de9282d71b",
        filename: "appsignal-x86_64-linux-musl-all-static.tar.gz"
      },
      "aarch64-linux-musl" => %{
        checksum: "bf85fe3dd65a6a85e8004eee8269af6f62c4dafa2c39ef4fe50958e3dc7c4d0e",
        filename: "appsignal-aarch64-linux-musl-all-static.tar.gz"
      },
      "x86_64-freebsd" => %{
        checksum: "7355fcf72d6141f7e411351ff0c7c4beffc3c2a3bfaee70732ad301ce24b4bfa",
        filename: "appsignal-x86_64-freebsd-all-static.tar.gz"
      },
      "amd64-freebsd" => %{
        checksum: "7355fcf72d6141f7e411351ff0c7c4beffc3c2a3bfaee70732ad301ce24b4bfa",
        filename: "appsignal-x86_64-freebsd-all-static.tar.gz"
      },
    }
  end
end
