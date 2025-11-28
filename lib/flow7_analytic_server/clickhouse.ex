defmodule Flow7AnalyticServer.ClickHouse do
  use GenServer

  def start_link(opts \\ []) do
    # Берем настройки из конфига и мерджим с переданными опциями
    config = Application.get_env(:flow7_analytic_server, :ch, [])
    final_opts = Keyword.merge(config, opts)

    GenServer.start_link(__MODULE__, final_opts, name: __MODULE__)
  end

  def init(opts) do
    # Здесь инициализируем соединение с ClickHouse
    {:ok, conn} = Ch.start_link(opts)
    {:ok, %{conn: conn}}
  end

  # Публичный API для использования в приложении
  def query(sql, params \\ []) do
    GenServer.call(__MODULE__, {:query, sql, params})
  end

  def handle_call({:query, sql, params}, _from, state) do
    result = Ch.query(state.conn, sql, params)
    {:reply, result, state}
  end

  # Другие методы по необходимости...
end
