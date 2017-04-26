defmodule Appsignal.Phoenix.TemplateEngineTest do
  use ExUnit.Case, async: true

  test "Whether the template instrumenter compiles files" do
    path = "test/fixtures/test.txt.eex"
    assert {_, _, [_, "render.phoenix_template", ^path, _]} =
      Appsignal.Phoenix.Template.EExEngine.compile(path, "test.txt")
  end
end
