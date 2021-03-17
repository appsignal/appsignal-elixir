defmodule Appsignal.Agent do
  def version, do: "d08ae6c"

  def triples do
    %{
      "x86_64-darwin" => %{
        checksum: "09a6ab79a1888b0d5101f099c1441477192243e431a2f099137a88dc13bf841e",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/d08ae6c/appsignal-x86_64-darwin-all-static.tar.gz"
      },
      "universal-darwin" => %{
        checksum: "09a6ab79a1888b0d5101f099c1441477192243e431a2f099137a88dc13bf841e",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/d08ae6c/appsignal-x86_64-darwin-all-static.tar.gz"
      },
      "i686-linux" => %{
        checksum: "976a43a8679bd69fc58b0f2dd2a15e9dc28ff27b5bd971a9c33cb75ee7f5f2d3",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/d08ae6c/appsignal-i686-linux-all-static.tar.gz"
      },
      "x86-linux" => %{
        checksum: "976a43a8679bd69fc58b0f2dd2a15e9dc28ff27b5bd971a9c33cb75ee7f5f2d3",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/d08ae6c/appsignal-i686-linux-all-static.tar.gz"
      },
      "x86_64-linux" => %{
        checksum: "f5ddf0914c285849a5f765ee15d7ea6a7c5ab415aa949fb0a521edd82516caa7",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/d08ae6c/appsignal-x86_64-linux-all-static.tar.gz"
      },
      "x86_64-linux-musl" => %{
        checksum: "c00fdf7f24ef459314eb9294c645df1517c1062498897abfc71b092f0fd26eb6",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/d08ae6c/appsignal-x86_64-linux-musl-all-static.tar.gz"
      },
      "x86_64-freebsd" => %{
        checksum: "cd6b80873e94a6f79a62bda6ca0058d97f4fccef4b07f5abde198d8df582de0d",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/d08ae6c/appsignal-x86_64-freebsd-all-static.tar.gz"
      },
      "amd64-freebsd" => %{
        checksum: "cd6b80873e94a6f79a62bda6ca0058d97f4fccef4b07f5abde198d8df582de0d",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/d08ae6c/appsignal-x86_64-freebsd-all-static.tar.gz"
      },
    }
  end
end
