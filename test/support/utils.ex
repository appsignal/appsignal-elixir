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

  def with_env(env, function) do
    before = put_merged_env(env)
    result = function.()
    System.put_env(before)
    result
  end

  def setup_with_env(env) do
    before = put_merged_env(env)

    ExUnit.Callbacks.on_exit fn() ->
      System.put_env(before)
    end
  end

  defp put_merged_env(env) do
    before = System.get_env

    before
    |> Map.merge(env)
    |> System.put_env

    before
  end
end
