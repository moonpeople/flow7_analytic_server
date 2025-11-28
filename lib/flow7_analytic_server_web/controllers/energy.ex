defmodule Flow7AnalyticServerWeb.EnergyController do
  use Flow7AnalyticServerWeb, :controller

  def get_device_data(conn, params) do
    device = params["device"] |> String.to_integer()
    from = params["from"]
    to = params["to"]
    interval = params["interval"] || nil
    Flow7AnalyticServer.EnergyData.get_data_by_period(device, from, to, interval)
    |> case do
      {:ok, data} -> render(conn, :data, data: data)
      {:error, _} -> raise ErrorResponse.NotFound, message: "request error"
    end
  end
end
