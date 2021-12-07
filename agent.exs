# DO NOT EDIT
# This is a generated file by the `rake ship` family of tasks in the
# appsignal-agent repository.
# Modifications to this file will be overwritten with the next agent release.

defmodule Appsignal.Agent do
  def version, do: "0db01c2"

  def mirrors do
    [
      "https://appsignal-agent-releases.global.ssl.fastly.net",
      "https://d135dj0rjqvssy.cloudfront.net",
    ]
  end

  def triples do
    %{
      "x86_64-darwin" => %{
        checksum: "8a7cf35f8c9aa98e7778b720f33b38bfbdedcdedb0047035259ab187517be971",
        filename: "appsignal-x86_64-darwin-all-static.tar.gz"
      },
      "universal-darwin" => %{
        checksum: "8a7cf35f8c9aa98e7778b720f33b38bfbdedcdedb0047035259ab187517be971",
        filename: "appsignal-x86_64-darwin-all-static.tar.gz"
      },
      "aarch64-darwin" => %{
        checksum: "a22cd07e656f194dd1921983be6507816b60c79bc0c4623d2cac5c88fda9d407",
        filename: "appsignal-aarch64-darwin-all-static.tar.gz"
      },
      "arm64-darwin" => %{
        checksum: "a22cd07e656f194dd1921983be6507816b60c79bc0c4623d2cac5c88fda9d407",
        filename: "appsignal-aarch64-darwin-all-static.tar.gz"
      },
      "arm-darwin" => %{
        checksum: "a22cd07e656f194dd1921983be6507816b60c79bc0c4623d2cac5c88fda9d407",
        filename: "appsignal-aarch64-darwin-all-static.tar.gz"
      },
      "aarch64-linux" => %{
        checksum: "edf43f1a6b340c0afa07c7b71963def9bb68bd8d62d17cb64a7f7a36f84a4517",
        filename: "appsignal-aarch64-linux-all-static.tar.gz"
      },
      "i686-linux" => %{
        checksum: "4179334f88dc32e00ce62aa196b3e47b4258b12ec48dd3cf722d4f6eeb4dc2c0",
        filename: "appsignal-i686-linux-all-static.tar.gz"
      },
      "x86-linux" => %{
        checksum: "4179334f88dc32e00ce62aa196b3e47b4258b12ec48dd3cf722d4f6eeb4dc2c0",
        filename: "appsignal-i686-linux-all-static.tar.gz"
      },
      "x86_64-linux" => %{
        checksum: "d602823277cac752bdea742d928112cef457bc61ee05b960b316fc052f0cc714",
        filename: "appsignal-x86_64-linux-all-static.tar.gz"
      },
      "x86_64-linux-musl" => %{
        checksum: "dfbdff116339b99613fff6ed4092b772e58f0d3e667b7de347b4215fb7ea9d62",
        filename: "appsignal-x86_64-linux-musl-all-static.tar.gz"
      },
      "x86_64-freebsd" => %{
        checksum: "e31a7d89798193857247bd3590a554782fcff64b65d3da86d9c451d3147e961a",
        filename: "appsignal-x86_64-freebsd-all-static.tar.gz"
      },
      "amd64-freebsd" => %{
        checksum: "e31a7d89798193857247bd3590a554782fcff64b65d3da86d9c451d3147e961a",
        filename: "appsignal-x86_64-freebsd-all-static.tar.gz"
      },
    }
  end
end
