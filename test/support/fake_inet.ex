defmodule FakeInet do
  def gethostname do
    {:ok, ~c"Bobs-MBP.example.com"}
  end
end
