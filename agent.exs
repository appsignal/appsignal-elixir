# DO NOT EDIT
# This is a generated file by the `rake ship` family of tasks in the
# appsignal-agent repository.
# Modifications to this file will be overwritten with the next agent release.

defmodule Appsignal.Agent do
  def version, do: "d4b6997"

  def mirrors do
    [
      "https://appsignal-agent-releases.global.ssl.fastly.net",
      "https://d135dj0rjqvssy.cloudfront.net",
    ]
  end

  def triples do
    %{
      "x86_64-darwin" => %{
        checksum: "e1fb1b5bd3da20e6b11952d03ee7c65879d659cb74db98496cac2c2e6fd4fa74",
        filename: "appsignal-x86_64-darwin-all-static.tar.gz"
      },
      "universal-darwin" => %{
        checksum: "e1fb1b5bd3da20e6b11952d03ee7c65879d659cb74db98496cac2c2e6fd4fa74",
        filename: "appsignal-x86_64-darwin-all-static.tar.gz"
      },
      "aarch64-darwin" => %{
        checksum: "24c438670080fff110d21a6f08484c3cad1af51b9c408ca6fc57c1f2b324306a",
        filename: "appsignal-aarch64-darwin-all-static.tar.gz"
      },
      "arm64-darwin" => %{
        checksum: "24c438670080fff110d21a6f08484c3cad1af51b9c408ca6fc57c1f2b324306a",
        filename: "appsignal-aarch64-darwin-all-static.tar.gz"
      },
      "arm-darwin" => %{
        checksum: "24c438670080fff110d21a6f08484c3cad1af51b9c408ca6fc57c1f2b324306a",
        filename: "appsignal-aarch64-darwin-all-static.tar.gz"
      },
      "aarch64-linux" => %{
        checksum: "9bf7b130279a5f64eb1c81372f481cfc077bd27910c7e6444f11f2dbecdf4424",
        filename: "appsignal-aarch64-linux-all-static.tar.gz"
      },
      "i686-linux" => %{
        checksum: "87449265504cc75140d34db4c01fa8257552e0aaf765bf72a67599c3ca180885",
        filename: "appsignal-i686-linux-all-static.tar.gz"
      },
      "x86-linux" => %{
        checksum: "87449265504cc75140d34db4c01fa8257552e0aaf765bf72a67599c3ca180885",
        filename: "appsignal-i686-linux-all-static.tar.gz"
      },
      "x86_64-linux" => %{
        checksum: "e93a4cfaf05d99e9a3e52affb511b895729f8bee12f1f606f6db46ff1126f0d9",
        filename: "appsignal-x86_64-linux-all-static.tar.gz"
      },
      "x86_64-linux-musl" => %{
        checksum: "5ffb26996dd2979828ed52b0ddd3caa81ff2c86228431f415c37de72ad07ed58",
        filename: "appsignal-x86_64-linux-musl-all-static.tar.gz"
      },
      "aarch64-linux-musl" => %{
        checksum: "fc1edeccdbb115c6bf596a7f3bd58b67099ad7bb155c0c901b7a15f2dc012419",
        filename: "appsignal-aarch64-linux-musl-all-static.tar.gz"
      },
      "x86_64-freebsd" => %{
        checksum: "5bf7a44675b14ada1b8c88471e694ceef32bcbb72bc83b33c4f3c7ee1c29e7cf",
        filename: "appsignal-x86_64-freebsd-all-static.tar.gz"
      },
      "amd64-freebsd" => %{
        checksum: "5bf7a44675b14ada1b8c88471e694ceef32bcbb72bc83b33c4f3c7ee1c29e7cf",
        filename: "appsignal-x86_64-freebsd-all-static.tar.gz"
      },
    }
  end
end
