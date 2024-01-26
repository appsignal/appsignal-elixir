# DO NOT EDIT
# This is a generated file by the `rake ship` family of tasks in the
# appsignal-agent repository.
# Modifications to this file will be overwritten with the next agent release.

defmodule Appsignal.Agent do
  def version, do: "0.31.2"

  def mirrors do
    [
      "https://appsignal-agent-releases.global.ssl.fastly.net",
      "https://d135dj0rjqvssy.cloudfront.net",
    ]
  end

  def triples do
    %{
      "x86_64-darwin" => %{
        checksum: "42cdf814a89e5d6bd6e5cd9ba84103df82b43418012bb4f9251e98d0c3627759",
        filename: "appsignal-x86_64-darwin-all-static.tar.gz"
      },
      "universal-darwin" => %{
        checksum: "42cdf814a89e5d6bd6e5cd9ba84103df82b43418012bb4f9251e98d0c3627759",
        filename: "appsignal-x86_64-darwin-all-static.tar.gz"
      },
      "aarch64-darwin" => %{
        checksum: "8db9e31e090e767b1157d969521967f322be9dd73eb1b677b6192eb4c987af72",
        filename: "appsignal-aarch64-darwin-all-static.tar.gz"
      },
      "arm64-darwin" => %{
        checksum: "8db9e31e090e767b1157d969521967f322be9dd73eb1b677b6192eb4c987af72",
        filename: "appsignal-aarch64-darwin-all-static.tar.gz"
      },
      "arm-darwin" => %{
        checksum: "8db9e31e090e767b1157d969521967f322be9dd73eb1b677b6192eb4c987af72",
        filename: "appsignal-aarch64-darwin-all-static.tar.gz"
      },
      "aarch64-linux" => %{
        checksum: "72873d1c7ad2d4d744fe3dd4370fb07b4c9d8a4f4d87febb8dbe08c532eebff8",
        filename: "appsignal-aarch64-linux-all-static.tar.gz"
      },
      "i686-linux" => %{
        checksum: "8779fdd2f02b034463900456b5b65a92d3a9165b87ba896b01baded96729685a",
        filename: "appsignal-i686-linux-all-static.tar.gz"
      },
      "x86-linux" => %{
        checksum: "8779fdd2f02b034463900456b5b65a92d3a9165b87ba896b01baded96729685a",
        filename: "appsignal-i686-linux-all-static.tar.gz"
      },
      "x86_64-linux" => %{
        checksum: "36fc29655d13e4dfe7bcbe2c798bfc16d68194610ff354d43e977f3768f31458",
        filename: "appsignal-x86_64-linux-all-static.tar.gz"
      },
      "x86_64-linux-musl" => %{
        checksum: "59b6cef9797746da9d6717effc0892a2f2219767734a0e76f8b3d1578dc0d9e0",
        filename: "appsignal-x86_64-linux-musl-all-static.tar.gz"
      },
      "aarch64-linux-musl" => %{
        checksum: "ec3ab8fcc20d1f31df6003e2ca3dcf257abfeddd1b7912fa6189f1f6905a89ab",
        filename: "appsignal-aarch64-linux-musl-all-static.tar.gz"
      },
      "x86_64-freebsd" => %{
        checksum: "bd654d5c555f6006e4145d76e27f02c5d22b285f411675a520455d6db6c8e165",
        filename: "appsignal-x86_64-freebsd-all-static.tar.gz"
      },
      "amd64-freebsd" => %{
        checksum: "bd654d5c555f6006e4145d76e27f02c5d22b285f411675a520455d6db6c8e165",
        filename: "appsignal-x86_64-freebsd-all-static.tar.gz"
      },
    }
  end
end
