defmodule Appsignal.Logger.Handler do
  def log(
        %{
          meta: metadata,
          level: level
        } = event,
        %{
          config: %{
            group: group,
            format: format
          },
          formatter: {formatter, formatter_config}
        }
      ) do
    Appsignal.Logger.log(
      level,
      group,
      IO.chardata_to_string(formatter.format(event, formatter_config)),
      Enum.into(metadata, %{}),
      format
    )
  end

  def add(group, format \\ :autodetect) do
    :logger.add_handler(:appsignal_log, __MODULE__, %{
      config: %{
        group: group,
        format: format
      },
      formatter:
        Logger.Formatter.new(
          format: "$message",
          colors: [enabled: false]
        )
    })
  end

  def remove, do: :logger.remove_handler(:appsignal_log)
end
