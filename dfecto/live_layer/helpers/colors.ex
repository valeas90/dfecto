defmodule Doomanager.LiveLayer.Colors do
  @moduledoc """
  This module ports functions from the following Javascript repo
  https://github.com/sass/dart-sass/blob/da67438ac2718a30d4c4fe6fac1180bb67e2d15b/lib/src/value/color.dart#L222-L270

  The module allows us to convert colors back and forth between HSL, RGB and hexString in any combination.
  The conversions are idempotent, so there is no collusion and the relation is always 1 to 1

  HSL to RGB -> hsl_to_rgb/3
  HSL to HEX -> hsl_to_hex/3
  RGB to HSL -> rgb_to_hsl/3
  RGB to HEX -> rgb_to_hex/3
  HEX to RGB -> hex_to_rgb/1
  HEX to HSL -> hex_to_hsl/1

  """

  @precision 10

  @doc """
  Converts given HSL values to corresponding hexString
  Example: hexString = Colors.hsl_to_hex(167.84810126582278, 42.702702702702695, 63.725490196078425)
           #7BCABA
  """
  @spec hsl_to_hex(float | integer, float | integer, float | integer) :: binary
  def hsl_to_hex(hue, saturation, lightness) do
    [red, green, blue] = hsl_to_rgb(hue, saturation, lightness)
    rgb_to_hex(red, green, blue)
  end

  @doc """
  Converts given hexString to corresponding HSL values
  Example: hsl = Colors.hex_to_hsl("#7BCABA")
           [167.84810126582278, 42.702702702702695, 63.725490196078425]
  """
  @spec hex_to_hsl(binary) :: [integer]
  def hex_to_hsl(hex) do
    [red, green, blue] = hex_to_rgb(hex)
    rgb_to_hsl(red, green, blue)
  end

  @doc """
  Converts given HSL values to corresponding RGB values
  Example: [red, green, blue] = Colors.hsl_to_rgb(167.84810126582278, 42.702702702702695, 63.725490196078425)
           [123, 202, 186]
  """
  @spec hsl_to_rgb(float | integer, float | integer, float | integer) :: [integer | float]
  def hsl_to_rgb(hue, saturation, lightness) do
    scaled_hue = hue / 360
    scaled_saturation = saturation / 100
    scaled_lightness = lightness / 100

    m2 =
      if scaled_lightness <= 0.5 do
        scaled_lightness * (scaled_saturation + 1)
      else
        scaled_lightness + scaled_saturation - scaled_lightness * scaled_saturation
      end

    m1 = scaled_lightness * 2 - m2

    red = fuzzy_round(hue_to_rgb(m1, m2, scaled_hue + 1 / 3) * 255)
    green = fuzzy_round(hue_to_rgb(m1, m2, scaled_hue) * 255)
    blue = fuzzy_round(hue_to_rgb(m1, m2, scaled_hue - 1 / 3) * 255)

    [red, green, blue]
  end

  @doc """
  Converts given RGB values to corresponding HSL values
  Example: [hue, saturation, lightness] = Colors.rgb_to_hsl(123, 202, 186)
           [167.84810126582278, 42.702702702702695, 63.725490196078425]
  """
  @spec rgb_to_hsl(integer, integer, integer) :: [integer]
  def rgb_to_hsl(red, green, blue) do
    scaled_red = red / 255
    scaled_green = green / 255
    scaled_blue = blue / 255

    maxx = max(max(scaled_red, scaled_green), scaled_blue)
    minn = min(min(scaled_red, scaled_green), scaled_blue)
    delta = maxx - minn

    hue =
      cond do
        maxx == minn -> 0
        maxx == scaled_red -> 60 * (scaled_green - scaled_blue) / delta
        maxx == scaled_green -> 120 + 60 * (scaled_blue - scaled_red) / delta
        maxx == scaled_blue -> 240 + 60 * (scaled_red - scaled_green) / delta
      end

    lightness = 50 * (maxx + minn)

    saturation =
      cond do
        maxx == minn -> 0
        lightness < 50 -> 100 * delta / (maxx + minn)
        true -> 100 * delta / (2 - maxx - minn)
      end

    [hue, saturation, lightness]
  end

  @doc """
  Helper to convert a given hexString to the corresponding RGB
  Example: [red, green, blue] = Colors.hex_to_rgb("#7BCABA")
           [123, 202, 186]
  """
  @spec hex_to_rgb(binary) :: [integer]
  def hex_to_rgb(hex) do
    if String.length(hex) == 7 do
      red = hex |> String.slice(1, 2) |> String.to_integer(16)
      green = hex |> String.slice(3, 2) |> String.to_integer(16)
      blue = hex |> String.slice(5, 2) |> String.to_integer(16)
      [red, green, blue]
    else
      red = String.slice(hex, 1, 1)
      green = String.slice(hex, 2, 1)
      blue = String.slice(hex, 3, 1)
      red = String.to_integer("#{red}#{red}", 16)
      green = String.to_integer("#{green}#{green}", 16)
      blue = String.to_integer("#{blue}#{blue}", 16)
      [red, green, blue]
    end
  end

  @doc """
  Helper to convert a given RGB to corresponding hexString
  Example: Colors.rgb_to_hex(123, 202, 186)
           #7BCABA
  """
  @spec rgb_to_hex(integer, integer, integer) :: binary
  def rgb_to_hex(red, green, blue) do
    red = String.slice("0#{Integer.to_string(red, 16)}", -2, 2)
    green = String.slice("0#{Integer.to_string(green, 16)}", -2, 2)
    blue = String.slice("0#{Integer.to_string(blue, 16)}", -2, 2)
    "##{red}#{green}#{blue}"
  end

  @spec hue_to_rgb(float, float, float) :: float
  defp hue_to_rgb(m1, m2, hue) do
    hue = if hue < 0, do: hue + 1, else: hue
    hue = if hue > 1, do: hue - 1, else: hue

    cond do
      hue < 1 / 6 -> m1 + (m2 - m1) * hue * 6
      hue < 1 / 2 -> m2
      hue < 2 / 3 -> m1 + (m2 - m1) * (2 / 3 - hue) * 6
      true -> m1
    end
  end

  @spec fuzzy_round(float) :: integer
  defp fuzzy_round(number) do
    # Taken from https://github.com/sass/dart-sass/blob/a10d7c677dd90f9f5731fa220d1553af620bedea/lib/src/util/number.dart
    result =
      if number > 0 do
        if fuzzy_less_than(decimal_part(number), 0.5),
          do: :math.floor(number),
          else: :math.ceil(number)
      else
        if fuzzy_less_than_or_equals(decimal_part(number), 0.5),
          do: :math.floor(number),
          else: :math.ceil(number)
      end

    trunc(result)
  end

  @spec fuzzy_less_than(float, float) :: boolean
  defp fuzzy_less_than(first, second) do
    first < second and !fuzzy_equals(first, second)
  end

  @spec fuzzy_less_than_or_equals(float, float) :: boolean
  defp fuzzy_less_than_or_equals(first, second) do
    first < second or fuzzy_equals(first, second)
  end

  @spec fuzzy_equals(float, float) :: boolean
  defp fuzzy_equals(first, second) do
    abs(first - second) < epsilon()
  end

  @spec decimal_part(float) :: float
  defp decimal_part(number) do
    # equivalent to 8.56 % 1 = 0.56 in javascript
    number - trunc(number)
  end

  @spec epsilon :: float
  defp epsilon do
    :math.pow(10, -@precision - 1)
  end
end
