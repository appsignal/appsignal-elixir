defmodule Appsignal.Phoenix.TemplateEngineTest do
  use ExUnit.Case, async: true


  test "Whether the templtae instrumenter compiles files" do
    file = "test/fixtures/test.txt.eex"

    assert r = Appsignal.Phoenix.Template.EExEngine.compile(file, "test.txt")
    IO.puts "r: #{inspect r}"

  end

  test "Phoenix template compilation" do
    # a = Templates.render()
    # IO.inspect "a: #{inspect a}"

  end
end
