# DO NOT EDIT
# This is a generated file by the `rake publish` family of tasks in the
# appsignal-agent repository.
# Modifications to this file will be overwritten with the next agent release.

defmodule Appsignal.Agent do
  def version, do: "0.35.29"

  def mirrors do
    [
      "https://d135dj0rjqvssy.cloudfront.net",
      "https://appsignal-agent-releases.global.ssl.fastly.net",
    ]
  end

  def triples do
    %{
      "x86_64-darwin" => %{
        checksum: "880b317fc23d3cfa11ba88c80d11129bd02742b8b9c100bb038b66e73f85b723",
        filename: "appsignal-x86_64-darwin-all-static.tar.gz"
      },
      "universal-darwin" => %{
        checksum: "880b317fc23d3cfa11ba88c80d11129bd02742b8b9c100bb038b66e73f85b723",
        filename: "appsignal-x86_64-darwin-all-static.tar.gz"
      },
      "aarch64-darwin" => %{
        checksum: "64b0107722401f5ee39eebec03b9c5a68a14967e8aa8806848df930f85a8afaf",
        filename: "appsignal-aarch64-darwin-all-static.tar.gz"
      },
      "arm64-darwin" => %{
        checksum: "64b0107722401f5ee39eebec03b9c5a68a14967e8aa8806848df930f85a8afaf",
        filename: "appsignal-aarch64-darwin-all-static.tar.gz"
      },
      "arm-darwin" => %{
        checksum: "64b0107722401f5ee39eebec03b9c5a68a14967e8aa8806848df930f85a8afaf",
        filename: "appsignal-aarch64-darwin-all-static.tar.gz"
      },
      "aarch64-linux" => %{
        checksum: "02dd40769daa5cde64dfee9e0931d0432c4ccffeb6c08197cccc454234fdae2c",
        filename: "appsignal-aarch64-linux-all-static.tar.gz"
      },
      "i686-linux" => %{
        checksum: "4e19e1db93add17a71aaf2fd14ddf4cbd6913338f8ebeb0569baa59e154e8999",
        filename: "appsignal-i686-linux-all-static.tar.gz"
      },
      "x86-linux" => %{
        checksum: "4e19e1db93add17a71aaf2fd14ddf4cbd6913338f8ebeb0569baa59e154e8999",
        filename: "appsignal-i686-linux-all-static.tar.gz"
      },
      "x86_64-linux" => %{
        checksum: "1150865e4a9b6d773a10702414b9b0b7cc69a72c0cbb17f5a01cebf40cabbcc4",
        filename: "appsignal-x86_64-linux-all-static.tar.gz"
      },
      "x86_64-linux-musl" => %{
        checksum: "86fe06ca6dcc93e68a9c603c9087f15b0cef213f4df0eab6c0b495034045cde0",
        filename: "appsignal-x86_64-linux-musl-all-static.tar.gz"
      },
      "aarch64-linux-musl" => %{
        checksum: "a3b2e4eb3a32408cbbc5b0a12b1d61322378ce0dc30edfb1c541a43d0c5306ff",
        filename: "appsignal-aarch64-linux-musl-all-static.tar.gz"
      },
      "x86_64-freebsd" => %{
        checksum: "a4982fab5a7b4a4292bd0002e3bc571cbeced167c6a3e36f6c26e7898b3d38a7",
        filename: "appsignal-x86_64-freebsd-all-static.tar.gz"
      },
      "amd64-freebsd" => %{
        checksum: "a4982fab5a7b4a4292bd0002e3bc571cbeced167c6a3e36f6c26e7898b3d38a7",
        filename: "appsignal-x86_64-freebsd-all-static.tar.gz"
      },
    }
  end
end
