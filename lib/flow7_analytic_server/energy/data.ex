defmodule Flow7AnalyticServer.EnergyData do
  alias Flow7AnalyticServer.Utils
  @doc """
  Получение данных за период по модели POWERMETER

  """
  def get_data_by_period(device, start, finish, interval \\ "hour") do
    with  {:ok, sdp} <- Utils.convert_datetime_type(start),
          {:ok, fdp} <- Utils.convert_datetime_type(finish),
          true <- sdp < fdp,
          {:ok, from} <- Utils.to_datetime_utc(sdp),
          {:ok, to} <- Utils.to_datetime_utc(fdp),
          true <- is_integer(device) do
            Flow7AnalyticServer.Energy.Queries.get_data_by_period_query(device, from, to, Utils.interval_to_seconds(interval))
            |> case do
              {:ok, result} -> {:ok, process_data(result.rows)}
              _ -> {:error, "Database Error"}
            end
          else
            _ -> {:error, "Error in query parameters"}
    end
  end

  # Обработка ответа
  def process_data(data) do
    data
    |> Enum.group_by(fn [datetime, _id | _] -> datetime end)
    |> Enum.map(fn {datetime, group} ->
      %{
        at: datetime,
        data: Enum.map(group, &build_sensor_data_detailed/1)
      }
    end)
    |> Enum.sort_by(& &1.at)
  end

  defp build_sensor_data_detailed([_datetime, id, max, min, diff, avg]) do
    %{
      name: sensor_name(id),
      value: calculate_value(id, diff, avg) |> Float.round(3),
      min: min,
      max: max,
      diff: diff,
      avg: avg
    }
  end

  defp calculate_value(id, _diff, avg) when id in 145..153 do
    # Для id 145-153: value = avg / 1000
    avg / 1000
  end

  defp calculate_value(154, diff, _avg) do
    # Для id 154: value = diff / 1000
    diff / 1000
  end

  defp calculate_value(_id, _diff, _avg) do
    # Для неизвестных датчиков
    0
  end

  defp sensor_name(id) do
    case id do
      145 -> "Ток фаза A"
      146 -> "Ток фаза B"
      147 -> "Ток фаза C"
      148 -> "Напряжение фаза A"
      149 -> "Напряжение фаза B"
      150 -> "Напряжение фаза C"
      151 -> "Реактивная мощность A"
      152 -> "Реактивная мощность B"
      153 -> "Реактивная мощность C"
      154 -> "Потребление кВт * ч"
      _ -> "Неизвестный датчик #{id}"
    end
  end
end
