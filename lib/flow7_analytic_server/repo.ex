defmodule Flow7AnalyticServer.Repo do
  use Ecto.Repo,
    otp_app: :flow7_analytic_server,
    adapter: Ecto.Adapters.Postgres
end
