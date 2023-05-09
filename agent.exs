# DO NOT EDIT
# This is a generated file by the `rake ship` family of tasks in the
# appsignal-agent repository.
# Modifications to this file will be overwritten with the next agent release.

defmodule Appsignal.Agent do
  def version, do: "4a0a036"

  def mirrors do
    [
      "https://appsignal-agent-releases.global.ssl.fastly.net",
      "https://d135dj0rjqvssy.cloudfront.net",
    ]
  end

  def triples do
    %{
      "x86_64-darwin" => %{
        checksum: "b5bd080e409cc2fb9031281363c8a85272af65277ac8c7aeb49c14c2272eedde",
        filename: "appsignal-x86_64-darwin-all-static.tar.gz"
      },
      "universal-darwin" => %{
        checksum: "b5bd080e409cc2fb9031281363c8a85272af65277ac8c7aeb49c14c2272eedde",
        filename: "appsignal-x86_64-darwin-all-static.tar.gz"
      },
      "aarch64-darwin" => %{
        checksum: "b39d9192cf4f20b97ba0ffc794045433f02c2814a69c5a5b72e2fb414ce30085",
        filename: "appsignal-aarch64-darwin-all-static.tar.gz"
      },
      "arm64-darwin" => %{
        checksum: "b39d9192cf4f20b97ba0ffc794045433f02c2814a69c5a5b72e2fb414ce30085",
        filename: "appsignal-aarch64-darwin-all-static.tar.gz"
      },
      "arm-darwin" => %{
        checksum: "b39d9192cf4f20b97ba0ffc794045433f02c2814a69c5a5b72e2fb414ce30085",
        filename: "appsignal-aarch64-darwin-all-static.tar.gz"
      },
      "aarch64-linux" => %{
        checksum: "b6c9317fa17063f25c73a6464ae84d4da1677cfa711538c8fd58b9198f04ac31",
        filename: "appsignal-aarch64-linux-all-static.tar.gz"
      },
      "i686-linux" => %{
        checksum: "b3b5d9217df1f40eb1187ea6188f5aaf55a17f91ece4a749bd9bf316b63ff09c",
        filename: "appsignal-i686-linux-all-static.tar.gz"
      },
      "x86-linux" => %{
        checksum: "b3b5d9217df1f40eb1187ea6188f5aaf55a17f91ece4a749bd9bf316b63ff09c",
        filename: "appsignal-i686-linux-all-static.tar.gz"
      },
      "x86_64-linux" => %{
        checksum: "bbc9bb6fe66a562b0ad36dc8d0a79ea0e6bd8bf9e7df5d5d4ba0a3b22de84460",
        filename: "appsignal-x86_64-linux-all-static.tar.gz"
      },
      "x86_64-linux-musl" => %{
        checksum: "34ee2de65a2509847d72a9a5a649b0714dbba6431e4bfa0c81c7d6280320bfd4",
        filename: "appsignal-x86_64-linux-musl-all-static.tar.gz"
      },
      "aarch64-linux-musl" => %{
        checksum: "495367c3190b0f03d0aaa3c9bdfd51edb1da2ac08312e1b246cbd9ff1ff462f5",
        filename: "appsignal-aarch64-linux-musl-all-static.tar.gz"
      },
      "x86_64-freebsd" => %{
        checksum: "fac3a7cb98fba93a63d47b49345c71c88806ed914417bb18ba12b5c9a02975d9",
        filename: "appsignal-x86_64-freebsd-all-static.tar.gz"
      },
      "amd64-freebsd" => %{
        checksum: "fac3a7cb98fba93a63d47b49345c71c88806ed914417bb18ba12b5c9a02975d9",
        filename: "appsignal-x86_64-freebsd-all-static.tar.gz"
      },
    }
  end
end
