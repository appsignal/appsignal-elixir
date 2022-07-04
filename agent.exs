# DO NOT EDIT
# This is a generated file by the `rake ship` family of tasks in the
# appsignal-agent repository.
# Modifications to this file will be overwritten with the next agent release.

defmodule Appsignal.Agent do
  def version, do: "a2b8d17"

  def mirrors do
    [
      "https://appsignal-agent-releases.global.ssl.fastly.net",
      "https://d135dj0rjqvssy.cloudfront.net",
    ]
  end

  def triples do
    %{
      "x86_64-darwin" => %{
        checksum: "763898817ab080c3a855fd882e3c4b8bce3cfe11dd309202fadb7ef3e800ed4d",
        filename: "appsignal-x86_64-darwin-all-static.tar.gz"
      },
      "universal-darwin" => %{
        checksum: "763898817ab080c3a855fd882e3c4b8bce3cfe11dd309202fadb7ef3e800ed4d",
        filename: "appsignal-x86_64-darwin-all-static.tar.gz"
      },
      "aarch64-darwin" => %{
        checksum: "00e396fcbf394d0ee435aed310945936515179d7b68306d773742308a023b16b",
        filename: "appsignal-aarch64-darwin-all-static.tar.gz"
      },
      "arm64-darwin" => %{
        checksum: "00e396fcbf394d0ee435aed310945936515179d7b68306d773742308a023b16b",
        filename: "appsignal-aarch64-darwin-all-static.tar.gz"
      },
      "arm-darwin" => %{
        checksum: "00e396fcbf394d0ee435aed310945936515179d7b68306d773742308a023b16b",
        filename: "appsignal-aarch64-darwin-all-static.tar.gz"
      },
      "aarch64-linux" => %{
        checksum: "17e852a5c26a90eadcdf5bdbc90243d944110c68b92c56a9fd374b2430953aab",
        filename: "appsignal-aarch64-linux-all-static.tar.gz"
      },
      "i686-linux" => %{
        checksum: "465784756432abe94c4df195ce055f59a0a3df705bbf49db301962736acb13fc",
        filename: "appsignal-i686-linux-all-static.tar.gz"
      },
      "x86-linux" => %{
        checksum: "465784756432abe94c4df195ce055f59a0a3df705bbf49db301962736acb13fc",
        filename: "appsignal-i686-linux-all-static.tar.gz"
      },
      "x86_64-linux" => %{
        checksum: "da7a3702e0bf8d95ef6c57b0c2afca638b86c35f82fd76d68f9960285ba6ece7",
        filename: "appsignal-x86_64-linux-all-static.tar.gz"
      },
      "x86_64-linux-musl" => %{
        checksum: "f158c781d1fdee000f0b6fde884133cba40d08ad278d71427759ad6d37e5e7a1",
        filename: "appsignal-x86_64-linux-musl-all-static.tar.gz"
      },
      "x86_64-freebsd" => %{
        checksum: "375b3a3d9ae4be47c9278714cf3214dee04236b4e01fa7b629d4358548e51cc5",
        filename: "appsignal-x86_64-freebsd-all-static.tar.gz"
      },
      "amd64-freebsd" => %{
        checksum: "375b3a3d9ae4be47c9278714cf3214dee04236b4e01fa7b629d4358548e51cc5",
        filename: "appsignal-x86_64-freebsd-all-static.tar.gz"
      },
    }
  end
end
