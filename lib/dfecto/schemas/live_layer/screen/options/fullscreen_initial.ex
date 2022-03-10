defmodule Dfecto.Schemas.LiveLayer.Screen.Options.FullscreenInitial do
  @moduledoc false

  use Ecto.Schema

  @primary_key false
  embedded_schema do
    field :min_capture_length, :integer, default: 3

    field :voice_search, :boolean, default: false

    field :add_to_cart_button, :boolean, default: false
    field :availability_card, :boolean, default: false
    field :discount_card, :boolean, default: false
  end
end
