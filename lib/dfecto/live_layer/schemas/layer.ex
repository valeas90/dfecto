defmodule Dfecto.LiveLayer.Schemas.Layer do
  @moduledoc """
  The layer schema for livelayer
  """

  use Ecto.Schema

  import Ecto.Changeset
  import Ecto.Query

  @fields [
    :account_id,
    :css,
    :currencies,
    :name,
    :options,
    :translations,
    :type
  ]

  @required_fields [
    :account_id,
    :type
  ]

  @options_fields_per_device [:availability_card, :discount_card, :add_to_cart_button]

  @layer_types %{
    "TYPE_A" => %{
      screens: [
        %{
          device: "desktop",
          theme: "fullscreen",
          type: "Elixir.LayerWeb.Layers.FullscreenInitial",
          order: 0
        },
        %{
          device: "desktop",
          theme: "fullscreen",
          type: "Elixir.LayerWeb.Layers.Fullscreen",
          order: 1
        },
        %{
          device: "mobile",
          theme: "mobile",
          type: "Elixir.LayerWeb.Layers.MobileInitial",
          order: 0
        },
        %{
          device: "mobile",
          theme: "mobile",
          type: "Elixir.LayerWeb.Layers.Mobile",
          order: 1
        }
      ]
    },
    "TYPE_0" => %{
      screens: [
        %{
          device: "desktop",
          theme: "fullscreen",
          type: "Elixir.LayerWeb.Layers.Fullscreen",
          order: 0
        },
        %{
          device: "mobile",
          theme: "mobile",
          type: "Elixir.LayerWeb.Layers.Mobile",
          order: 0
        }
      ]
    },
    "TYPE_C" => %{
      screens: [
        %{
          device: "desktop",
          theme: "classic",
          type: "Elixir.LayerWeb.Layers.Classic",
          order: 0
        },
        %{
          device: "mobile",
          theme: "mobile",
          type: "Elixir.LayerWeb.Layers.MobileInitial",
          order: 0
        },
        %{
          device: "mobile",
          theme: "mobile",
          type: "Elixir.LayerWeb.Layers.Mobile",
          order: 1
        }
      ]
    },
    "TYPE_E" => %{
      screens: [
        %{
          device: "desktop",
          theme: "embedded",
          type: "Elixir.LayerWeb.Layers.Embedded",
          order: 0
        },
        %{
          device: "mobile",
          theme: "mobile",
          type: "Elixir.LayerWeb.Layers.MobileInitial",
          order: 0
        },
        %{
          device: "mobile",
          theme: "mobile",
          type: "Elixir.LayerWeb.Layers.Mobile",
          order: 1
        }
      ]
    }
  }

  @type t :: %__MODULE__{
          account_id: integer(),
          css: map(),
          currencies: map(),
          name: String.t(),
          options: map(),
          translations: map(),
          type: String.t()
        }

  schema "layer" do
    field :account_id, :integer
    field :css, :map, default: %{}
    field :currencies, :map, default: %{}
    field :name, :string
    field :options, :map, default: %{}
    field :translations, :map, default: %{}
    field :type, :string

    has_many :installation, Dfecto.LiveLayer.Schemas.Installation
    has_many :screen, Dfecto.LiveLayer.Schemas.Screen

    timestamps()
  end

  defimpl Jason.Encoder, for: __MODULE__ do
    @spec encode(map, Jason.Encode.opts()) :: iodata
    def encode(value, opts) do
      value
      |> Map.take([
        :id,
        :account_id,
        :css,
        :currencies,
        :name,
        :options,
        :translations,
        :type,
        :inserted_at,
        :updated_at
      ])
      |> Jason.Encode.map(opts)
    end
  end

  @doc false
  @spec changeset(Ecto.Schema.t(), map) :: Ecto.Changeset.t()
  def changeset(layer, attrs) do
    layer
    |> cast(attrs, @fields)
    |> validate_required(@required_fields)
    |> validate_inclusion(:type, Map.keys(@layer_types))
  end

  @spec type_name(binary) :: binary
  def type_name("TYPE_0"), do: "Basic"
  def type_name("TYPE_A"), do: "Standard"
  def type_name("TYPE_C"), do: "Floating layers only have a results screen"
  def type_name(_), do: "Other"

  @spec layout_name(binary) :: binary
  def layout_name("TYPE_0"), do: "Fullscreen"
  def layout_name("TYPE_A"), do: "Fullscreen"
  def layout_name("TYPE_C"), do: "Floating"
  def layout_name(_), do: "Other"

  @spec known_types :: [binary]
  def known_types, do: Map.keys(@layer_types)

  @spec editable?(t()) :: boolean
  def editable?(%__MODULE__{} = layer),
    do: is_map_key(@layer_types, layer.type)

  @spec options_fields_per_device :: list
  def options_fields_per_device, do: @options_fields_per_device

  @spec screens_by_type(binary) :: {:ok, [map]} | {:error, :invalid_type}
  def screens_by_type(type) when is_map_key(@layer_types, type),
    do: {:ok, @layer_types[type].screens || []}

  def screens_by_type(_),
    do: {:error, :invalid_type}

  @spec base :: Ecto.Query.t()
  def base, do: __MODULE__

  @spec for_account(Ecto.Query.t(), pos_integer) :: Ecto.Query.t()
  def for_account(query \\ base(), account_id) do
    where(query, [d], d.account_id == ^account_id)
  end
end
