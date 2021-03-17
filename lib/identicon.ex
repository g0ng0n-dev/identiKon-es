defmodule Identicon do
  def main(input) do
    input
    |> hash_input
    |> pick_color
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
