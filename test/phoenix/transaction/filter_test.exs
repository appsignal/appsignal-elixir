defmodule Appsignal.Phoenix.Transaction.FilterTest do
  use ExUnit.Case

  alias Appsignal.Utils.MapFilter

  describe "parameter filtering" do
    test "filter_values does not filter structs" do
      assert MapFilter.filter_values(%{"foo" => "bar", "file" => %Plug.Upload{}}, ["password"]) ==
               %{"foo" => "bar", "file" => %{content_type: nil, filename: nil, path: nil}}
    end
  end
end
