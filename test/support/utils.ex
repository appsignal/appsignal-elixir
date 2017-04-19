defmodule AppsignalTest.Utils do
  def with_frozen_environment(function) do
    environment = freeze_environment()
    result = function.()
    unfreeze_environment(environment)
    result
  end

  def freeze_environment do
    {
      Application.get_env(:appsignal, :config, %{}),
      System.get_env
    }
  end

  def unfreeze_environment({config, env}) do
    Application.put_env(:appsignal, :config, config)
    reset_env(env)
  end

  def with_config(config, function) do
    with_config(:appsignal, config, function)
  end

  def with_config(app, config, function) do
    with_frozen_environment(fn() ->
      put_merged_config_for(app, config)
      function.()
    end)
  end

  defp put_merged_config_for(app, config) do
    config = app
    |> Application.get_env(:config, %{})
    |> Map.merge(config)

    Application.put_env(app, :config, config)
  end

  def setup_with_config(config) do
    environment = freeze_environment()
    put_merged_config_for(:appsignal, config)

    ExUnit.Callbacks.on_exit fn() ->
      unfreeze_environment(environment)
    end
  end

  def with_env(env, function) do
    with_frozen_environment(fn() ->
      put_merged_env(env)
      function.()
    end)
  end

  def setup_with_env(env) do
    environment = freeze_environment()
    put_merged_env(env)

    ExUnit.Callbacks.on_exit fn() ->
      unfreeze_environment(environment)
    end
  end

  defp put_merged_env(env) do
    System.get_env
    |> Map.merge(env)
    |> System.put_env
  end

  defp reset_env(before) do
    System.put_env(before)

    Map.keys(System.get_env) -- Map.keys(before)
    |> Enum.each(&System.delete_env/1)
  end
end
