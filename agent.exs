# DO NOT EDIT
# This is a generated file by the `rake ship` family of tasks in the
# appsignal-agent repository.
# Modifications to this file will be overwritten with the next agent release.

defmodule Appsignal.Agent do
  def version, do: "e8207c1"

  def mirrors do
    [
      "https://appsignal-agent-releases.global.ssl.fastly.net",
      "https://d135dj0rjqvssy.cloudfront.net",
    ]
  end

  def triples do
    %{
      "x86_64-darwin" => %{
        checksum: "b4f9460cee052fb278e854abd0253c62844cf872c1be8fec6f04474fbdbab6b7",
        filename: "appsignal-x86_64-darwin-all-static.tar.gz"
      },
      "universal-darwin" => %{
        checksum: "b4f9460cee052fb278e854abd0253c62844cf872c1be8fec6f04474fbdbab6b7",
        filename: "appsignal-x86_64-darwin-all-static.tar.gz"
      },
      "aarch64-darwin" => %{
        checksum: "47ab9a2778483ed7c35844778eaa983809679a70642739f30ad8d18c2cd7a578",
        filename: "appsignal-aarch64-darwin-all-static.tar.gz"
      },
      "arm64-darwin" => %{
        checksum: "47ab9a2778483ed7c35844778eaa983809679a70642739f30ad8d18c2cd7a578",
        filename: "appsignal-aarch64-darwin-all-static.tar.gz"
      },
      "arm-darwin" => %{
        checksum: "47ab9a2778483ed7c35844778eaa983809679a70642739f30ad8d18c2cd7a578",
        filename: "appsignal-aarch64-darwin-all-static.tar.gz"
      },
      "aarch64-linux" => %{
        checksum: "dfecb037362aac064d6a697c3e4ce293136a8e459894b2928c0120c6393db22a",
        filename: "appsignal-aarch64-linux-all-static.tar.gz"
      },
      "i686-linux" => %{
        checksum: "a98181bfc8c7557468253c863185f68907b0d2283023f318da26dae8f997b566",
        filename: "appsignal-i686-linux-all-static.tar.gz"
      },
      "x86-linux" => %{
        checksum: "a98181bfc8c7557468253c863185f68907b0d2283023f318da26dae8f997b566",
        filename: "appsignal-i686-linux-all-static.tar.gz"
      },
      "x86_64-linux" => %{
        checksum: "3350aec725af61a3eeb83971c0ee1da6dee761df3f2099945dd5ced9a0193a50",
        filename: "appsignal-x86_64-linux-all-static.tar.gz"
      },
      "x86_64-linux-musl" => %{
        checksum: "eaab36b010bdc5b06ac4646b6d4ebb94523a9f852a2a2cbaba7738b3fade64d1",
        filename: "appsignal-x86_64-linux-musl-all-static.tar.gz"
      },
      "aarch64-linux-musl" => %{
        checksum: "ad371eabe4e2484f7fb980e8bb53d7b079a473d615cbb738271d36f7ad81c71f",
        filename: "appsignal-aarch64-linux-musl-all-static.tar.gz"
      },
      "x86_64-freebsd" => %{
        checksum: "b1b86d145b07b030788e1e5f21089efbda103f11ec3c11ff77c388aaa1856d4d",
        filename: "appsignal-x86_64-freebsd-all-static.tar.gz"
      },
      "amd64-freebsd" => %{
        checksum: "b1b86d145b07b030788e1e5f21089efbda103f11ec3c11ff77c388aaa1856d4d",
        filename: "appsignal-x86_64-freebsd-all-static.tar.gz"
      },
    }
  end
end
