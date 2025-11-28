defmodule Flow7AnalyticServer.MilkData do
  alias Flow7AnalyticServer.Utils
  @doc """
  Получение данных за период по модели POWERMETER
  device_id - 841
  from - "2025-11-10 00:00:00"
  to - "2025-11-10 23:59:59"
  """
  def get_cycles(device, start, finish) do
    with  {:ok, sdp} <- Utils.convert_datetime_type(start),
          {:ok, fdp} <- Utils.convert_datetime_type(finish),
          true <- sdp < fdp,
          {:ok, from} <- Utils.to_datetime_utc(sdp),
          {:ok, to} <- Utils.to_datetime_utc(fdp),
          true <- is_integer(device) do
            dbg({sdp, fdp, from, to})
            Flow7AnalyticServer.Milk.Queries.get_cycles_query(device, from, to, sdp.time_zone)
            |> case do
              {:ok, result} -> {:ok, process_data(result)}
              _ -> {:error, "Database Error"}
            end
          else
            _ -> {:error, "Error in query parameters"}
    end
  end

  def process_data(response) do
    Enum.map(response.rows, fn row ->
      response.columns
      |> Enum.zip(row)
      |> Enum.into(%{}, fn {k, v} -> {to_string(k), v} end)
    end)
  end


end
