defmodule Cfdi.Helpers.Xml do

  import SweetXml

  alias Cfdi.Helpers.Xlsx

  @main "//cfdi:Comprobante"

  @spec parse_xml(list, list) :: tuple
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
      parse_xml(tail, [_get_data(xmldoc)] ++ acc)
    else
      {:error, error} ->
        {:error, "#{head.filename}"}
    end
  end

  @spec _get_data(String.t) :: map
  defp _get_data(xml) do
    %{
      concept: "#{xpath(xml, ~x"#{@main}/cfdi:Emisor/@Nombre")}",
      date: _set_date(xml),
      description: _set_description(xml),
      invoice: _set_invoice(xml),
      payment_method: _set_payment_method("#{xpath(xml, ~x"#{@main}/@FormaPago")}"),
      receiver: "#{xpath(xml, ~x"#{@main}/cfdi:Receptor/@Nombre")}",
      rfc: "#{xpath(xml, ~x"#{@main}/cfdi:Emisor/@Rfc")}",
      subtotal: "#{xpath(xml, ~x"#{@main}/@SubTotal")}",
      taxes: _set_taxes(xml),
      total: "#{xpath(xml, ~x"#{@main}/@Total")}",
      type: _set_type("#{xpath(xml, ~x"#{@main}/@TipoDeComprobante")}"),
      uuid: "#{xpath(xml, ~x"#{@main}/cfdi:Complemento/tfd:TimbreFiscalDigital/@UUID")}",
    }
  end

  @spec _set_description(String.t) :: String.t
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

  @spec _set_date(String.t) :: String.t
  defp _set_date(xml) do
    date =
      xml
      |> xpath(~x"#{@main}/@Fecha")
      |> List.to_string()
      |> String.slice(0..9)
      |> Date.from_iso8601!()

    Enum.join([date.month, date.day, date.year], "/")
  end

  @spec _set_invoice(String.t) :: String.t
  defp _set_invoice(xml) do
    "#{xpath(xml, ~x"#{@main}/@Serie")}-#{xpath(xml, ~x"#{@main}/@Folio")}"
  end

  @spec _set_payment_method(String.t) :: String.t
  defp _set_payment_method("01"), do: "Efectivo"
  defp _set_payment_method("02"), do: "Transferencia electrónica"
  defp _set_payment_method(method), do: method

  @spec _set_taxes(String.t) :: map
  defp _set_taxes(xml) do
    xml
    |> xpath(~x"#{@main}/cfdi:Impuestos/cfdi:Traslados/cfdi:Traslado"l)
    |> Enum.reduce(%{}, fn (taxe, acc) ->
      taxe
      |> xpath(~x"./@Impuesto")
      |> _set_taxe(taxe, acc)
    end)
  end

  @spec _set_taxe(charlist, String.t, map) :: map
  defp _set_taxe('002', taxe, acc) do
    Map.put(acc, :iva, "#{xpath(taxe, ~x"./@Importe")}")
  end
  defp _set_taxe('003', taxe, acc) do
    Map.put(acc, :ieps, "#{xpath(taxe, ~x"./@Importe")}")
  end
  defp _set_taxe(_type, _taxe, acc), do: acc

  @spec _set_type(String.t) :: String.t
  defp _set_type("I"), do: "Ingreso"
  defp _set_type("E"), do: "Egreso"
  defp _set_type("P"), do: "Pago"
  defp _set_type(type), do: type
end
