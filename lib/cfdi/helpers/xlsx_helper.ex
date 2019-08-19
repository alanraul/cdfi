defmodule Cfdi.Helpers.Xlsx do

  alias Elixlsx.{Workbook, Sheet}

  def generate(lol) do
    IO.inspect(lol)
    "Sheet 1"
    |> Sheet.with_name()
    |> Sheet.set_cell("A1", "Hello", [bold: true, wrap_text: true])
    |> _header()
    |> (&(Workbook.append_sheet(%Workbook{}, &1))).()
    |> Elixlsx.write_to("hello.xlsx")

    File.read("hello.xlsx")
  end

  @spec _header(Sheet.t) :: Sheet.t
  def _header(sheet) do
    sheet
    |> Sheet.set_cell("A2", "FECHA DE INGRESO", [bold: true, wrap_text: true])
    |> Sheet.set_col_width("A", 18.0)
    |> Sheet.set_cell("B2", "CONCEPTO", bold: true)
    |> Sheet.set_cell("C2", "FACTURA", bold: true)
    |> Sheet.set_cell("D2", "SUBTOTAL", bold: true)
    |> Sheet.set_cell("E2", "IEPS", bold: true)
    |> Sheet.set_cell("F2", "IVA", bold: true)
    |> Sheet.set_cell("G2", "TOTAL", bold: true)
    |> Sheet.set_cell("J2", "DECRIPCIÓN", bold: true)
    |> Sheet.set_cell("K2", "FORMA DE PAGO", bold: true)
    |> Sheet.set_cell("L2", "UUID", bold: true)
  end
end
