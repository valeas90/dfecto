defmodule Dfecto.LiveLayer.Schemas.Screen.Params.Embedded do
  @moduledoc false

  use Ecto.Schema

  @primary_key false
  embedded_schema do
    field :autofilters, :boolean, default: true
  end
end
