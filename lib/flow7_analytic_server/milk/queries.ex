defmodule Flow7AnalyticServer.Milk.Queries do
  alias Flow7AnalyticServer.ClickHouse
  # sn CCDBA78A3D0C
  # id 841

  # @dataKeyId 144

  def get_cycles_query(device, start, finish) do
    ClickHouse.query(
      """
        WITH
          now() as now_time,
          {start:DateTime} as from_datetime,
          {finish:DateTime} as to_datetime,
          1 as capacity,
          {device:Integer} as input_device_id,

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
          ),

          dataset AS
          (
              SELECT
                  at,
                  value,
                  lagInFrame(value) OVER (ORDER BY at) AS prev
              FROM data
              ORDER BY at
          ),

          events AS
          (
              SELECT
                  at,
                  value,
                  -- метка начала работы лампы
                  case when value > 300 AND prev = 0 then 1 else 0 end AS start_flag,
                  -- метка конца работы лампы
                  case when value <= 300 AND prev > 0 then 1 else 0 end AS stop_flag
              FROM dataset
          ),

          -- назначаем каждому включению свой session_id (interval_id)
          sessions AS
          (
              SELECT
                  at,
                  value,
                  sum(start_flag) OVER (ORDER BY at ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS session_id
              FROM events
          )

          SELECT
              session_id + 1 as cycle,
              minIf(at, value > 0)                      AS start_time,
              maxIf(at, value > 0)                      AS stop_time,
              dateDiff('second', start_time, stop_time) AS duration,
              sum(value) / 1000000                      AS total
          FROM sessions
          GROUP BY session_id
          HAVING total > 0     -- убрать пустые сессии
          ORDER BY start_time;
      """,
      %{
        start: start,
        finish: finish,
        device: device
      }
    )
  end
end
