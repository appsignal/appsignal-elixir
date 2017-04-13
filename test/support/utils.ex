defmodule AppsignalTest.Utils do
  def clear_env do
    Application.delete_env(:appsignal, :config)

    System.get_env
    |> Enum.filter(
      fn({"APPSIGNAL_" <> _, _}) -> true;
      ({"_APPSIGNAL_" <> _, _}) -> true;
      ({"APP_REVISION", _}) -> true;
      ({"DYNO", _}) -> true;
      (_) -> false end
    ) |> Enum.each(fn({key, _}) ->
      System.delete_env(key)
    end)
  end

  def with_config_for(app, config, function) do
    before = put_merged_config_for(app, config)
    result = function.()
    Application.put_env(app, :config, before)
    result
  end

  def with_config(config, function) do
    with_config_for(:appsignal, config, function)
  end

  defp put_merged_config_for(app, config) do
    before = Application.get_env(app, :config, %{})
    Application.put_env(app, :config, Map.merge(before, config))
    before
  end

  def setup_with_config(config) do
    before = put_merged_config_for(:appsignal, config)

    ExUnit.Callbacks.on_exit fn() ->
      Application.put_env(:appsignal, :config, before)
    end
  end

  def with_env(env, function) do
    before = put_merged_env(env)
    result = function.()
    reset_env(before)
    result
  end

  def setup_with_env(env) do
    before = put_merged_env(env)

    ExUnit.Callbacks.on_exit fn() ->
      reset_env(before)
    end
  end

  defp put_merged_env(env) do
    before = System.get_env

    before
    |> Map.merge(env)
    |> System.put_env

    before
  end

  defp reset_env(before) do
    System.put_env(before)

    Map.keys(System.get_env) -- Map.keys(before)
    |> Enum.each(&System.delete_env/1)
  end
end
