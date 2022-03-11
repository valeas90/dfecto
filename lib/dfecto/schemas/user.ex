defmodule Dfecto.Schemas.User do
  @moduledoc """
  The User schema.
  """

  use Ecto.Schema

  import Ecto.Changeset

  alias Dfecto.Schemas.Account
  alias Dfecto.Schemas.AuthGroup
  alias Dfecto.Schemas.Token
  alias Dfecto.Utils

  @fields [
    :email,
    :password,
    :username,
    :first_name,
    :last_name,
    :is_superuser,
    :is_staff,
    :is_active,
    :email_valid,
    :last_login,
    :email_updated_at,
    :timezone,
    :language,
    :login_token,
    :account_id
  ]
  @update_field [
    :first_name,
    :last_name,
    :is_staff,
    :is_active,
    :email_valid,
    :language,
    :login_token,
    :account_id
  ]
  @mail_regex ~r/^[A-Za-z0-9._%+-]+@[A-Za-z0-9._-]+\.[A-Za-z]{2,4}$/
  @username_regex ~r/^[a-f0-9]{30}$/

  @derive {Jason.Encoder, only: @fields}

  @type t :: %__MODULE__{
          email: binary,
          password: binary,
          username: binary,
          first_name: binary,
          last_name: binary,
          is_superuser: boolean,
          is_staff: boolean,
          is_active: boolean,
          email_valid: boolean,
          last_login: DateTime.t(),
          date_joined: DateTime.t(),
          email_updated_at: DateTime.t(),
          timezone: binary,
          language: binary,
          login_token: binary,
          account_id: integer,
          groups: list(AuthGroup.t())
        }

  schema "users_doofinderuser" do
    field :email, :string
    field :password, :string
    field :username, :string, autogenerate: {Utils, :generate_token, [30]}
    field :first_name, :string
    field :last_name, :string
    field :is_superuser, :boolean
    field :is_staff, :boolean, default: false
    field :is_active, :boolean
    field :email_valid, :boolean, default: false
    field :last_login, :utc_datetime_usec
    field :date_joined, :utc_datetime_usec, autogenerate: {DateTime, :utc_now, []}
    field :email_updated_at, :utc_datetime_usec, autogenerate: {DateTime, :utc_now, []}
    field :timezone, :string, default: "UTC"
    field :language, :string
    field :login_token, :string
    field :max_api_keys, :integer, default: 10

    belongs_to :account, Account
    has_many :tokens, Token, on_delete: :delete_all

    many_to_many(:groups, AuthGroup,
      join_through: "users_doofinderuser_groups",
      join_keys: [doofinderuser_id: :id, group_id: :id]
    )
  end

  @doc false
  @spec changeset(Ecto.Schema.t(), map, (String.t() -> boolean)) :: Ecto.Changeset.t()
  def changeset(user, attrs, zone_checker?) do
    user
    |> cast(attrs, @fields)
    |> validate_required([:email, :password])
    |> validate_format(:email, @mail_regex)
    |> validate_format(:username, @username_regex)
    |> unique_constraint(:email,
      name: "helpck_doofinderuser_email_2689ea416bbc7e2b_uniq",
      message: "This email address already exists."
    )
    |> update_change(:email, &String.downcase/1)
    |> validate_change(:email, &(check_zone(&1, &2, zone_checker?)))
    |> update_change(:password, &Pbkdf2.hash_pwd_salt(&1, format: :django, digest: :sha256))
  end

  @doc """
  Changeset for social logins that doesn't need password for the user creation
  """
  @spec changeset_without_password(Ecto.Schema.t(), map, (String.t() -> boolean)) :: Ecto.Changeset.t()
  def changeset_without_password(user, attrs, zone_checker?) do
    user
    |> cast(attrs, @fields)
    |> validate_required([:email])
    |> validate_format(:email, @mail_regex)
    |> validate_format(:username, @username_regex)
    |> unique_constraint(:email,
      name: "helpck_doofinderuser_email_2689ea416bbc7e2b_uniq",
      message: "This email address already exists."
    )
    |> update_change(:email, &String.downcase/1)
    |> validate_change(:email, &(check_zone(&1, &2, zone_checker?)))
  end

  @doc """
  This changeset check user validation.
  Is not included on changeset because of errors on user create
  """
  @spec password_changeset(Ecto.Schema.t(), map) :: Ecto.Changeset.t()
  def password_changeset(user, attrs) do
    user
    |> cast(attrs, [:password])
    |> validate_required(:password)
    |> validate_confirmation(:password, message: "The passwords does not match.", required: true)
    |> validate_length(:password, min: 8, max: 128)
    |> validate_format(:password, ~r/[a-zA-Z]+/)
    |> validate_format(:password, ~r/[0-9]+/)
    |> update_change(:password, &Pbkdf2.hash_pwd_salt(&1, format: :django, digest: :sha256))
  end

  @doc """
  Changeset for user update.
  """
  @spec update_changeset(Ecto.Schema.t(), map) :: Ecto.Changeset.t()
  def update_changeset(user, attrs) do
    cast(user, attrs, @update_field)
  end

  @spec check_zone(atom, String.t(), (String.t() -> boolean)) :: [{atom, String.t()}]
  def check_zone(key, email, zone_checker?) do
    if zone_checker?.(email) do
      [{key, "This email address already exists."}]
    else
      []
    end
  end
end
