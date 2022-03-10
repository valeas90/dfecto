defmodule Dfecto.LiveLayer.Schemas.Screen do
  @moduledoc """
  The screen schema for livelayer
  """

  use Ecto.Schema

  import Ecto.Changeset

  alias Doomanager.LiveLayer.Schemas.Screen.Options
  alias Doomanager.LiveLayer.Schemas.Screen.Params

  @options_fields [:min_capture_length, :latest_searches]
  @params_fields [:autofilters]

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

    belongs_to :layer, Doomanager.LiveLayer.Schemas.Layer

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
    |> Options.cast_embed()
    |> Params.cast_embed()
  end

  @spec get_type(binary) :: binary | nil
  def get_type("Elixir.LayerWeb.Layers.FullscreenInitial"), do: "initial"
  def get_type("Elixir.LayerWeb.Layers.Fullscreen"), do: "results"
  def get_type("Elixir.LayerWeb.Layers.MobileInitial"), do: "initial"
  def get_type("Elixir.LayerWeb.Layers.Mobile"), do: "results"
  def get_type("Elixir.LayerWeb.Layers.Classic"), do: "results"
  def get_type(_), do: nil

  @spec options_fields :: [:min_capture_length, ...]
  def options_fields, do: @options_fields

  @spec params_fields :: [:autofilters, ...]
  def params_fields, do: @params_fields
end
