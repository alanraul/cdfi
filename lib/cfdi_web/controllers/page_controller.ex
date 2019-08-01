defmodule CfdiWeb.PageController do
  use CfdiWeb, :controller

  import SweetXml

  def index(conn, _params) do
    render(conn, "index.html")
  end

  def xml(conn, %{"for" => files} = params) do
    case parse_xml(files, []) do
      {:ok, xmls} ->
        conn
        |> put_flash(:info, "Archivos cargados con exito")
        |> render("index.html")
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

  def parse_xml([head], acc) do
    with {:ok, xmldoc} <- File.read(Path.expand("#{head.path}")) do
      {:ok, [xmldoc] ++ acc}
    else
      {:error, error} ->
        {:error, "#{head.filename}"}
    end
  end
  def parse_xml([head | tail], acc) do
    with {:ok, xmldoc} <- File.read(Path.expand("#{head.path}")) do
      parse_xml([tail], [xmldoc] ++ acc)
    else
      {:error, error} ->
        {:error, "#{head.filename}"}
    end
  end
end
