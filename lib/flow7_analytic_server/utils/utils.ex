defmodule Flow7AnalyticServer.Utils do

  def convert_datetime_type(datetime, timezone \\ "UTC") do
    datetime
    |> DateTimeParser.parse()
    |> case do
      {:ok, %Date{} = date} ->
        date
        |> NaiveDateTime.new!(~T[00:00:00])
        |> DateTime.from_naive(timezone)
        |> case do
          {:ok, datetime} -> {:ok, DateTime.truncate(datetime, :second)}
          {:error, error} -> {:error, error}
        end
      {:ok, %Time{} = time} ->
        Date.utc_today()
        |> NaiveDateTime.new!(time)
        |> DateTime.from_naive(timezone)
        |> case do
          {:ok, datetime} -> {:ok, DateTime.truncate(datetime, :second)}
          {:error, error} -> {:error, error}
        end
      {:ok, %NaiveDateTime{} = datetime} ->
        datetime
        |> DateTime.from_naive(timezone)
        |> case do
          {:ok, datetime} -> {:ok, DateTime.truncate(datetime, :second)}
          {:error, error} -> {:error, error}
        end
      {:ok, %DateTime{} = datetime} -> {:ok, DateTime.truncate(datetime, :second)}
      _ -> {:error, "Incorrect date or time"}
    end
  end

  def to_datetime_utc(datetime) do
    DateTime.shift_zone(datetime, "UTC")
  end


  def interval_to_seconds(interval) do
    case interval do
      "minute" -> 60
      "fifteen" -> 900
      "hour" -> 3600
      "day" -> 86400
      _ -> 86400
    end
  end

end
