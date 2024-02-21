# DO NOT EDIT
# This is a generated file by the `rake ship` family of tasks in the
# appsignal-agent repository.
# Modifications to this file will be overwritten with the next agent release.

defmodule Appsignal.Agent do
  def version, do: "0.33.1"

  def mirrors do
    [
      "https://appsignal-agent-releases.global.ssl.fastly.net",
      "https://d135dj0rjqvssy.cloudfront.net",
    ]
  end

  def triples do
    %{
      "x86_64-darwin" => %{
        checksum: "d76923df6dd73e732eb32cad402b6ac8aa6f59ecf90551fd941ea7eb56f61aa4",
        filename: "appsignal-x86_64-darwin-all-static.tar.gz"
      },
      "universal-darwin" => %{
        checksum: "d76923df6dd73e732eb32cad402b6ac8aa6f59ecf90551fd941ea7eb56f61aa4",
        filename: "appsignal-x86_64-darwin-all-static.tar.gz"
      },
      "aarch64-darwin" => %{
        checksum: "730c405a37dba1f777da0cb90b08cc05e1c84315bff91ba879eea108f6c91c5b",
        filename: "appsignal-aarch64-darwin-all-static.tar.gz"
      },
      "arm64-darwin" => %{
        checksum: "730c405a37dba1f777da0cb90b08cc05e1c84315bff91ba879eea108f6c91c5b",
        filename: "appsignal-aarch64-darwin-all-static.tar.gz"
      },
      "arm-darwin" => %{
        checksum: "730c405a37dba1f777da0cb90b08cc05e1c84315bff91ba879eea108f6c91c5b",
        filename: "appsignal-aarch64-darwin-all-static.tar.gz"
      },
      "aarch64-linux" => %{
        checksum: "787f6251bf18da3ba87c0501bfd71613f86a38bb7106dc8c51f3d6de981b7d57",
        filename: "appsignal-aarch64-linux-all-static.tar.gz"
      },
      "i686-linux" => %{
        checksum: "e49f31a5c3919b85f0df8e0edf7e68c3ba870a446648951b9fb74f90b39f96e0",
        filename: "appsignal-i686-linux-all-static.tar.gz"
      },
      "x86-linux" => %{
        checksum: "e49f31a5c3919b85f0df8e0edf7e68c3ba870a446648951b9fb74f90b39f96e0",
        filename: "appsignal-i686-linux-all-static.tar.gz"
      },
      "x86_64-linux" => %{
        checksum: "18ba0fc691518d06ac9677d075a6a94882b5343b2cb25238d935d6963f94bcac",
        filename: "appsignal-x86_64-linux-all-static.tar.gz"
      },
      "x86_64-linux-musl" => %{
        checksum: "fc89f2353a5ef8940f68dc87d1587f7f2832648899e707aa8978a8d56f52fe71",
        filename: "appsignal-x86_64-linux-musl-all-static.tar.gz"
      },
      "aarch64-linux-musl" => %{
        checksum: "512d38d277dcddec05b70bd8a5f100a13c18e5dcf326562ca856674852698c5a",
        filename: "appsignal-aarch64-linux-musl-all-static.tar.gz"
      },
      "x86_64-freebsd" => %{
        checksum: "4ce1fa4c513a5cbcd5262a35f521c8e8d3ffb44a2f05b81891a09a3b4e96c33e",
        filename: "appsignal-x86_64-freebsd-all-static.tar.gz"
      },
      "amd64-freebsd" => %{
        checksum: "4ce1fa4c513a5cbcd5262a35f521c8e8d3ffb44a2f05b81891a09a3b4e96c33e",
        filename: "appsignal-x86_64-freebsd-all-static.tar.gz"
      },
    }
  end
end
