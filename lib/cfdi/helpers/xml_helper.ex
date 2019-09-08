defmodule Cfdi.Helpers.Xml do

  import SweetXml

  alias Cfdi.Helpers.Xlsx

  @main "//cfdi:Comprobante"

  def parse_xml([head], acc) do
    with {:ok, xmldoc} <- File.read(Path.expand("#{head.path}")) do
      Xlsx.generate([_get_data(xmldoc)] ++ acc)
    else
      {:error, error} ->
        {:error, "#{head.filename}"}
    end
  end
  def parse_xml([head | tail], acc) do
    with {:ok, xmldoc} <- File.read(Path.expand("#{head.path}")) do
      parse_xml([tail], [_get_data(xmldoc)] ++ acc)
    else
      {:error, error} ->
        {:error, "#{head.filename}"}
    end
  end

  defp _get_data(xml) do
    %{
      date: _set_date(xml),
      uuid: "#{xpath(xml, ~x"#{@main}/cfdi:Complemento/tfd:TimbreFiscalDigital/@UUID")}",
      concept: "#{xpath(xml, ~x"#{@main}/cfdi:Emisor/@Nombre")}",
      invoice: _set_invoice(xml),
      subtotal: "#{xpath(xml, ~x"#{@main}/@SubTotal")}",
      receiver: "#{xpath(xml, ~x"#{@main}/cfdi:Receptor/@Nombre")}",
      rfc: "#{xpath(xml, ~x"#{@main}/cfdi:Emisor/@Rfc")}",
      iva: "#{xpath(xml, ~x"#{@main}/cfdi:Impuestos/@TotalImpuestosTrasladados")}",
      total: "#{xpath(xml, ~x"#{@main}/@Total")}",
      type: _set_type(xpath(xml, ~x"#{@main}/@TipoDeComprobante")),
      description: _set_description(xml),
    }
  end

  defp _set_invoice(xml) do
    "#{xpath(xml, ~x"#{@main}/@Serie")}-#{xpath(xml, ~x"#{@main}/@Folio")}"
  end

  defp _set_date(xml) do
    date =
      xml
      |> xpath(~x"#{@main}/@Fecha")
      |> List.to_string()
      |> String.slice(0..9)
      |> Date.from_iso8601!()

      Enum.join([date.month, date.day, date.year], "/")
  end

  defp _set_type('I'), do: "Ingreso"
  defp _set_type(type), do: type

  defp _set_description(xml) do
    xml
    |> xpath(~x"#{@main}/cfdi:Conceptos/cfdi:Concepto"l)
    |> Enum.reduce("", fn (concept, acc) ->
      desctiption =
        concept
        |> xpath(~x"./@Descripcion")
        |> List.to_string()

      "#{desctiption}, " <> acc
    end)
    |> String.slice(0..-3)
  end
end
