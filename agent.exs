defmodule Appsignal.Agent do
  def version, do: "f781aa1"

  def triples do
    %{
      "x86_64-darwin" => %{
        checksum: "2d881b17e6400f6298acd1e565e714c873fd6e489cfcf19892c71c9fade06381",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/f781aa1/appsignal-x86_64-darwin-all-static.tar.gz"
      },
      "universal-darwin" => %{
        checksum: "2d881b17e6400f6298acd1e565e714c873fd6e489cfcf19892c71c9fade06381",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/f781aa1/appsignal-x86_64-darwin-all-static.tar.gz"
      },
      "i686-linux" => %{
        checksum: "7e9547965dcb31b34fcd52e9cfc248d1f314feb74e1191b8e5061aadd6da14d1",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/f781aa1/appsignal-i686-linux-all-static.tar.gz"
      },
      "x86-linux" => %{
        checksum: "7e9547965dcb31b34fcd52e9cfc248d1f314feb74e1191b8e5061aadd6da14d1",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/f781aa1/appsignal-i686-linux-all-static.tar.gz"
      },
      "i686-linux-musl" => %{
        checksum: "cbfb6b1aaa2a6894b3bcc35f5879cfd232b9ccafe0bc4a95762d4155bf8a65a7",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/f781aa1/appsignal-i686-linux-musl-all-static.tar.gz"
      },
      "x86-linux-musl" => %{
        checksum: "cbfb6b1aaa2a6894b3bcc35f5879cfd232b9ccafe0bc4a95762d4155bf8a65a7",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/f781aa1/appsignal-i686-linux-musl-all-static.tar.gz"
      },
      "x86_64-linux" => %{
        checksum: "e994fff885d8fcae6aeb7e0e41c299b2d5d4a7a724cc7753db5225d54dc8dad9",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/f781aa1/appsignal-x86_64-linux-all-static.tar.gz"
      },
      "x86_64-linux-musl" => %{
        checksum: "64b357d4af2be84010d35cc2cfa843350a6bb788d7eacf48150b0c01bb5e3dff",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/f781aa1/appsignal-x86_64-linux-musl-all-static.tar.gz"
      },
      "x86_64-freebsd" => %{
        checksum: "a3cb12c629f7b52dfab9ec02f755a0512cb104826123e1937e05711fed014f3f",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/f781aa1/appsignal-x86_64-freebsd-all-static.tar.gz"
      },
      "amd64-freebsd" => %{
        checksum: "a3cb12c629f7b52dfab9ec02f755a0512cb104826123e1937e05711fed014f3f",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/f781aa1/appsignal-x86_64-freebsd-all-static.tar.gz"
      },
    }
  end
end
