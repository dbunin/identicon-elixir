defmodule Identicon do
  @moduledoc """
  Documentation for Identicon.
  """

  @doc """
  Hello world.
  """
  def main(input) do
    input
    |> hash_input
    |> pick_colour
    |> build_grid
    |> filter_odd_squeres
    |> build_pixel_map
    |> draw_image
    |> save_image(input)
  end

  @doc """
  Generates MD5 hash for the input

  ## Examples

      iex> Identicon.hash_input("billy")
      %Identicon.Image{
             color: nil,
             hex: [137, 194, 70, 41, 139, 226, 182, 17, 63, 177, 11, 168, 15,
              60, 105, 86]
           }
  """
  def hash_input(input) do
    hex = :crypto.hash(:md5, input)
    |> :binary.bin_to_list

    %Identicon.Image{hex: hex}
  end

  def pick_colour(%Identicon.Image{hex: [r, g, b | _tail]} = image) do
    %Identicon.Image{image | color: {r, g, b}}
  end

  def build_grid(%Identicon.Image{hex: hex} = image) do
    grid =
      hex
      |> Enum.chunk(3)
      |> Enum.map(&mirror_row/1)
      |> List.flatten
      |> Enum.with_index

    %Identicon.Image{image | grid: grid}
  end

  def mirror_row(row) do
    [first, second | _tail] = row
    row ++ [second, first]
  end

  def filter_odd_squeres(%Identicon.Image{grid: grid} = image) do
    grid = Enum.filter grid, fn({x, _index}) ->
      rem(x, 2) == 0
    end
    %Identicon.Image{image | grid: grid}
  end

  def build_pixel_map(%Identicon.Image{grid: grid} = image) do
    pixel_map = Enum.map grid, fn({_code, index}) ->
      horisontal = rem(index, 5) * 50
      vertical = div(index, 5) * 50
      
      top_left = {horisontal, vertical}
      bottom_right = {horisontal + 50, vertical + 50}
      
      {top_left, bottom_right}
    end 

    %Identicon.Image{image | pixel_map: pixel_map}
  end

  def draw_image(%Identicon.Image{color: color, pixel_map: pixel_map}) do
    image = :egd.create(250, 250)
    fill = :egd.color(color)

    Enum.each pixel_map, fn({start, stop}) ->  
      :egd.filledRectangle(image, start, stop, fill)
    end

    :egd.render(image)
  end

  def save_image(image, filename) do
    File.write("#{filename}.png", image)
  end
end
