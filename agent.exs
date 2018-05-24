defmodule Appsignal.Agent do
  def version, do: "a17dde1"

  def triples do
    %{
      "x86_64-darwin" => %{
        checksum: "41c6e63c601773a598ef45ae9895f5d6a5cd26602180c9376b6ceab179085454",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/a17dde1/appsignal-x86_64-darwin-all-static.tar.gz"
      },
      "universal-darwin" => %{
        checksum: "41c6e63c601773a598ef45ae9895f5d6a5cd26602180c9376b6ceab179085454",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/a17dde1/appsignal-x86_64-darwin-all-static.tar.gz"
      },
      "i686-linux" => %{
        checksum: "3c6f117c9177460f78b7074dc2062b567fa6faf19035868ab36406cd36314cf7",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/a17dde1/appsignal-i686-linux-all-static.tar.gz"
      },
      "x86-linux" => %{
        checksum: "3c6f117c9177460f78b7074dc2062b567fa6faf19035868ab36406cd36314cf7",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/a17dde1/appsignal-i686-linux-all-static.tar.gz"
      },
      "i686-linux-musl" => %{
        checksum: "b1b357987a72dcaa339692dfb27725f415b7549385db24d45d1dca45c7f13b2a",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/a17dde1/appsignal-i686-linux-musl-all-static.tar.gz"
      },
      "x86-linux-musl" => %{
        checksum: "b1b357987a72dcaa339692dfb27725f415b7549385db24d45d1dca45c7f13b2a",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/a17dde1/appsignal-i686-linux-musl-all-static.tar.gz"
      },
      "x86_64-linux" => %{
        checksum: "cd45d4c8266f5fd57fdaafcbdbf840aec98ba28a3d50386804e44a3e90ee2549",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/a17dde1/appsignal-x86_64-linux-all-static.tar.gz"
      },
      "x86_64-linux-musl" => %{
        checksum: "51cc7c1209a024603f6cef1cceda9b6e06c76e97a2cda6a2607a431ee515c401",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/a17dde1/appsignal-x86_64-linux-musl-all-static.tar.gz"
      },
      "x86_64-freebsd" => %{
        checksum: "94895e50aa4a3aa9bb4f02eef208c9a9156eef955aa7cbfa980d90cf41a9df3f",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/a17dde1/appsignal-x86_64-freebsd-all-static.tar.gz"
      },
      "amd64-freebsd" => %{
        checksum: "94895e50aa4a3aa9bb4f02eef208c9a9156eef955aa7cbfa980d90cf41a9df3f",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/a17dde1/appsignal-x86_64-freebsd-all-static.tar.gz"
      },
    }
  end
end
