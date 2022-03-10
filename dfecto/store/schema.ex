defmodule Dfecto.Store.Schema do
  @moduledoc """
  The Store schema.
  """

  use Ecto.Schema

  import Ecto.Changeset

  @account_code_regex ~r/^[a-f0-9]{30}$/
  @fields [
    :id,
    :account_code,
    :account_id,
    :name,
    :inserted_at,
    :updated_at
  ]
  @primary_key {:id, Ecto.UUID, autogenerate: true}
  @required_fields [:account_id, :account_code]

  @type t :: %__MODULE__{
          id: binary,
          account_code: binary,
          account_id: integer,
          name: binary,
          inserted_at: DateTime.t(),
          updated_at: DateTime.t()
        }

  schema "store" do
    field :account_code, :string
    field :account_id, :integer
    field :name, :string
    timestamps(inserted_at: :inserted_at, updated_at: :updated_at, type: :utc_datetime)
  end

  @doc false
  @spec changeset(Ecto.Schema.t(), map) :: Ecto.Changeset.t()
  def changeset(store, attrs) do
    store
    |> cast(attrs, @fields)
    |> validate_required(@required_fields)
    |> validate_format(:account_code, @account_code_regex)
    |> unique_constraint(:id, name: "store_pkey")
  end
end
