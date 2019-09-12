defmodule CfdiWeb.PageController do
  use CfdiWeb, :controller

  import SweetXml

  alias Cfdi.Helpers.Xml

  def index(conn, _params) do
    render(conn, "index.html")
  end

  def xml(conn, %{"for" => files} = params) do
    case Xml.parse_xml(files, []) do
      {:ok, xlsx} ->
        File.rm("hello.xlsx")

        conn
        |> put_resp_content_type("text/xlsx")
        |> put_resp_header("content-disposition", "attachment; filename=\"hello.xlsx\"")
        |> send_resp(200, xlsx)
      {:error, error} ->
        conn
        |> put_flash(:error, "Error al leer un archivo")
        |> render("index.html")
    end
  end
  def xml(conn, params) do
    conn
    |> put_flash(:error, "Debes cargar al menos un archivo")
    |> render("index.html")
  end
end
