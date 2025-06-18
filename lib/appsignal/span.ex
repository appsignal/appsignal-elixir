defmodule Appsignal.Span do
  alias Appsignal.{Config, Nif, Span}

  defstruct [:reference, :pid]

  @nif Application.compile_env(:appsignal, :appsignal_tracer_nif, Appsignal.Nif)

  @type t() :: %__MODULE__{
          reference: reference(),
          pid: pid()
        }

  @spec create_root(String.t(), pid()) :: t() | nil
  @doc """
  Create a root `Appsignal.Span` with a namespace and a pid.

  For a description of namespaces, see `set_namespace/2`.

  ## Example
      Appsignal.Span.create_root("http_request", self())

  """
  def create_root(namespace, pid), do: create_root(namespace, pid, nil)

  @spec create_root(String.t(), pid(), integer() | nil) :: t() | nil
  @doc """
  Create a root `Appsignal.Span` with a namespace, a pid and an explicit start time.

  For a description of namespaces, see `set_namespace/2`.

  ## Example
      Appsignal.Span.create_root("http_request", self(), :os.system_time())

  """
  def create_root(namespace, pid, nil) do
    if Config.active?() do
      {:ok, reference} = @nif.create_root_span(namespace)

      %Span{reference: reference, pid: pid}
    end
  end

  def create_root(namespace, pid, start_time) do
    if Config.active?() do
      sec = :erlang.convert_time_unit(start_time, :native, :second)
      nsec = :erlang.convert_time_unit(start_time, :native, :nanosecond) - sec * 1_000_000_000
      {:ok, reference} = @nif.create_root_span_with_timestamp(namespace, sec, nsec)

      %Span{reference: reference, pid: pid}
    end
  end

  @spec create_child(t() | nil, pid()) :: t() | nil
  @doc """
  Create a child `Appsignal.Span`.

  ## Example
      Appsignal.Tracer.root_span()
      |> Appsignal.Span.create_child(self())

  """
  def create_child(span, pid), do: create_child(span, pid, nil)

  @spec create_child(t() | nil, pid(), integer() | nil) :: t() | nil
  @doc """
  Create a child `Appsignal.Span` with an explicit start time.

  ## Example
      Appsignal.Tracer.root_span()
      |> Appsignal.Span.create_child(self(), :os.system_time())

  """
  def create_child(%Span{reference: parent}, pid, nil) do
    if Config.active?() do
      {:ok, reference} = @nif.create_child_span(parent)

      %Span{reference: reference, pid: pid}
    end
  end

  def create_child(%Span{reference: parent}, pid, start_time) do
    if Config.active?() do
      sec = :erlang.convert_time_unit(start_time, :native, :second)
      nsec = :erlang.convert_time_unit(start_time, :native, :nanosecond) - sec * 1_000_000_000

      {:ok, reference} = @nif.create_child_span_with_timestamp(parent, sec, nsec)

      %Span{reference: reference, pid: pid}
    end
  end

  @spec set_name(t() | nil, String.t()) :: t() | nil
  @doc """
  Sets an `Appsignal.Span`'s name.

  ## Example
      Appsignal.Tracer.root_span()
      |> Appsignal.Span.set_name("PageController#index")

  """
  def set_name(%Span{reference: reference} = span, name)
      when is_reference(reference) and is_binary(name) do
    :ok = @nif.set_span_name(reference, name)
    span
  end

  def set_name(span, _name), do: span

  @spec set_name_if_nil(t() | nil, String.t()) :: t() | nil
  @doc """
  Sets an `Appsignal.Span`'s name if it was not set before.

  ## Example
      Appsignal.Tracer.root_span()
      |> Appsignal.Span.set_name_if_nil("PageController#index")

  """
  def set_name_if_nil(%Span{reference: reference} = span, name)
      when is_reference(reference) and is_binary(name) do
    :ok = @nif.set_span_name_if_nil(reference, name)
    span
  end

  def set_name_if_nil(span, _name), do: span

  @spec set_namespace(t() | nil, String.t()) :: t() | nil
  @doc """
  Sets an `Appsignal.Span`'s namespace.  The namespace is `"http_request"` or
  `"background_job'` to add the span to the "web" and "background" namespaces
  respectively. Passing another string creates a custom namespace to store the
  `Appsignal.Span`'s samples in.

  ## Example
      Appsignal.Tracer.root_span()
      |> Appsignal.Span.set_namespace("http_request")

  """
  def set_namespace(span, namespace) when is_binary(namespace),
    do: set_attribute(span, "appsignal.namespace", namespace)

  def set_namespace(span, _name), do: span

  @spec set_namespace_if_nil(t() | nil, String.t()) :: t() | nil
  @doc """
  Sets an `Appsignal.Span`'s namespace.  The namespace is `"http_request"` or
  `"background_job'` to add the span to the "web" and "background" namespaces
  respectively. Passing another string creates a custom namespace to store the
  `Appsignal.Span`'s samples in.

  ## Example
      Appsignal.Tracer.root_span()
      |> Appsignal.Span.set_namespace("http_request")

  """
  def set_namespace_if_nil(span, namespace) when is_binary(namespace),
    do: set_attribute(span, "appsignal.namespace_if_nil", namespace)

  def set_namespace_if_nil(span, _name), do: span

  @spec set_attribute(t() | nil, String.t(), String.t() | integer() | boolean() | float()) ::
          t() | nil
  @doc """
  Sets an `Appsignal.Span` attribute.

  ## Example
      Appsignal.Tracer.root_span()
      |> Appsignal.Span.set_attribute("appsignal:category", "query.ecto")

  """
  def set_attribute(%Span{reference: reference} = span, key, true) when is_binary(key) do
    :ok = @nif.set_span_attribute_bool(reference, key, 1)
    span
  end

  def set_attribute(%Span{reference: reference} = span, key, false) when is_binary(key) do
    :ok = @nif.set_span_attribute_bool(reference, key, 0)
    span
  end

  def set_attribute(%Span{reference: reference} = span, key, value)
      when is_binary(key) and is_binary(value) do
    :ok = @nif.set_span_attribute_string(reference, key, value)
    span
  end

  def set_attribute(%Span{reference: reference} = span, key, value)
      when is_binary(key) and is_integer(value) do
    :ok = @nif.set_span_attribute_int(reference, key, value)
    span
  end

  def set_attribute(%Span{reference: reference} = span, key, value)
      when is_binary(key) and is_float(value) do
    :ok = @nif.set_span_attribute_double(reference, key, value)
    span
  end

  def set_attribute(span, _key, _value), do: span

  @spec set_sql(t() | nil, String.t()) :: t() | nil
  @doc """
  Sets the `"appsignal:body"` attribute with an SQL query string.

  ## Example
      Appsignal.Tracer.root_span()
      |> Appsignal.Span.set_sql("SELECT * FROM users")

  """
  def set_sql(%Span{reference: reference} = span, body) when is_binary(body) do
    :ok = @nif.set_span_attribute_sql_string(reference, "appsignal:body", body)
    span
  end

  def set_sql(span, _body), do: span

  @spec set_sample_data(t() | nil, String.t(), map()) :: t() | nil
  @doc """
  Sets sample data for an `Appsignal.Span`.

  ## Example
      Appsignal.Tracer.root_span()
      |> Appsignal.Span.set_sample_data("environment", %{"method" => "GET"})

  """
  def set_sample_data(span, key, value) do
    do_set_sample_data(
      span,
      Application.get_env(:appsignal, :config),
      key,
      value,
      &@nif.set_span_sample_data/3
    )
  end

  @spec set_sample_data_if_nil(t() | nil, String.t(), map()) :: t() | nil
  @doc """
  Sets sample data for an `Appsignal.Span`, unless it has already been set.

  ## Example
      Appsignal.Tracer.root_span()
      |> Appsignal.Span.set_sample_data_if_nil("environment", %{"method" => "GET"})

  """
  def set_sample_data_if_nil(span, key, value) do
    do_set_sample_data(
      span,
      Application.get_env(:appsignal, :config),
      key,
      value,
      &@nif.set_span_sample_data_if_nil/3
    )
  end

  defp do_set_sample_data(span, %{send_params: true}, "params", value, setter) do
    do_set_sample_data(span, "params", Appsignal.Utils.MapFilter.filter(value), setter)
  end

  defp do_set_sample_data(span, %{send_session_data: true}, "session_data", value, setter) do
    do_set_sample_data(span, "session_data", value, setter)
  end

  defp do_set_sample_data(span, _config, "params", _value, _setter) do
    span
  end

  defp do_set_sample_data(span, _config, "session_data", _value, _setter) do
    span
  end

  defp do_set_sample_data(span, _config, key, value, setter) do
    do_set_sample_data(span, key, value, setter)
  end

  defp do_set_sample_data(%Span{reference: reference} = span, key, value, setter)
       when is_binary(key) and (is_map(value) or is_list(value)) do
    data = Appsignal.Utils.DataEncoder.encode(value)

    :ok = setter.(reference, key, data)
    span
  end

  defp do_set_sample_data(span, _key, _value, _setter), do: span

  @spec add_error(t() | nil, Exception.kind(), any(), Exception.stacktrace()) :: t() | nil
  @doc """
  Add an error to an `Appsignal.Span` by passing a `kind` and `reason` from a
  `catch` block, and a stack trace.

  ## Example
      span = Appsignal.Tracer.root_span()

      try
        raise "Exception!"
      catch
        kind, reason ->
          Appsignal.Span.add_error(span, kind, reason, __STACKTRACE__)
      end

  """
  def add_error(span, kind, reason, stacktrace) do
    {name, message, formatted_stacktrace} = Appsignal.Error.metadata(kind, reason, stacktrace)
    do_add_error(span, name, message, formatted_stacktrace)
  end

  @spec add_error(t() | nil, Exception.t(), Exception.stacktrace()) :: t() | nil
  @doc """
  Add an error to an `Appsignal.Span` by passing an exception from a `rescue`
  block, and a stack trace.

  ## Example
      span = Appsignal.Tracer.root_span()

      try
        raise "Exception!"
      rescue
        exception ->
          Appsignal.Span.add_error(span, exception, __STACKTRACE__)
      end

  """
  def add_error(span, %_{__exception__: true, plug_status: status}, _stacktrace)
      when status < 500 do
    span
  end

  def add_error(span, %_{__exception__: true} = exception, stacktrace) do
    {name, message, formatted_stacktrace} = Appsignal.Error.metadata(exception, stacktrace)
    do_add_error(span, name, message, formatted_stacktrace)
  end

  @doc false
  def do_add_error(%Span{reference: reference} = span, name, message, stacktrace) do
    :ok =
      @nif.add_span_error(
        reference,
        name,
        message,
        Appsignal.Utils.DataEncoder.encode(stacktrace)
      )

    span
  end

  def do_add_error(nil, _name, _message, _stacktrace), do: nil

  @spec close(t() | nil) :: t() | nil
  @doc """
  Close an `Appsignal.Span`.

  ## Example
      Appsignal.Tracer.root_span()
      |> Span.close()
  """
  def close(%Span{reference: reference} = span) do
    :ok = @nif.close_span(reference)
    span
  end

  def close(nil), do: nil

  @spec close(t() | nil, integer()) :: t() | nil
  @doc """
  Close an `Appsignal.Span` with an explicit end time.

  ## Example
      Appsignal.Tracer.root_span()
      |> Span.close(span, :os.system_time())
  """
  def close(%Span{reference: reference} = span, end_time) do
    sec = :erlang.convert_time_unit(end_time, :native, :second)
    nsec = :erlang.convert_time_unit(end_time, :native, :nanosecond) - sec * 1_000_000_000
    :ok = @nif.close_span_with_timestamp(reference, sec, nsec)
    span
  end

  def close(nil, _end_time), do: nil

  @doc false
  def to_map(%Span{reference: reference}) do
    {:ok, json} = Nif.span_to_json(reference)
    Jason.decode!(json)
  end
end
