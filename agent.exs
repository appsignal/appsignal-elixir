# DO NOT EDIT
# This is a generated file by the `rake ship` family of tasks in the
# appsignal-agent repository.
# Modifications to this file will be overwritten with the next agent release.

defmodule Appsignal.Agent do
  def version, do: "de9fb3f"

  def mirrors do
    [
      "https://appsignal-agent-releases.global.ssl.fastly.net",
      "https://d135dj0rjqvssy.cloudfront.net",
    ]
  end

  def triples do
    %{
      "x86_64-darwin" => %{
        checksum: "cda17e591639baf054df1da669419f465c9f4f1d40cf0ff346698381e961a73c",
        filename: "appsignal-x86_64-darwin-all-static.tar.gz"
      },
      "universal-darwin" => %{
        checksum: "cda17e591639baf054df1da669419f465c9f4f1d40cf0ff346698381e961a73c",
        filename: "appsignal-x86_64-darwin-all-static.tar.gz"
      },
      "aarch64-darwin" => %{
        checksum: "d761045f4b5227c425a1d904df098187d8ce99e14c206b5c0b1c9d4562542661",
        filename: "appsignal-aarch64-darwin-all-static.tar.gz"
      },
      "arm64-darwin" => %{
        checksum: "d761045f4b5227c425a1d904df098187d8ce99e14c206b5c0b1c9d4562542661",
        filename: "appsignal-aarch64-darwin-all-static.tar.gz"
      },
      "arm-darwin" => %{
        checksum: "d761045f4b5227c425a1d904df098187d8ce99e14c206b5c0b1c9d4562542661",
        filename: "appsignal-aarch64-darwin-all-static.tar.gz"
      },
      "aarch64-linux" => %{
        checksum: "ae08f23ef166831a5736a9dacc7437fec0b621bf9d51e424800aa3ca6f129e17",
        filename: "appsignal-aarch64-linux-all-static.tar.gz"
      },
      "i686-linux" => %{
        checksum: "dfa84b48fe3f545ead792b86d3f1c4f17a6d8c32c538481a70ae5ff8c22a0965",
        filename: "appsignal-i686-linux-all-static.tar.gz"
      },
      "x86-linux" => %{
        checksum: "dfa84b48fe3f545ead792b86d3f1c4f17a6d8c32c538481a70ae5ff8c22a0965",
        filename: "appsignal-i686-linux-all-static.tar.gz"
      },
      "x86_64-linux" => %{
        checksum: "ec6e6b02eb676663369d3dac80d7bde9bf81bd9e7b34cdc00621b3e6fc57f956",
        filename: "appsignal-x86_64-linux-all-static.tar.gz"
      },
      "x86_64-linux-musl" => %{
        checksum: "5c479566abf498b9349d830f65267f4d6b7fe3f8e90e8c5d29e0fd7a3d6404f5",
        filename: "appsignal-x86_64-linux-musl-all-static.tar.gz"
      },
      "x86_64-freebsd" => %{
        checksum: "afc63b2553d9d357758b3104ca140d9c78e72f53c36d1b8acc0871fa937c32c2",
        filename: "appsignal-x86_64-freebsd-all-static.tar.gz"
      },
      "amd64-freebsd" => %{
        checksum: "afc63b2553d9d357758b3104ca140d9c78e72f53c36d1b8acc0871fa937c32c2",
        filename: "appsignal-x86_64-freebsd-all-static.tar.gz"
      },
    }
  end
end
