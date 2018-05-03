defmodule Appsignal.Phoenix.Transaction.FilterTest do
  use ExUnit.Case

  alias Appsignal.Utils.MapFilter

  describe "parameter filtering" do

    test "filter_values does not filter structs" do
      assert MapFilter.filter_values(%{"foo" => "bar", "file" => %Plug.Upload{}}, ["password"]) ==
        %{"foo" => "bar", "file" => %Plug.Upload{}}

      assert MapFilter.filter_values(%{"foo" => "bar", "file" => %{__struct__: "s"}}, ["password"]) ==
        %{"foo" => "bar", "file" => %{:__struct__ => "s"}}
    end
  end

end
