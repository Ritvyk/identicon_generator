defmodule Identicon do
  def main(input) do
    input
    |>hash_input
    |>pick_color
    |>build_grid
    |>filter_odds
    |>build_pixel_map
    |>draw_image
    |>save_image(input)

  end

  def pick_color(image) do
    %Identicon.Image{ hex: [r,g,b | _tail ]} = image
    %Identicon.Image{image | color: {r ,g ,b} }

  end

  def save_image(image,input) do
    File.write("images/#{input}.png",image)
  end

  def draw_image(%Identicon.Image{color: color,pixel_map: pixel_map}) do
    image = :egd.create(250,250)
    color = :egd.color(color)

    Enum.each pixel_map, fn({start,end_to}) ->
      :egd.filledRectangle(image,start,end_to,color)
    end

    :egd.render(image)

  end

  def build_pixel_map(%Identicon.Image{grid: grid}=image) do
    pixel_map = Enum.map grid , fn({_code,index}) ->
      horz= rem(index,5)*50
      vert = div(index,5)*50
      top_left = {horz,vert}
      bottom_right = {horz+50,vert+50}

      {top_left,bottom_right}
    end

    %Identicon.Image{image | pixel_map: pixel_map}
  end

  # def draw_image(%Identicon.Image{grid: grid, pixel_map: pixel_map}) do

  # end

  def filter_odds(%Identicon.Image{grid: grid}=image) do
    grid = Enum.filter grid , fn({code,_index}) ->
      rem(code,2) == 0
    end

    %Identicon.Image{image | grid: grid}

  end



  def build_grid(%Identicon.Image{hex: hex}=image) do
    grid =
    hex
    |>Enum.chunk(3)
    |>Enum.map(&mirror_row/1) #referencing a method in elixr
    |>List.flatten
    |>Enum.with_index

    %Identicon.Image{image | grid: grid}

  end

  def mirror_row(row) do
    [f,s | _tail]= row
    row ++ [s,f]
  end


  def hash_input(input) do
    hex = :crypto.hash(:md5,input)
    |>:binary.bin_to_list

    %Identicon.Image{hex: hex}

  end
end
