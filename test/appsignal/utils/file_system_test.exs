defmodule Appsignal.Utils.FileSystemTest do
  use ExUnit.Case
  import AppsignalTest.Utils
  alias Appsignal.Utils.FileSystem

  describe "system_tmp_dir_for_os/1" do
    test "returns /tmp dir on *nix" do
      tmp_dir = "/tmp"
      assert FileSystem.system_tmp_dir_for_os(:unix) == tmp_dir
    end

    test "returns Windows tmp dir on Microsoft Windows" do
      windows_tmp_dir = Path.join(System.tmp_dir(), "windows_tmp_dir")
      File.mkdir(windows_tmp_dir)
      setup_with_env(%{"TMPDIR" => windows_tmp_dir})
      assert FileSystem.system_tmp_dir_for_os(:nt) == windows_tmp_dir
    end
  end
end
