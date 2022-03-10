defmodule Dfecto.Token.Schema do
  @moduledoc """
  The Token schema.
  """

  use Ecto.Schema

  import Ecto.Changeset

  alias Dfecto.Account.Schema, as: AccountSchema
  alias Dfecto.User.Schema, as: UserSchema
  alias Dfecto.Utils

  @fields [:name, :key, :created, :internal, :is_owner, :account_id, :user_id]
  @required_fields [:account_id, :user_id]
  @primary_key {:key, :string, autogenerate: {Utils, :generate_token, [30]}}
  @derive {Jason.Encoder, only: @fields}

  @type t :: %__MODULE__{
          name: binary,
          key: binary,
          created: DateTime.t(),
          internal: boolean,
          is_owner: boolean
        }

  schema "authentication_mytoken" do
    field :name, :string
    field :created, :utc_datetime_usec, autogenerate: {DateTime, :utc_now, []}
    field :internal, :boolean, default: false
    field :is_owner, :boolean, default: false

    belongs_to :account, AccountSchema
    belongs_to :user, UserSchema
  end

  @doc false
  @spec changeset(Ecto.Schema.t(), map) :: Ecto.Changeset.t()
  def changeset(my_token, attrs) do
    my_token
    |> cast(attrs, @fields)
    |> validate_required(@required_fields)
  end
end
