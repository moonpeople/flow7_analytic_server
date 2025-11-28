defmodule Flow7AnalyticServer.Devices.Queries do
  alias Flow7AnalyticServer.ClickHouse

  # Flow7AnalyticServer.Devices.Queries.get_device_data(5011, "2025-06-29 14:05:00", "2025-06-30 14:45:00", 60)
  def get_device_test_data(sensor, start_datetime, end_datetime, capacity) do
    with {:ok, start_parsed} <- DateTimeParser.parse(start_datetime),
    {:ok, finish_parsed} <- DateTimeParser.parse(end_datetime),
    {:ok, start} <- start_parsed |> DateTime.from_naive("UTC"),
    {:ok, finish} <- finish_parsed |> DateTime.from_naive("UTC") do
      ClickHouse.query(
        """
          WITH
            now() as now_time,
            {start:DateTime} as from_datetime,
            {finish:DateTime} as to_datetime,
            {capasity:Integer} as capacity,
            {inputSensor:Integer} as input_sensor_id,

            data as (
              SELECT
                toStartOfInterval(at, INTERVAL capacity SECOND) as at,
                value
              FROM sensor_values
              WHERE
                (toUnixTimestamp(at) >= toUnixTimestamp(from_datetime))
                AND (toUnixTimestamp(at) <= toUnixTimestamp(to_datetime))
                AND (toUnixTimestamp(at) <= toUnixTimestamp(now_time))
                AND sensor_id = input_sensor_id
            )

            SELECT
              at,
              toInt64(avg(value)) as value
            FROM data
            GROUP BY at
            ORDER BY at
        """,
        %{
          start: start,
          finish: finish,
          capasity: capacity,
          inputSensor: sensor,
        }
      )
    end
  end
end
