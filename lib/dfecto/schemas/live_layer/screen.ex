defmodule Dfecto.LiveLayer.Schemas.Screen do
  @moduledoc """
  The screen schema for livelayer
  """

  use Ecto.Schema

  import Ecto.Changeset
  import Ecto.Query

  alias Dfecto.Schemas.LiveLayer.Screen

  @fields [
    :layer_id,
    :order,
    :device,
    :theme,
    :type,
    :template,
    :indices,
    :options,
    :params,
    :sort,
    :translations,
    :currencies,
    :enabled
  ]

  @required_fields [
    :layer_id,
    :device,
    :type
  ]

  @type t :: %__MODULE__{
          layer_id: integer,
          order: integer,
          device: binary,
          theme: binary,
          type: binary,
          template: binary,
          indices: any,
          options: map,
          params: map,
          sort: map,
          translations: map,
          currencies: map,
          enabled: boolean
        }

  schema "new_screen" do
    field :currencies, :map, default: %{}
    field :device, :string
    field :indices, {:array, :string}, default: [""]
    field :options, :map, default: %{}
    field :order, :integer
    field :params, :map, default: %{}
    field :sort, :map, default: %{}
    field :template, :string
    field :theme, :string
    field :translations, :map, default: %{}
    field :type, :string
    field :enabled, :boolean

    belongs_to :layer, Dfecto.LiveLayer.Schemas.Layer

    timestamps()
  end

  defimpl Jason.Encoder, for: __MODULE__ do
    @spec encode(map, Jason.Encode.opts()) :: iodata
    def encode(value, opts) do
      value
      |> Map.take([
        :id,
        :layer_id,
        :currencies,
        :device,
        :enabled,
        :indices,
        :options,
        :order,
        :params,
        :sort,
        :template,
        :theme,
        :translations,
        :type,
        :inserted_at,
        :updated_at
      ])
      |> Jason.Encode.map(opts)
    end
  end

  @spec changeset(Ecto.Schema.t(), map) :: Ecto.Changeset.t()
  def changeset(screen, attrs) do
    screen
    |> cast(attrs, @fields)
    |> validate_required(@required_fields)
    |> Screen.Options.cast_embed()
    |> Screen.Params.cast_embed()
  end

  @spec base :: Ecto.Query.t()
  def base, do: __MODULE__

  @spec for_layer(Ecto.Query.t(), integer) :: Ecto.Query.t()
  def for_layer(query \\ base(), layer_id) do
    where(query, [d], d.layer_id == ^layer_id)
  end
end
