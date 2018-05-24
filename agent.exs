defmodule Appsignal.Agent do
  def version, do: "f1d8b5d"

  def triples do
    %{
      "x86_64-darwin" => %{
        checksum: "4deeb24393c3bb51593de2c475b9c1395088dfd16cbd0af634cb0a75c004b426",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/f1d8b5d/appsignal-x86_64-darwin-all-static.tar.gz"
      },
      "universal-darwin" => %{
        checksum: "4deeb24393c3bb51593de2c475b9c1395088dfd16cbd0af634cb0a75c004b426",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/f1d8b5d/appsignal-x86_64-darwin-all-static.tar.gz"
      },
      "i686-linux" => %{
        checksum: "61df57d8342f6e88d842067ea676ec6d2961866491f4ca7178f3455845d63be4",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/f1d8b5d/appsignal-i686-linux-all-static.tar.gz"
      },
      "x86-linux" => %{
        checksum: "61df57d8342f6e88d842067ea676ec6d2961866491f4ca7178f3455845d63be4",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/f1d8b5d/appsignal-i686-linux-all-static.tar.gz"
      },
      "i686-linux-musl" => %{
        checksum: "f3965cffd01eb9ac5d29262dbe59af0fcc376d37b6192d0bade1e17bd8ae87e2",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/f1d8b5d/appsignal-i686-linux-musl-all-static.tar.gz"
      },
      "x86-linux-musl" => %{
        checksum: "f3965cffd01eb9ac5d29262dbe59af0fcc376d37b6192d0bade1e17bd8ae87e2",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/f1d8b5d/appsignal-i686-linux-musl-all-static.tar.gz"
      },
      "x86_64-linux" => %{
        checksum: "eb85d8ba8ec10c1d85125b6af1bf44fb85ac2139ebc15627d740994641c0d8e8",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/f1d8b5d/appsignal-x86_64-linux-all-static.tar.gz"
      },
      "x86_64-linux-musl" => %{
        checksum: "6ac6595829898d6b45647f774ca3570bfe15d7a889cff6e623332c4f20e11622",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/f1d8b5d/appsignal-x86_64-linux-musl-all-static.tar.gz"
      },
      "x86_64-freebsd" => %{
        checksum: "2ff73b4a30022855a4f805a6183378da3ba352a613429547d4a7d5e815d5e31d",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/f1d8b5d/appsignal-x86_64-freebsd-all-static.tar.gz"
      },
      "amd64-freebsd" => %{
        checksum: "2ff73b4a30022855a4f805a6183378da3ba352a613429547d4a7d5e815d5e31d",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/f1d8b5d/appsignal-x86_64-freebsd-all-static.tar.gz"
      },
    }
  end
end
