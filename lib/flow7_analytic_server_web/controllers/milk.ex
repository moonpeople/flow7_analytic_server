defmodule Flow7AnalyticServerWeb.MilkController do
  use Flow7AnalyticServerWeb, :controller

  action_fallback MattrBaseWeb.FallbackController

  def get_device_cycles(conn, params) do
    device = params["device"] |> String.to_integer()
    from = params["from"]
    to = params["to"]
    Flow7AnalyticServer.MilkData.get_cycles(device, from, to)
    |> case do
      {:ok, data} -> render(conn, :data, data: data)
      {:error, _} -> raise ErrorResponse.NotFound, message: "request error"
    end
  end
end
