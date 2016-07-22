defmodule AppsignalTest do
  use ExUnit.Case

  test "set gauge" do
    Appsignal.set_gauge("key", 10.0)
  end

  test "increment counter" do
    Appsignal.increment_counter("counter")
    Appsignal.increment_counter("counter", 5)
  end

  test "add distribution value" do
    Appsignal.add_distribution_value("dist_key", 10.0)
  end
end
