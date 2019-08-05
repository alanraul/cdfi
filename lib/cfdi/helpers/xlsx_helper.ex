defmodule Cfdi.Helpers.Xlsx do

  alias Elixlsx.{Workbook, Sheet}

  def generate(lol) do
    %Workbook{}
    |> Workbook.append_sheet(Sheet.with_name("Sheet 1")
    |> Sheet.set_cell("A1", "Hello", bold: true))
    |> Elixlsx.write_to("hello.xlsx")

    File.read("hello.xlsx")
  end
end
