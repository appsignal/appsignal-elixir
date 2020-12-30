defmodule Appsignal.Transaction do
  @doc false

  @deprecated "Use Appsignal.Tracer instead."
  def start(_id, _namespace), do: nil

  @deprecated ""
  def generate_id, do: nil

  @deprecated "Use Appsignal.Span instead."
  def set_action(_action), do: nil

  @deprecated "Use Appsignal.Span instead."
  def set_sample_data(_key, _values), do: nil

  @deprecated "Use Appsignal.Span instead."
  def set_error(_transaction, _name, _message, _backtrace), do: nil

  @deprecated "Use Appsignal.Span instead."
  def set_error(_name, _message, _backtrace), do: nil

  @deprecated "Use Appsignal.Tracer instead."
  def finish(_), do: nil

  @deprecated "Use Appsignal.Tracer instead."
  def complete(_), do: nil
end
