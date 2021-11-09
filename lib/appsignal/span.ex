defmodule Appsignal.Span do
  alias Appsignal.{Config, Nif, Span}

  defstruct [:reference, :pid]

  require Appsignal.Utils

  @nif Appsignal.Utils.compile_env(:appsignal, :appsignal_tracer_nif, Appsignal.Nif)

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
  def create_root(namespace, pid) do
    if Config.active?() do
      {:ok, reference} = @nif.create_root_span(namespace)

      %Span{reference: reference, pid: pid}
    end
  end

  @spec create_root(String.t(), pid(), integer()) :: t() | nil
  @doc """
  Create a root `Appsignal.Span` with a namespace, a pid and an explicit start time.

  For a description of namespaces, see `set_namespace/2`.

  ## Example
      Appsignal.Span.create_root("http_request", self(), :os.system_time())

  """
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
  def create_child(%Span{reference: parent}, pid) do
    if Config.active?() do
      {:ok, reference} = @nif.create_child_span(parent)

      %Span{reference: reference, pid: pid}
    end
  end

  @spec create_child(t() | nil, pid(), integer()) :: t() | nil
  @doc """
  Create a child `Appsignal.Span` with an explicit start time.

  ## Example
      Appsignal.Tracer.root_span()
      |> Appsignal.Span.create_child(self(), :os.system_time())

  """
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
    if Config.active?() do
      :ok = @nif.set_span_name(reference, name)
      span
    end
  end

  def set_name(_span, _name), do: nil

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
  def set_namespace(%Span{reference: reference} = span, namespace) when is_binary(namespace) do
    :ok = @nif.set_span_namespace(reference, namespace)
    span
  end

  def set_namespace(_span, _name), do: nil

  @spec set_attribute(t() | nil, String.t(), String.t() | integer() | boolean() | float()) ::
          t() | nil
  @doc """
  Sets an `Appsignal.Span` attribute.

  ## Example
      Appsignal.Tracer.root_span()
      |> Appsignal.Span.set_attribute("appsignal:category", "query.ecto")

  """
  def set_attribute(%Span{reference: reference} = span, key, true) when is_binary(key) do
    :ok = Nif.set_span_attribute_bool(reference, key, 1)
    span
  end

  def set_attribute(%Span{reference: reference} = span, key, false) when is_binary(key) do
    :ok = Nif.set_span_attribute_bool(reference, key, 0)
    span
  end

  def set_attribute(%Span{reference: reference} = span, key, value)
      when is_binary(key) and is_binary(value) do
    :ok = Nif.set_span_attribute_string(reference, key, value)
    span
  end

  def set_attribute(%Span{reference: reference} = span, key, value)
      when is_binary(key) and is_integer(value) do
    :ok = Nif.set_span_attribute_int(reference, key, value)
    span
  end

  def set_attribute(%Span{reference: reference} = span, key, value)
      when is_binary(key) and is_float(value) do
    :ok = Nif.set_span_attribute_double(reference, key, value)
    span
  end

  def set_attribute(_span, _key, _value), do: nil

  @spec set_sql(t() | nil, String.t()) :: t() | nil
  @doc """
  Sets the `"appsignal:body"` attribute with an SQL query string.

  ## Example
      Appsignal.Tracer.root_span()
      |> Appsignal.Span.set_sql("SELECT * FROM users")

  """
  def set_sql(%Span{reference: reference} = span, body) when is_binary(body) do
    :ok = Nif.set_span_attribute_sql_string(reference, "appsignal:body", body)
    span
  end

  def set_sql(_span, _body), do: nil

  @deprecated """
  Use the `set_tags/1`, `set_params/1`, `set_headers/1`, `set_session_data/1`
  or `set_custom_data/1` methods on `Appsignal.Tracer` instead.
  """
  @spec set_sample_data(t() | nil, String.t(), map()) :: t() | nil
  @doc """
  Sets sample data for an `Appsignal.Span`. Previously set
  sample data with the same key is overriden. Sample data can only
  be set on a root span.

  **This method is deprecated.** You should instead use the
  `set_tags/1`, `set_params/1`, `set_headers/1`, `set_session_data/1`
  or `set_custom_data/1` methods on `Appsignal.Tracer`.

  ## Example
      Appsignal.Tracer.root_span()
      |> Appsignal.Span.set_sample_data("environment", %{"method" => "GET"})

  """
  def set_sample_data(%Span{reference: _reference} = span, key, value)
      when is_binary(key) and is_map(value) do
    do_set_sample_data(span, key, Appsignal.Utils.MapFilter.filter(value))
  end

  def set_sample_data(_span, _key, _value), do: nil

  @doc false
  def do_set_sample_data(%Span{reference: reference} = span, key, value)
      when is_binary(key) and is_map(value) do
    data = Appsignal.Utils.DataEncoder.encode(value)

    :ok = @nif.set_span_sample_data(reference, key, data)
    span
  end

  def do_set_sample_data(_span, _key, _value), do: nil

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
  def add_error(span, %_{__exception__: true} = exception, stacktrace) do
    {name, message, formatted_stacktrace} = Appsignal.Error.metadata(exception, stacktrace)
    do_add_error(span, name, message, formatted_stacktrace)
  end

  @doc false
  def do_add_error(%Span{reference: reference} = span, name, message, stacktrace) do
    if Config.active?() do
      :ok =
        @nif.add_span_error(
          reference,
          name,
          message,
          Appsignal.Utils.DataEncoder.encode(stacktrace)
        )

      span
    end
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
    Appsignal.Json.decode!(json)
  end
end
