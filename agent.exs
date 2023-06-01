# DO NOT EDIT
# This is a generated file by the `rake ship` family of tasks in the
# appsignal-agent repository.
# Modifications to this file will be overwritten with the next agent release.

defmodule Appsignal.Agent do
  def version, do: "fd8ee9e"

  def mirrors do
    [
      "https://appsignal-agent-releases.global.ssl.fastly.net",
      "https://d135dj0rjqvssy.cloudfront.net",
    ]
  end

  def triples do
    %{
      "x86_64-darwin" => %{
        checksum: "38731cb50e31377053618cd3687ab99d10cc991171b73ea81a40aab49d415fe1",
        filename: "appsignal-x86_64-darwin-all-static.tar.gz"
      },
      "universal-darwin" => %{
        checksum: "38731cb50e31377053618cd3687ab99d10cc991171b73ea81a40aab49d415fe1",
        filename: "appsignal-x86_64-darwin-all-static.tar.gz"
      },
      "aarch64-darwin" => %{
        checksum: "ee791758b84b56ce01482c1c3f65db926457558275f22673442e19a4e9b9c43e",
        filename: "appsignal-aarch64-darwin-all-static.tar.gz"
      },
      "arm64-darwin" => %{
        checksum: "ee791758b84b56ce01482c1c3f65db926457558275f22673442e19a4e9b9c43e",
        filename: "appsignal-aarch64-darwin-all-static.tar.gz"
      },
      "arm-darwin" => %{
        checksum: "ee791758b84b56ce01482c1c3f65db926457558275f22673442e19a4e9b9c43e",
        filename: "appsignal-aarch64-darwin-all-static.tar.gz"
      },
      "aarch64-linux" => %{
        checksum: "65ccb3ed4fdc7f55671ca4ff04beaa97bb01835e0f30b6a5f2e02dbe8b5c31f4",
        filename: "appsignal-aarch64-linux-all-static.tar.gz"
      },
      "i686-linux" => %{
        checksum: "849d2a2ff27814961e1ce9183877a0aedda263f538b0dbfa5e17357e2af00ba4",
        filename: "appsignal-i686-linux-all-static.tar.gz"
      },
      "x86-linux" => %{
        checksum: "849d2a2ff27814961e1ce9183877a0aedda263f538b0dbfa5e17357e2af00ba4",
        filename: "appsignal-i686-linux-all-static.tar.gz"
      },
      "x86_64-linux" => %{
        checksum: "907889dbc50c5f670c1edce503b6f1cdacc52127217611df56b4913137e814f1",
        filename: "appsignal-x86_64-linux-all-static.tar.gz"
      },
      "x86_64-linux-musl" => %{
        checksum: "f4b26fbee43be4bf15033cd3594d8a79d5cd73a95aa62e1949e3a0836345af03",
        filename: "appsignal-x86_64-linux-musl-all-static.tar.gz"
      },
      "aarch64-linux-musl" => %{
        checksum: "d316c1a6a92963ba88c1c578a070eba505e1a466e3af768362122d935af31ccd",
        filename: "appsignal-aarch64-linux-musl-all-static.tar.gz"
      },
      "x86_64-freebsd" => %{
        checksum: "c2d8f903e683ce77f608d7e8d1eadc98a0fd29d19f07110e04cc73c5d2cb887c",
        filename: "appsignal-x86_64-freebsd-all-static.tar.gz"
      },
      "amd64-freebsd" => %{
        checksum: "c2d8f903e683ce77f608d7e8d1eadc98a0fd29d19f07110e04cc73c5d2cb887c",
        filename: "appsignal-x86_64-freebsd-all-static.tar.gz"
      },
    }
  end
end
