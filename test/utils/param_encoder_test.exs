defmodule ParamsEncoderExampleStruct do
  defstruct a: "b"
end

defmodule Appsignal.Utils.ParamsEncoderTest do
  use ExUnit.Case

  alias Appsignal.Utils.ParamsEncoder

  test "preprocess" do
    assert %{"1" => 2} == ParamsEncoder.preprocess(%{1 => 2})
    assert %{"a" => "b"} == ParamsEncoder.preprocess(%{"a" => "b"})
    assert %{:a => "b"} == ParamsEncoder.preprocess(%{:a => "b"})
    assert %{"{:weird, :key}" => "b"} == ParamsEncoder.preprocess(%{{:weird, :key} => "b"})
    assert %{:a => "b"} == ParamsEncoder.preprocess(%ParamsEncoderExampleStruct{})
  end

  test "deep nesting" do
    assert %{"1" => [%{"666" => true}]} == ParamsEncoder.preprocess(%{1 => [%{666 => true}]})
  end

  test "weird values" do
    assert %{"1" => "{}"} == ParamsEncoder.preprocess(%{1 => {} })
    assert %{:a => "{:error, :foo}"} == ParamsEncoder.preprocess(%{:a => {:error, :foo} })

    assert %{:a => inspect self()} == ParamsEncoder.preprocess(%{:a => self()})

    ref = make_ref()
    assert %{:a => inspect ref} == ParamsEncoder.preprocess(%{:a => ref})
  end

end
