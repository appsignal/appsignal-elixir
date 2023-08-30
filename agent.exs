# DO NOT EDIT
# This is a generated file by the `rake ship` family of tasks in the
# appsignal-agent repository.
# Modifications to this file will be overwritten with the next agent release.

defmodule Appsignal.Agent do
  def version, do: "6133900"

  def mirrors do
    [
      "https://appsignal-agent-releases.global.ssl.fastly.net",
      "https://d135dj0rjqvssy.cloudfront.net",
    ]
  end

  def triples do
    %{
      "x86_64-darwin" => %{
        checksum: "19cfea536fc6c4a8fe335a26d14ce955b422c23217902642f95d7df670152238",
        filename: "appsignal-x86_64-darwin-all-static.tar.gz"
      },
      "universal-darwin" => %{
        checksum: "19cfea536fc6c4a8fe335a26d14ce955b422c23217902642f95d7df670152238",
        filename: "appsignal-x86_64-darwin-all-static.tar.gz"
      },
      "aarch64-darwin" => %{
        checksum: "4fa0dbccba79f70edc6844a86bfd047ccdd612d752b65aff46fe0e21d8a610ea",
        filename: "appsignal-aarch64-darwin-all-static.tar.gz"
      },
      "arm64-darwin" => %{
        checksum: "4fa0dbccba79f70edc6844a86bfd047ccdd612d752b65aff46fe0e21d8a610ea",
        filename: "appsignal-aarch64-darwin-all-static.tar.gz"
      },
      "arm-darwin" => %{
        checksum: "4fa0dbccba79f70edc6844a86bfd047ccdd612d752b65aff46fe0e21d8a610ea",
        filename: "appsignal-aarch64-darwin-all-static.tar.gz"
      },
      "aarch64-linux" => %{
        checksum: "cdd75637940fcfd369b569e873048c7d37a3844d9d31d783e4459b375b78ee0e",
        filename: "appsignal-aarch64-linux-all-static.tar.gz"
      },
      "i686-linux" => %{
        checksum: "a9374d1fd4baae84f1c4a74957cbb8c919b29ae2ab05a571ff75b9ca483717ab",
        filename: "appsignal-i686-linux-all-static.tar.gz"
      },
      "x86-linux" => %{
        checksum: "a9374d1fd4baae84f1c4a74957cbb8c919b29ae2ab05a571ff75b9ca483717ab",
        filename: "appsignal-i686-linux-all-static.tar.gz"
      },
      "x86_64-linux" => %{
        checksum: "bd625ed84100d0632b298ac602b152463628c41afe56a8621745cdae626f8413",
        filename: "appsignal-x86_64-linux-all-static.tar.gz"
      },
      "x86_64-linux-musl" => %{
        checksum: "7988c4a2a6ba5d59be2186ce9bf51ab50b6537a60888b08c8e9066172516e59d",
        filename: "appsignal-x86_64-linux-musl-all-static.tar.gz"
      },
      "aarch64-linux-musl" => %{
        checksum: "8e5fe2a8bc4cb7de4ba7d61fec48f15aa0cd580050f67752f07625853636eb16",
        filename: "appsignal-aarch64-linux-musl-all-static.tar.gz"
      },
      "x86_64-freebsd" => %{
        checksum: "09e21821eb98ad6afdb5d3708b67ea25799aedbee2ccb0d566b99d9c5703cb1e",
        filename: "appsignal-x86_64-freebsd-all-static.tar.gz"
      },
      "amd64-freebsd" => %{
        checksum: "09e21821eb98ad6afdb5d3708b67ea25799aedbee2ccb0d566b99d9c5703cb1e",
        filename: "appsignal-x86_64-freebsd-all-static.tar.gz"
      },
    }
  end
end
