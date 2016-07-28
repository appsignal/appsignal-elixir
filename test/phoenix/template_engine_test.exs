defmodule Appsignal.Phoenix.TemplateEngineTest do
  use ExUnit.Case, async: true


  test "Whether the template instrumenter compiles files" do
    file = "test/fixtures/test.txt.eex"
    assert {_, _, _} = Appsignal.Phoenix.Template.EExEngine.compile(file, "test.txt")
  end

end
