defmodule SqueezeWeb.DashboardController do
  use SqueezeWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end