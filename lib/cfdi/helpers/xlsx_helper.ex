defmodule Cfdi.Helpers.Xlsx do

  alias Elixlsx.{Workbook, Sheet}

  @merge_cells [
    {"B1", "F1"},
    {"B2", "F2"},
    {"B3", "F3"}
  ]

  @spec generate(list) :: tuple
  def generate(data) do
    %Sheet{
      name: "Merged Cells",
      merge_cells: @merge_cells
    }
    |> _set_header(data)
    |> _set_body(data, 7)
    |> (&(Workbook.append_sheet(%Workbook{}, &1))).()
    |> Elixlsx.write_to("hello.xlsx")

    File.read("hello.xlsx")
  end

  @spec _set_header(Sheet.t, map) :: Sheet.t
  defp _set_header(sheet, data) do
    sheet
    |> Sheet.set_cell("B2", List.first(data).receiver, bold: true, size: 14)
    |> Sheet.set_cell("B3", "R.F.C: #{List.first(data).rfc}", bold: true, size: 14)
    |> Sheet.set_cell("A6", "FECHA DE INGRESO", [bold: true, wrap_text: true])
    |> Sheet.set_cell("B6", "CONCEPTO", bold: true)
    |> Sheet.set_cell("C6", "FACTURA", bold: true)
    |> Sheet.set_cell("D6", "SUBTOTAL", bold: true)
    |> Sheet.set_cell("E6", "IEPS", bold: true)
    |> Sheet.set_cell("F6", "IVA", bold: true)
    |> Sheet.set_cell("G6", "TOTAL", bold: true)
    |> Sheet.set_cell("J6", "DECRIPCIÓN", bold: true)
    |> Sheet.set_cell("K6", "FORMA DE PAGO", bold: true)
    |> Sheet.set_cell("L6", "UUID", bold: true)
    |> Sheet.set_col_width("A", 18.0)
    |> Sheet.set_col_width("B", 25.0)
    |> Sheet.set_col_width("C", 12.0)
    |> Sheet.set_col_width("D", 10.0)
    |> Sheet.set_col_width("J", 25.0)
    |> Sheet.set_col_width("K", 15.0)
    |> Sheet.set_col_width("L", 15.0)
    |> Sheet.set_row_height(2, 25)
    |> Sheet.set_row_height(3, 25)
  end

  @spec _set_body(Sheet.t, list, integer) :: Sheet.t
  defp _set_body(sheet, [head], row), do: _body_cells(sheet, head, row)
  defp _set_body(sheet, [head | tail], row) do
    sheet
    |> _body_cells(head, row)
    |> _set_body(tail, row ++ 1)
  end

  @spec _body_cells(Sheet.t, map, integer) :: Sheet.t
  defp _body_cells(sheet, data, row)  do
    sheet
    |> Sheet.set_cell("A#{row}", data.date)
    |> Sheet.set_cell("B#{row}", data.concept)
    |> Sheet.set_cell("C#{row}", data.invoice)
    |> Sheet.set_cell("D#{row}", data.subtotal)
    |> Sheet.set_cell("E#{row}", Map.get(data.taxes, :ieps))
    |> Sheet.set_cell("F#{row}", Map.get(data.taxes, :iva))
    |> Sheet.set_cell("G#{row}", data.total)
    |> Sheet.set_cell("H#{row}", data.type)
    |> Sheet.set_cell("J#{row}", data.description)
    |> Sheet.set_cell("K#{row}", data.payment_method)
    |> Sheet.set_cell("L#{row}", data.uuid)
  end
end
