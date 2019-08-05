defmodule Cfdi.Helpers.Xml do

  alias Cfdi.Helpers.Xlsx

  def parse_xml([head], acc) do
    with {:ok, xmldoc} <- File.read(Path.expand("#{head.path}")) do
      Xlsx.generate([xmldoc] ++ acc)
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
