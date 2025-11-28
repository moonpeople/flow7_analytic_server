defmodule Flow7AnalyticServerWeb.FallbackController do
  use Flow7AnalyticServerWeb, :controller


  # def call(conn, {:error, %Ecto.Changeset{} = changeset}) do
  #   conn
  #   |> put_status(:unprocessable_entity)
  #   |> put_view(json: Flow7AnalyticServerWeb.ChangesetJSON)
  #   |> render("error.json", changeset: changeset)
  # end

  def call(conn, {:error, :not_found}) do
    send_resp(conn, :not_found, "")
  end

  def call(conn, {:error, :unauthorized}) do
    send_resp(conn, :unauthorized, "")
  end

  def call(conn, {:error, :bad_request, message}) do
    conn
    |> put_status(:bad_request)
    |> put_view(json: Flow7AnalyticServerWeb.ChangesetJSON)
    |> render("error.json", message: message)
  end
end
