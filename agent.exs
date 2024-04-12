# DO NOT EDIT
# This is a generated file by the `rake ship` family of tasks in the
# appsignal-agent repository.
# Modifications to this file will be overwritten with the next agent release.

defmodule Appsignal.Agent do
  def version, do: "0.34.3"

  def mirrors do
    [
      "https://appsignal-agent-releases.global.ssl.fastly.net",
      "https://d135dj0rjqvssy.cloudfront.net",
    ]
  end

  def triples do
    %{
      "x86_64-darwin" => %{
        checksum: "f18ee8d23371c32e5bb90ab0d0b0362736f55a0bf7cb266eb61d3af97f71d7e8",
        filename: "appsignal-x86_64-darwin-all-static.tar.gz"
      },
      "universal-darwin" => %{
        checksum: "f18ee8d23371c32e5bb90ab0d0b0362736f55a0bf7cb266eb61d3af97f71d7e8",
        filename: "appsignal-x86_64-darwin-all-static.tar.gz"
      },
      "aarch64-darwin" => %{
        checksum: "4431eef769b1c4c7fee2146dc896ac8806e10d683c814f2d9790142173936c8e",
        filename: "appsignal-aarch64-darwin-all-static.tar.gz"
      },
      "arm64-darwin" => %{
        checksum: "4431eef769b1c4c7fee2146dc896ac8806e10d683c814f2d9790142173936c8e",
        filename: "appsignal-aarch64-darwin-all-static.tar.gz"
      },
      "arm-darwin" => %{
        checksum: "4431eef769b1c4c7fee2146dc896ac8806e10d683c814f2d9790142173936c8e",
        filename: "appsignal-aarch64-darwin-all-static.tar.gz"
      },
      "aarch64-linux" => %{
        checksum: "70dad154a9281009b5e309d0c5e366d187249ec43c13750ad8e03e52838b062f",
        filename: "appsignal-aarch64-linux-all-static.tar.gz"
      },
      "i686-linux" => %{
        checksum: "827f656b6bc6c62c0a949b8f94224baaff3da2de8ff8a493dfd9d390cc0d50b2",
        filename: "appsignal-i686-linux-all-static.tar.gz"
      },
      "x86-linux" => %{
        checksum: "827f656b6bc6c62c0a949b8f94224baaff3da2de8ff8a493dfd9d390cc0d50b2",
        filename: "appsignal-i686-linux-all-static.tar.gz"
      },
      "x86_64-linux" => %{
        checksum: "6fb5be7677165f4725583e8e06c870177a83134c497c6fe38f29b540eb0c86db",
        filename: "appsignal-x86_64-linux-all-static.tar.gz"
      },
      "x86_64-linux-musl" => %{
        checksum: "23392fefdc3f892b7a8c1f6a103e54a59c0a402c48844d97afc511fa200a7415",
        filename: "appsignal-x86_64-linux-musl-all-static.tar.gz"
      },
      "aarch64-linux-musl" => %{
        checksum: "580d5f87abff3027e7c776d3f05ed713edc40434a1de5c90994ef6673837c5fe",
        filename: "appsignal-aarch64-linux-musl-all-static.tar.gz"
      },
      "x86_64-freebsd" => %{
        checksum: "7db5a03be4f391cabc772202c7a8800322d5756096d0361a4062e4ac670b947c",
        filename: "appsignal-x86_64-freebsd-all-static.tar.gz"
      },
      "amd64-freebsd" => %{
        checksum: "7db5a03be4f391cabc772202c7a8800322d5756096d0361a4062e4ac670b947c",
        filename: "appsignal-x86_64-freebsd-all-static.tar.gz"
      },
    }
  end
end
