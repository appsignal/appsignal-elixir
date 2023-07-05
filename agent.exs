# DO NOT EDIT
# This is a generated file by the `rake ship` family of tasks in the
# appsignal-agent repository.
# Modifications to this file will be overwritten with the next agent release.

defmodule Appsignal.Agent do
  def version, do: "9e1ad6b"

  def mirrors do
    [
      "https://appsignal-agent-releases.global.ssl.fastly.net",
      "https://d135dj0rjqvssy.cloudfront.net",
    ]
  end

  def triples do
    %{
      "x86_64-darwin" => %{
        checksum: "dcbe4b05f84f56e376d99ce7febfa777a2d016670139af5dd7d62b2d8544fb53",
        filename: "appsignal-x86_64-darwin-all-static.tar.gz"
      },
      "universal-darwin" => %{
        checksum: "dcbe4b05f84f56e376d99ce7febfa777a2d016670139af5dd7d62b2d8544fb53",
        filename: "appsignal-x86_64-darwin-all-static.tar.gz"
      },
      "aarch64-darwin" => %{
        checksum: "a015987b5b7df028ce38d9a00a637f13afd30ffd639f6487447f2319359a61aa",
        filename: "appsignal-aarch64-darwin-all-static.tar.gz"
      },
      "arm64-darwin" => %{
        checksum: "a015987b5b7df028ce38d9a00a637f13afd30ffd639f6487447f2319359a61aa",
        filename: "appsignal-aarch64-darwin-all-static.tar.gz"
      },
      "arm-darwin" => %{
        checksum: "a015987b5b7df028ce38d9a00a637f13afd30ffd639f6487447f2319359a61aa",
        filename: "appsignal-aarch64-darwin-all-static.tar.gz"
      },
      "aarch64-linux" => %{
        checksum: "aa27f9402c80bd5e241dce61f093eef291cde7c9866f724ac513f00c79ac00de",
        filename: "appsignal-aarch64-linux-all-static.tar.gz"
      },
      "i686-linux" => %{
        checksum: "5de40c1cf697abcbbb875cdd02d28eef51453f8537d3cbb7abf17bc1dcc74403",
        filename: "appsignal-i686-linux-all-static.tar.gz"
      },
      "x86-linux" => %{
        checksum: "5de40c1cf697abcbbb875cdd02d28eef51453f8537d3cbb7abf17bc1dcc74403",
        filename: "appsignal-i686-linux-all-static.tar.gz"
      },
      "x86_64-linux" => %{
        checksum: "754fa65f8539e77e2c548dff689a1d04c13306799eb79353a7821ef3d3cf1fb4",
        filename: "appsignal-x86_64-linux-all-static.tar.gz"
      },
      "x86_64-linux-musl" => %{
        checksum: "159fc5e3a9fdd01addabfc16f5c6b3e0e5c0ce2bf030b443fa739df9e987b656",
        filename: "appsignal-x86_64-linux-musl-all-static.tar.gz"
      },
      "aarch64-linux-musl" => %{
        checksum: "75469fd7d2b5da23be2b7763c171f76cef8f7aaafd9b2980a578348775949b52",
        filename: "appsignal-aarch64-linux-musl-all-static.tar.gz"
      },
      "x86_64-freebsd" => %{
        checksum: "5fe5c746800db955096713dbab5120d3e07d3c54a8801a9c55796ea4825f15ee",
        filename: "appsignal-x86_64-freebsd-all-static.tar.gz"
      },
      "amd64-freebsd" => %{
        checksum: "5fe5c746800db955096713dbab5120d3e07d3c54a8801a9c55796ea4825f15ee",
        filename: "appsignal-x86_64-freebsd-all-static.tar.gz"
      },
    }
  end
end
