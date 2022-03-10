defmodule Dfecto.LiveLayer.Schemas.Installation do
  @moduledoc """
  The installation schema for livelayer
  """

  use Ecto.Schema

  import Ecto.Changeset

  @fields [
    :id,
    :account_id,
    :layer_id,
    :name,
    :config
  ]

  @required_fields [
    :account_id,
    :name,
    :layer_id
  ]

  @primary_key {:id, :binary_id, autogenerate: true}

  @type t :: %__MODULE__{
          account_id: integer(),
          config: map(),
          name: String.t()
        }

  schema "installation" do
    field :account_id, :integer
    field :config, :map, default: %{}
    field :name, :string

    belongs_to :layer, Doomanager.LiveLayer.Schemas.Layer

    timestamps()
  end

  @spec changeset(Ecto.Schema.t(), map) :: Ecto.Changeset.t()
  def changeset(installation, attrs) do
    installation
    |> cast(attrs, @fields)
    |> validate_required(@required_fields)
  end

  defimpl Jason.Encoder, for: __MODULE__ do
    @spec encode(map, Jason.Encode.opts()) :: iodata
    def encode(value, opts) do
      value
      |> Map.take([
        :account_id,
        :name,
        :layer_id,
        :config,
        :inserted_at,
        :updated_at
      ])
      |> Jason.Encode.map(opts)
    end
  end
end
