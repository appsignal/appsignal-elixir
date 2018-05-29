defmodule Appsignal.Agent do
  def version, do: "6d079b6"

  def triples do
    %{
      "x86_64-darwin" => %{
        checksum: "04b9721dc8abe072f6a36bfc8a4dbff140194dce1433bd5400886b72f615e828",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/6d079b6/appsignal-x86_64-darwin-all-static.tar.gz"
      },
      "universal-darwin" => %{
        checksum: "04b9721dc8abe072f6a36bfc8a4dbff140194dce1433bd5400886b72f615e828",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/6d079b6/appsignal-x86_64-darwin-all-static.tar.gz"
      },
      "i686-linux" => %{
        checksum: "01b25a346276262db69fc8f0048eb3b44faec5d0363b4d00459252b248f76007",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/6d079b6/appsignal-i686-linux-all-static.tar.gz"
      },
      "x86-linux" => %{
        checksum: "01b25a346276262db69fc8f0048eb3b44faec5d0363b4d00459252b248f76007",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/6d079b6/appsignal-i686-linux-all-static.tar.gz"
      },
      "i686-linux-musl" => %{
        checksum: "34762246413becc700c3276c940c2cc16462fe5b639336baf6f8f21d7f739901",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/6d079b6/appsignal-i686-linux-musl-all-static.tar.gz"
      },
      "x86-linux-musl" => %{
        checksum: "34762246413becc700c3276c940c2cc16462fe5b639336baf6f8f21d7f739901",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/6d079b6/appsignal-i686-linux-musl-all-static.tar.gz"
      },
      "x86_64-linux" => %{
        checksum: "0088fffe8531fc45c2f023491c14f1a39ed097669c4e478aca98b7b67fd99967",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/6d079b6/appsignal-x86_64-linux-all-static.tar.gz"
      },
      "x86_64-linux-musl" => %{
        checksum: "8e216c45c5e38077b0d01bc479d38e671017b2352c27380efa617181b9af3fc3",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/6d079b6/appsignal-x86_64-linux-musl-all-static.tar.gz"
      },
      "x86_64-freebsd" => %{
        checksum: "8828aa80730c72356a90ebdeb50077bebf55fccd48e54deadb22f2429904224e",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/6d079b6/appsignal-x86_64-freebsd-all-static.tar.gz"
      },
      "amd64-freebsd" => %{
        checksum: "8828aa80730c72356a90ebdeb50077bebf55fccd48e54deadb22f2429904224e",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/6d079b6/appsignal-x86_64-freebsd-all-static.tar.gz"
      },
    }
  end
end
