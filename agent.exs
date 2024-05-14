# DO NOT EDIT
# This is a generated file by the `rake ship` family of tasks in the
# appsignal-agent repository.
# Modifications to this file will be overwritten with the next agent release.

defmodule Appsignal.Agent do
  def version, do: "0.35.10"

  def mirrors do
    [
      "https://appsignal-agent-releases.global.ssl.fastly.net",
      "https://d135dj0rjqvssy.cloudfront.net",
    ]
  end

  def triples do
    %{
      "x86_64-darwin" => %{
        checksum: "8bdf6b162e03c5f63bc06f2d49ae789bb14e111636524ed78262bd543587a971",
        filename: "appsignal-x86_64-darwin-all-static.tar.gz"
      },
      "universal-darwin" => %{
        checksum: "8bdf6b162e03c5f63bc06f2d49ae789bb14e111636524ed78262bd543587a971",
        filename: "appsignal-x86_64-darwin-all-static.tar.gz"
      },
      "aarch64-darwin" => %{
        checksum: "c6453bb54a68cdb0b42864747b328e60a14b5b99921f11757de03db42041bed2",
        filename: "appsignal-aarch64-darwin-all-static.tar.gz"
      },
      "arm64-darwin" => %{
        checksum: "c6453bb54a68cdb0b42864747b328e60a14b5b99921f11757de03db42041bed2",
        filename: "appsignal-aarch64-darwin-all-static.tar.gz"
      },
      "arm-darwin" => %{
        checksum: "c6453bb54a68cdb0b42864747b328e60a14b5b99921f11757de03db42041bed2",
        filename: "appsignal-aarch64-darwin-all-static.tar.gz"
      },
      "aarch64-linux" => %{
        checksum: "4e90ec4bce1e632316a26fdaf03ccd8773bf7a9615eb7a1739c8c53f3fa5221a",
        filename: "appsignal-aarch64-linux-all-static.tar.gz"
      },
      "i686-linux" => %{
        checksum: "f5bcb9f732cb5af53a5de2f2c916156bdd6677c0e563ddafd23f09576440dfdc",
        filename: "appsignal-i686-linux-all-static.tar.gz"
      },
      "x86-linux" => %{
        checksum: "f5bcb9f732cb5af53a5de2f2c916156bdd6677c0e563ddafd23f09576440dfdc",
        filename: "appsignal-i686-linux-all-static.tar.gz"
      },
      "x86_64-linux" => %{
        checksum: "6faa14f508f7c27b65d912eedb31f7808e1e2fb1dcaa077db2426c321e1f5c65",
        filename: "appsignal-x86_64-linux-all-static.tar.gz"
      },
      "x86_64-linux-musl" => %{
        checksum: "8f54b734e56eae7867b5474c7ad4d79e049fd4063202e1b80989795708354e49",
        filename: "appsignal-x86_64-linux-musl-all-static.tar.gz"
      },
      "aarch64-linux-musl" => %{
        checksum: "b3d247d632e3465b2233dd8bb2e977f248f14286ca870e9bd7b855b550ba1c00",
        filename: "appsignal-aarch64-linux-musl-all-static.tar.gz"
      },
      "x86_64-freebsd" => %{
        checksum: "1cce550eac963e2edf405e551a613ffd15ae69e4b817b6155b8a5783a9fa9b7f",
        filename: "appsignal-x86_64-freebsd-all-static.tar.gz"
      },
      "amd64-freebsd" => %{
        checksum: "1cce550eac963e2edf405e551a613ffd15ae69e4b817b6155b8a5783a9fa9b7f",
        filename: "appsignal-x86_64-freebsd-all-static.tar.gz"
      },
    }
  end
end
