defmodule FakeInet do
  def gethostname() do
    {:ok, 'Bobs-MBP.example.com'}
  end
end
