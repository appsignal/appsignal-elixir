# DO NOT EDIT
# This is a generated file by the `rake publish` family of tasks in the
# appsignal-agent repository.
# Modifications to this file will be overwritten with the next agent release.

defmodule Appsignal.Agent do
  def version, do: "0.35.27"

  def mirrors do
    [
      "https://d135dj0rjqvssy.cloudfront.net",
      "https://appsignal-agent-releases.global.ssl.fastly.net",
    ]
  end

  def triples do
    %{
      "x86_64-darwin" => %{
        checksum: "466a8ded961424cef363e15db1ae281a5c8868de1e866054943b63800c52ee11",
        filename: "appsignal-x86_64-darwin-all-static.tar.gz"
      },
      "universal-darwin" => %{
        checksum: "466a8ded961424cef363e15db1ae281a5c8868de1e866054943b63800c52ee11",
        filename: "appsignal-x86_64-darwin-all-static.tar.gz"
      },
      "aarch64-darwin" => %{
        checksum: "a775401a75dac8e643508cee6a5489945fc568085bd89d613dab579b08db6703",
        filename: "appsignal-aarch64-darwin-all-static.tar.gz"
      },
      "arm64-darwin" => %{
        checksum: "a775401a75dac8e643508cee6a5489945fc568085bd89d613dab579b08db6703",
        filename: "appsignal-aarch64-darwin-all-static.tar.gz"
      },
      "arm-darwin" => %{
        checksum: "a775401a75dac8e643508cee6a5489945fc568085bd89d613dab579b08db6703",
        filename: "appsignal-aarch64-darwin-all-static.tar.gz"
      },
      "aarch64-linux" => %{
        checksum: "d4d33982382b04f89ca7b1cdbe2ec364d7e505a53fe2b87ad4c33583f583d430",
        filename: "appsignal-aarch64-linux-all-static.tar.gz"
      },
      "i686-linux" => %{
        checksum: "0ef6bf102929a6efbf3587310628d1321ea83987cb18f64ef7654162945c6216",
        filename: "appsignal-i686-linux-all-static.tar.gz"
      },
      "x86-linux" => %{
        checksum: "0ef6bf102929a6efbf3587310628d1321ea83987cb18f64ef7654162945c6216",
        filename: "appsignal-i686-linux-all-static.tar.gz"
      },
      "x86_64-linux" => %{
        checksum: "4405619e2a536c153d99d80c20d137810e3cf410a8f6013ba88a49f0ff51f9ff",
        filename: "appsignal-x86_64-linux-all-static.tar.gz"
      },
      "x86_64-linux-musl" => %{
        checksum: "191aaa688289167912ac2269e6f0f16e893c9938b34153375658a2caae67a25b",
        filename: "appsignal-x86_64-linux-musl-all-static.tar.gz"
      },
      "aarch64-linux-musl" => %{
        checksum: "f068b5d9aeca142766efe424d6e1c38cd79323bb22ff707efe75e13d56863b13",
        filename: "appsignal-aarch64-linux-musl-all-static.tar.gz"
      },
      "x86_64-freebsd" => %{
        checksum: "93b26e0b1e9bb6bcf6ce862c8c7e95eb6b6f0a8be519012f84d47e48c24acead",
        filename: "appsignal-x86_64-freebsd-all-static.tar.gz"
      },
      "amd64-freebsd" => %{
        checksum: "93b26e0b1e9bb6bcf6ce862c8c7e95eb6b6f0a8be519012f84d47e48c24acead",
        filename: "appsignal-x86_64-freebsd-all-static.tar.gz"
      },
    }
  end
end
