defmodule Cfdi.Helpers.Xml do

  import SweetXml

  alias Cfdi.Helpers.Xlsx

  @main "//cfdi:Comprobante"

  def parse_xml([head], acc) do
    with {:ok, xmldoc} <- File.read(Path.expand("#{head.path}")) do
      IO.inspect function_name(xmldoc)
      # Xlsx.generate([xmldoc] ++ acc)
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

  def function_name(xml) do
    date = xpath(xml, ~x"#{@main}/@Fecha")
    uuid = xpath(xml, ~x"#{@main}/cfdi:Complemento/tfd:TimbreFiscalDigital/@UUID")

    %{
      date: date,
      uuid: uuid
    }
  end
end
