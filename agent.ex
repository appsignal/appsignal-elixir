defmodule Appsignal.Agent do
  def version, do: "0eb371d"

  def triples do
    %{
      "x86_64-darwin" => %{
        checksum: "4177dc40117c85d1396874ab0e7b4d354c477eb00deb3610168833da572ef6c9",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/0eb371d/appsignal-x86_64-darwin-all-dynamic.tar.gz"
       },
      "universal-darwin" => %{
        checksum: "4177dc40117c85d1396874ab0e7b4d354c477eb00deb3610168833da572ef6c9",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/0eb371d/appsignal-x86_64-darwin-all-dynamic.tar.gz"
       },
      "i686-linux" => %{
        checksum: "77b12d3ca2bf75ddcaf85917e6d6ab0f86f60439aeddf15312cd995710e35af4",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/0eb371d/appsignal-i686-linux-all-static.tar.gz"
       },
      "x86-linux" => %{
        checksum: "77b12d3ca2bf75ddcaf85917e6d6ab0f86f60439aeddf15312cd995710e35af4",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/0eb371d/appsignal-i686-linux-all-static.tar.gz"
       },
      "i686-linux-musl" => %{
        checksum: "319d3202689e5b5658d5a5b9d99639bb89926fb7b8d1684a9ac2c84a9bd28317",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/0eb371d/appsignal-i686-linux-musl-all-static.tar.gz"
       },
      "x86-linux-musl" => %{
        checksum: "319d3202689e5b5658d5a5b9d99639bb89926fb7b8d1684a9ac2c84a9bd28317",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/0eb371d/appsignal-i686-linux-musl-all-static.tar.gz"
       },
      "i686-freebsd" => %{
        checksum: "dee5f6c024bc9ea4590a9866e618105557ce62f269a08075479c74a29fe7d8a1",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/0eb371d/appsignal-i686-freebsd-all-static.tar.gz"
       },
      "x86_64-linux" => %{
        checksum: "e7d1327fdbd9cb7d7c7aaac1d90ba96e245891521f6add6d5af4b5f4ccfad1e6",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/0eb371d/appsignal-x86_64-linux-all-static.tar.gz"
       },
      "x86_64-linux-musl" => %{
        checksum: "3dc0ba42f0b37d4c4b8cd03531d2a40b13381077e5a870395189dd9d691880ab",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/0eb371d/appsignal-x86_64-linux-musl-all-static.tar.gz"
       },
      "x86_64-freebsd" => %{
        checksum: "0f8ca95f7a6741d61bed336a85731ff63bf4d8226014057be862d89afc2f865f",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/0eb371d/appsignal-x86_64-freebsd-all-static.tar.gz"
       },
      "amd64-freebsd" => %{
        checksum: "0f8ca95f7a6741d61bed336a85731ff63bf4d8226014057be862d89afc2f865f",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/0eb371d/appsignal-x86_64-freebsd-all-static.tar.gz"
       },
    }
  end
end
