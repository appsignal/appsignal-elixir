defmodule Appsignal.SystemTest do
  use ExUnit.Case, async: true
  import AppsignalTest.Utils

  describe "when not on Heroku" do
    test "returns false" do
      refute Appsignal.System.heroku?()
    end
  end

  describe "when on Heroku" do
    setup do: setup_with_env(%{"DYNO" => "1"})

    test "returns true" do
      assert Appsignal.System.heroku?()
    end
  end
end
