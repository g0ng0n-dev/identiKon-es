defmodule Identicon do
  def main(input) do
    input
    |> hash_input
    |> pick_color
    |> build_grid
    |> filter_odd_squares
    |> build_pixel_map
    |> draw_image
    |> save_image(input)
  end

  def save_image(image, input) do
    
    File.write("#{input}.png", image)
  end

  def draw_image(%Identicon.Image{color: color, pixel_map: pixel_map}) do
    
    image = :egd.create(250, 250)

    fill = :egd.color(color)

    Enum.each pixel_map, fn({start, stop}) -> 
      ## Here we modified image, we are not creating a new refs
      ## This is because of the erlang library
      :egd.filledRectangle(image, start, stop, fill)
    end

    :egd.render(image)
  end

  ## We added = image at the end of the deconstr so we can have a ref to the image
  def build_grid(%Identicon.Image{hex: hex} = image) do 

    grid = 
      hex
      |> Enum.chunk(3)
      |> Enum.map(&mirrow_row/1)
      |> List.flatten
      |> Enum.with_index
      |> build_pixel_map

    ## We take all of the existing properties out of the existing image 
    ## and then we will also throw in the grid
    %Identicon.Image{image | grid: grid}
  end

  def build_pixel_map(%Identicon.Image{grid:grid} = image) do 

    pixel_map = Enum.map grid, fn({_code, index}) -> 

      horizontal = rem(index, 5) * 50
      vertical = div(index, 5) * 50
      top_left = {horizontal, vertical}
      bottom_right = {horizontal + 50 , vertical + 50}

      {top_left, bottom_right}
    end

    %Identicon.Image{image | pixel_map: pixel_map}

  end


  def filter_odd_squares(%Identicon.Image{grid: grid} = image) do
    
    grid = Enum.filter grid, fn({code, _index}) -> 

      rem(code, 2) == 0

    end

    %Identicon.Image{image | grid: grid}
  end


  def mirrow_row(row) do 

    # in [145, 46, 200]

    [first, second | _tail] = row
    row ++ [second, first] ## Join Lists

    # out [145, 46, 200, 46, 145]
  end

  def pick_color(image) do
    

    ## the _tail is give me the first three values are RGB and then I acknowledge that the
    ## list has many other values inside of it, just toss them off to the wind
    ## %Identicon.Image{hex: [r,g,b |  hex_list ]} = image
    ## [r,g,b |  _tail ] = hex_list
    ## We can move this to the params like
    ##   def pick_color(%Identicon.Image{hex: [r,g,b |  _tail ]} = image) do
    %Identicon.Image{hex: [r,g,b |  _tail ]} = image

    ## so are going to make the new image struct.
    ## I want to take all of the properties off of my existing image 
    ## all the properties of the existing struct
    ## and then also throw on top a tuple of R G and B.
    %Identicon.Image{ image | color: {r,g,b}}
  end



  def hash_input(input) do

    hex = :crypto.hash(:m5, input)
    |> :binary.bin_to_list

    %Identicon.Image{hex:hex}
  end
end
