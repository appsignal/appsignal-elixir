defmodule Appsignal.Agent do
  def version, do: "f81fe90"

  def triples do
    %{
      "x86_64-linux" => %{
        checksum: "5336a1fe0e59e542095463698f5acd2038ecd9899544284f68bc8a312c66a1ef",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/f81fe90/appsignal-x86_64-linux-all-static.tar.gz"
       },
      "i686-linux" => %{
        checksum: "84b72b1dd43e8e58af11658d13b57508a8975bf347f0625d56bd7e69ed7ad382",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/f81fe90/appsignal-i686-linux-all-static.tar.gz"
      },
      "x86-linux" => %{
        checksum: "84b72b1dd43e8e58af11658d13b57508a8975bf347f0625d56bd7e69ed7ad382",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/f81fe90/appsignal-i686-linux-all-static.tar.gz"
      },
      "x86_64-darwin" => %{
        checksum: "2a7179ab79ad28af88bed8db37cbd52b3a8065393f476ae9b5e3d7b027020b72",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/f81fe90/appsignal-x86_64-darwin-all-static.tar.gz"
      },
      "universal-darwin" => %{
        checksum: "2a7179ab79ad28af88bed8db37cbd52b3a8065393f476ae9b5e3d7b027020b72",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/f81fe90/appsignal-x86_64-darwin-all-static.tar.gz"
      }
    }
  end
end
