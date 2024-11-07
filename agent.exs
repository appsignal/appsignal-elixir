# DO NOT EDIT
# This is a generated file by the `rake publish` family of tasks in the
# appsignal-agent repository.
# Modifications to this file will be overwritten with the next agent release.

defmodule Appsignal.Agent do
  def version, do: "0.35.28"

  def mirrors do
    [
      "https://d135dj0rjqvssy.cloudfront.net",
      "https://appsignal-agent-releases.global.ssl.fastly.net",
    ]
  end

  def triples do
    %{
      "x86_64-darwin" => %{
        checksum: "8759daae4f842a7dcf370e521de8de9390b3883e09abe8b4f868b6827c855bb3",
        filename: "appsignal-x86_64-darwin-all-static.tar.gz"
      },
      "universal-darwin" => %{
        checksum: "8759daae4f842a7dcf370e521de8de9390b3883e09abe8b4f868b6827c855bb3",
        filename: "appsignal-x86_64-darwin-all-static.tar.gz"
      },
      "aarch64-darwin" => %{
        checksum: "247551894b2195bb7e9cc6b52e8a42e10af0723b67f757d3eb84fe34791d0509",
        filename: "appsignal-aarch64-darwin-all-static.tar.gz"
      },
      "arm64-darwin" => %{
        checksum: "247551894b2195bb7e9cc6b52e8a42e10af0723b67f757d3eb84fe34791d0509",
        filename: "appsignal-aarch64-darwin-all-static.tar.gz"
      },
      "arm-darwin" => %{
        checksum: "247551894b2195bb7e9cc6b52e8a42e10af0723b67f757d3eb84fe34791d0509",
        filename: "appsignal-aarch64-darwin-all-static.tar.gz"
      },
      "aarch64-linux" => %{
        checksum: "02d62cfab5ab81faec40db6d80d47e53b2fca640026715697ab43f19539ace34",
        filename: "appsignal-aarch64-linux-all-static.tar.gz"
      },
      "i686-linux" => %{
        checksum: "d5771f360fbb24eb6d39459a910fcbb097904f8459a1735747dde3589c7d710d",
        filename: "appsignal-i686-linux-all-static.tar.gz"
      },
      "x86-linux" => %{
        checksum: "d5771f360fbb24eb6d39459a910fcbb097904f8459a1735747dde3589c7d710d",
        filename: "appsignal-i686-linux-all-static.tar.gz"
      },
      "x86_64-linux" => %{
        checksum: "f3efd7973a0a4b5a0dca7ef23a896a866f011e70d90e2d22cd77c343ffbdf0c1",
        filename: "appsignal-x86_64-linux-all-static.tar.gz"
      },
      "x86_64-linux-musl" => %{
        checksum: "9e0cc593389e08527d2e62cc4389711a137511021fd59abd311da8ef5343aee6",
        filename: "appsignal-x86_64-linux-musl-all-static.tar.gz"
      },
      "aarch64-linux-musl" => %{
        checksum: "5112c3d0b22f27e6ed108d671ec2903f4cbe084c8d104a05bc946d88ccfed633",
        filename: "appsignal-aarch64-linux-musl-all-static.tar.gz"
      },
      "x86_64-freebsd" => %{
        checksum: "5d87cf82173f95440277b4565a58742c2843f0ddb17bf8f285023c294d1d30ad",
        filename: "appsignal-x86_64-freebsd-all-static.tar.gz"
      },
      "amd64-freebsd" => %{
        checksum: "5d87cf82173f95440277b4565a58742c2843f0ddb17bf8f285023c294d1d30ad",
        filename: "appsignal-x86_64-freebsd-all-static.tar.gz"
      },
    }
  end
end
