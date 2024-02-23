# DO NOT EDIT
# This is a generated file by the `rake ship` family of tasks in the
# appsignal-agent repository.
# Modifications to this file will be overwritten with the next agent release.

defmodule Appsignal.Agent do
  def version, do: "0.33.2"

  def mirrors do
    [
      "https://appsignal-agent-releases.global.ssl.fastly.net",
      "https://d135dj0rjqvssy.cloudfront.net",
    ]
  end

  def triples do
    %{
      "x86_64-darwin" => %{
        checksum: "0864691f001133fa479b34b00a682e76f374c40c161e7715756a3c036e3c8798",
        filename: "appsignal-x86_64-darwin-all-static.tar.gz"
      },
      "universal-darwin" => %{
        checksum: "0864691f001133fa479b34b00a682e76f374c40c161e7715756a3c036e3c8798",
        filename: "appsignal-x86_64-darwin-all-static.tar.gz"
      },
      "aarch64-darwin" => %{
        checksum: "13506e5911523e7107a8cb714e18b3bcb690f3eeef88bf9aff54777ba540fdc4",
        filename: "appsignal-aarch64-darwin-all-static.tar.gz"
      },
      "arm64-darwin" => %{
        checksum: "13506e5911523e7107a8cb714e18b3bcb690f3eeef88bf9aff54777ba540fdc4",
        filename: "appsignal-aarch64-darwin-all-static.tar.gz"
      },
      "arm-darwin" => %{
        checksum: "13506e5911523e7107a8cb714e18b3bcb690f3eeef88bf9aff54777ba540fdc4",
        filename: "appsignal-aarch64-darwin-all-static.tar.gz"
      },
      "aarch64-linux" => %{
        checksum: "76702b5755d5bb45cc05df17dd38389b7e20e105a52324120a45ae1b481c7881",
        filename: "appsignal-aarch64-linux-all-static.tar.gz"
      },
      "i686-linux" => %{
        checksum: "22cbda11a8d801d75e9394033f5cf28f0ddcff66a2138720f827441bdcf919c2",
        filename: "appsignal-i686-linux-all-static.tar.gz"
      },
      "x86-linux" => %{
        checksum: "22cbda11a8d801d75e9394033f5cf28f0ddcff66a2138720f827441bdcf919c2",
        filename: "appsignal-i686-linux-all-static.tar.gz"
      },
      "x86_64-linux" => %{
        checksum: "8ff0b1d7bf0cfc1c66e918545a9ab5c29be35c371cde48f64a01c725290599ed",
        filename: "appsignal-x86_64-linux-all-static.tar.gz"
      },
      "x86_64-linux-musl" => %{
        checksum: "a5e0af3e5e1ad908792e79c7c46b59119272e9836e5ea96791c78e3cb12ed132",
        filename: "appsignal-x86_64-linux-musl-all-static.tar.gz"
      },
      "aarch64-linux-musl" => %{
        checksum: "92460560115d540a8140cbc360bd98beba8477e8a73eafd20ee611543b4528df",
        filename: "appsignal-aarch64-linux-musl-all-static.tar.gz"
      },
      "x86_64-freebsd" => %{
        checksum: "8d8733c2adc0f750553be11b5e54fd614b13207be67863d95c57e4739021a92f",
        filename: "appsignal-x86_64-freebsd-all-static.tar.gz"
      },
      "amd64-freebsd" => %{
        checksum: "8d8733c2adc0f750553be11b5e54fd614b13207be67863d95c57e4739021a92f",
        filename: "appsignal-x86_64-freebsd-all-static.tar.gz"
      },
    }
  end
end
