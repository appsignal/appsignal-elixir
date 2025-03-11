# DO NOT EDIT
# This is a generated file by the `rake publish` family of tasks in the
# appsignal-agent repository.
# Modifications to this file will be overwritten with the next agent release.

defmodule Appsignal.Agent do
  def version, do: "0.36.1"

  def mirrors do
    [
      "https://d135dj0rjqvssy.cloudfront.net",
      "https://appsignal-agent-releases.global.ssl.fastly.net",
    ]
  end

  def triples do
    %{
      "x86_64-darwin" => %{
        checksum: "b04866a9f8d5002d37e4142c0d95281a18b14afdb7f43d9cd27ed457c18ba605",
        filename: "appsignal-x86_64-darwin-all-static.tar.gz"
      },
      "universal-darwin" => %{
        checksum: "b04866a9f8d5002d37e4142c0d95281a18b14afdb7f43d9cd27ed457c18ba605",
        filename: "appsignal-x86_64-darwin-all-static.tar.gz"
      },
      "aarch64-darwin" => %{
        checksum: "2449f66f00a2c4999f7e46527377127df70b8d1dbc15460987d3cc7878189e02",
        filename: "appsignal-aarch64-darwin-all-static.tar.gz"
      },
      "arm64-darwin" => %{
        checksum: "2449f66f00a2c4999f7e46527377127df70b8d1dbc15460987d3cc7878189e02",
        filename: "appsignal-aarch64-darwin-all-static.tar.gz"
      },
      "arm-darwin" => %{
        checksum: "2449f66f00a2c4999f7e46527377127df70b8d1dbc15460987d3cc7878189e02",
        filename: "appsignal-aarch64-darwin-all-static.tar.gz"
      },
      "aarch64-linux" => %{
        checksum: "8177ee4235fe031371e9bd7f8b0cb782c4825ed5fafbee7f7984564d813ce712",
        filename: "appsignal-aarch64-linux-all-static.tar.gz"
      },
      "i686-linux" => %{
        checksum: "ef073d456d4f676836a238e83f177851b2568993adb9c2a952e9bf2b700069a9",
        filename: "appsignal-i686-linux-all-static.tar.gz"
      },
      "x86-linux" => %{
        checksum: "ef073d456d4f676836a238e83f177851b2568993adb9c2a952e9bf2b700069a9",
        filename: "appsignal-i686-linux-all-static.tar.gz"
      },
      "x86_64-linux" => %{
        checksum: "9701b9cb4b904dc51c08a7cd044f03194ca1f2029ee6bf7fa74514e62bf5b6bd",
        filename: "appsignal-x86_64-linux-all-static.tar.gz"
      },
      "x86_64-linux-musl" => %{
        checksum: "fde82104787e0531ea816019b0c7a9e16afb29fb015c1776faaa7ccd5cb4f60c",
        filename: "appsignal-x86_64-linux-musl-all-static.tar.gz"
      },
      "aarch64-linux-musl" => %{
        checksum: "95876c74ea67fa9b5e14d4a84df2d91c78b23f471339addc6b7b624e3ea3fbe7",
        filename: "appsignal-aarch64-linux-musl-all-static.tar.gz"
      },
      "x86_64-freebsd" => %{
        checksum: "478de9db74f9fc9c32fd34c7c7ace70c86006f42b31396707bbe8b2d9e3481b0",
        filename: "appsignal-x86_64-freebsd-all-static.tar.gz"
      },
      "amd64-freebsd" => %{
        checksum: "478de9db74f9fc9c32fd34c7c7ace70c86006f42b31396707bbe8b2d9e3481b0",
        filename: "appsignal-x86_64-freebsd-all-static.tar.gz"
      },
    }
  end
end
