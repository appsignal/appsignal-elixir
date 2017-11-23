defmodule Appsignal.Agent do
  def version, do: "98aef2c"

  def triples do
    %{
      "x86_64-darwin" => %{
        checksum: "275b03a13348a853f188a1ca88c60478a802a6d75e78468234eb4842f26f666c",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/98aef2c/appsignal-x86_64-darwin-all-static.tar.gz"
       },
      "universal-darwin" => %{
        checksum: "275b03a13348a853f188a1ca88c60478a802a6d75e78468234eb4842f26f666c",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/98aef2c/appsignal-x86_64-darwin-all-static.tar.gz"
       },
      "i686-linux" => %{
        checksum: "7ae3942e3aa7cc659e2318f06cbe45b0dc9fbba219f804665b0bc60ea68efce4",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/98aef2c/appsignal-i686-linux-all-static.tar.gz"
       },
      "x86-linux" => %{
        checksum: "7ae3942e3aa7cc659e2318f06cbe45b0dc9fbba219f804665b0bc60ea68efce4",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/98aef2c/appsignal-i686-linux-all-static.tar.gz"
       },
      "i686-linux-musl" => %{
        checksum: "38859a7d5513f1aa3c849559807c4fba42c8fe76eb93eaf46a96fc5adb8c105a",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/98aef2c/appsignal-i686-linux-musl-all-static.tar.gz"
       },
      "x86-linux-musl" => %{
        checksum: "38859a7d5513f1aa3c849559807c4fba42c8fe76eb93eaf46a96fc5adb8c105a",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/98aef2c/appsignal-i686-linux-musl-all-static.tar.gz"
       },
      "x86_64-linux" => %{
        checksum: "cbf6104586e004bbd6f0e67c8629224a27612ee24a5a9434a5240471330f73a4",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/98aef2c/appsignal-x86_64-linux-all-static.tar.gz"
       },
      "x86_64-linux-musl" => %{
        checksum: "968964c84e0a640b2b7f50c376190d95aa5bee105361d0989c679bcc42f12f79",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/98aef2c/appsignal-x86_64-linux-musl-all-static.tar.gz"
       },
      "x86_64-freebsd" => %{
        checksum: "f9f604127a8315d776312a7ce608aa1df937ed0263a2f0d3ef871d6a0f470b8b",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/98aef2c/appsignal-x86_64-freebsd-all-static.tar.gz"
       },
      "amd64-freebsd" => %{
        checksum: "f9f604127a8315d776312a7ce608aa1df937ed0263a2f0d3ef871d6a0f470b8b",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/98aef2c/appsignal-x86_64-freebsd-all-static.tar.gz"
       },
    }
  end
end
