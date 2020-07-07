defprotocol Appsignal.Metadata do
  @spec metadata(t) :: map()
  def metadata(value)
end
