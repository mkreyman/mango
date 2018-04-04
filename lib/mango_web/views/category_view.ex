defmodule MangoWeb.CategoryView do
  use MangoWeb, :view

  def title_case(string) do
    string
    |> String.downcase()
    |> String.split()
    |> Enum.map(&String.capitalize/1)
    |> Enum.join(" ")
  end
end
