defprotocol Appsignal.Metadata do
  @fallback_to_any true
  @spec metadata(t) :: map()
  def metadata(value)

  @fallback_to_any true
  @spec name(t) :: nil | binary()
  def name(value)

  @fallback_to_any true
  @spec category(t) :: nil | binary()
  def category(value)

  @fallback_to_any true
  @spec params(t) :: map()
  def params(value)

  @fallback_to_any true
  @spec session(t) :: map()
  def session(value)
end

defimpl Appsignal.Metadata, for: Any do
  def metadata(_) do
    %{}
  end

  def name(_) do
    nil
  end

  def category(_) do
    nil
  end

  def params(_) do
    %{}
  end

  def session(_) do
    %{}
  end
end
