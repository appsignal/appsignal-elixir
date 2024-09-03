defmodule AppsignalTest.Utils do
  require ExUnit.Assertions

  # Remove loaded from the app so the module is recompiled when called. Do this
  # if the module is already loaded before the test env, such as in `mix.exs`.
  def purge(mod) do
    :code.purge(mod)
    :code.delete(mod)
  end

  def with_frozen_environment(function) do
    environment = freeze_environment()
    result = function.()
    unfreeze_environment(environment)
    result
  end

  def freeze_environment do
    {
      Application.get_env(:appsignal, :config, %{}),
      Application.get_env(:appsignal, :config_sources, %{}),
      System.get_env()
    }
  end

  def unfreeze_environment({config, sources, env}) do
    Application.put_env(:appsignal, :config, config)
    Application.put_env(:appsignal, :config_sources, sources)
    reset_env(env)
  end

  def with_config(config, function) do
    with_config(:appsignal, config, function)
  end

  def with_config(app, config, function) do
    with_frozen_environment(fn ->
      put_merged_config_for(app, config)
      function.()
    end)
  end

  def without_config(function) do
    with_frozen_environment(fn ->
      Application.delete_env(:appsignal, :config)
      function.()
    end)
  end

  defp put_merged_config_for(app, config) do
    config =
      app
      |> Application.get_env(:config, %{})
      |> Map.merge(config)

    Application.put_env(app, :config, config)
  end

  def setup_with_config(config) do
    environment = freeze_environment()
    put_merged_config_for(:appsignal, config)

    ExUnit.Callbacks.on_exit(fn ->
      unfreeze_environment(environment)
    end)
  end

  def with_env(env, function) do
    with_frozen_environment(fn ->
      put_merged_env(env)
      function.()
    end)
  end

  def setup_with_env(env) do
    environment = freeze_environment()
    put_merged_env(env)

    ExUnit.Callbacks.on_exit(fn ->
      unfreeze_environment(environment)
    end)
  end

  def reference_or_binary?(term) do
    if System.otp_release() >= "20" do
      is_reference(term)
    else
      is_binary(term)
    end
  end

  defp put_merged_env(env) do
    System.get_env()
    |> Map.merge(env)
    |> System.put_env()
  end

  defp reset_env(before) do
    System.put_env(before)

    (Map.keys(System.get_env()) -- Map.keys(before))
    |> Enum.each(&System.delete_env/1)
  end

  def until(assertion) do
    until(assertion, 500)
  end

  defp until(assertion, retries) when retries < 1 do
    assertion.()
  end

  defp until(assertion, retries) do
    try do
      assertion.()
    rescue
      ExUnit.AssertionError ->
        :timer.sleep(1)
        until(assertion, retries - 1)
    end
  end

  def until_all_messages_processed(name_or_pid) do
    until_messages_queued(name_or_pid, 0)
  end

  def until_messages_queued(name, count) when is_atom(name) do
    until_messages_queued(Process.whereis(name), count)
  end

  def until_messages_queued(pid, count) when is_pid(pid) do
    until(fn ->
      ExUnit.Assertions.assert({_, ^count} = :erlang.process_info(pid, :message_queue_len))
    end)
  end

  def repeatedly(assertion) do
    repeatedly(assertion, 10)
  end

  defp repeatedly(assertion, retries) when retries < 1 do
    assertion.()
  end

  defp repeatedly(assertion, retries) do
    assertion.()
    :timer.sleep(10)
    repeatedly(assertion, retries - 1)
  end

  def run_probes do
    send(Process.whereis(Appsignal.Probes), :run_probes)
  end
end
