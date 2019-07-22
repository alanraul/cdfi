defmodule CfdiWeb.PageController do
  use CfdiWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
