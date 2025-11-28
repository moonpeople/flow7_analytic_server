defmodule Flow7AnalyticServer.Energy.Queries do
  alias Flow7AnalyticServer.ClickHouse
  # sn 30C9223CFA80
  # id 841

  def get_data_by_period_query(device, from, to, interval) do
    ClickHouse.query(
      """
        WITH
            now() as now_time,
            {start:DateTime} as from_datetime,
            {finish:DateTime} as to_datetime,
            {interval:Integer} as capacity,
            {inputDeviceId:Integer} as input_device_id,

            data as (
                SELECT
                    toStartOfInterval(at, INTERVAL capacity SECOND) as at,
                    sensor_type_id,
                    value
                FROM welder_production.sensor_values
                WHERE
                    (toUnixTimestamp(at) >= toUnixTimestamp(from_datetime))
                    AND (toUnixTimestamp(at) <= toUnixTimestamp(to_datetime))
                    AND (toUnixTimestamp(at) <= toUnixTimestamp(now_time))
                    AND device_id = input_device_id
            )

          SELECT
            at,
            sensor_type_id,
            toInt64(max(value)) as max_value,
            toInt64(min(value)) as min_value,
            max_value - min_value as diff_value,
            toInt64(avg(value)) as avg_value
          FROM data
          GROUP BY at, sensor_type_id
          ORDER BY at, sensor_type_id
      """,
      %{
        start: from,
        finish: to,
        interval: interval,
        inputDeviceId: device
      }
    )
  end
end
