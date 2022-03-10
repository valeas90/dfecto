defmodule Dfecto.Account.Schema do
  @moduledoc """
  The Account schema.

  TODO: Clean up account fields, many of them are useless.
  """

  use Ecto.Schema

  import Ecto.Changeset

  alias Dfecto.Token.Schema, as: Token
  alias Dfecto.User.Schema, as: User

  @required_fields [:code]
  @code_regex ~r/^[a-f0-9]{30}$/
  @currency_choices ["EUR", "USD", "GBP"]
  @fields [
    :code,
    :query_limit_reached,
    :pro,
    :temporarily_disabled,
    :start_trial_date,
    :is_installed,
    :max_searchengines,
    :mktcod,
    :mkt_source,
    :goal_done,
    :created_at,
    :is_reseller,
    :reseller_account_id,
    :sales_person_id,
    :commercial_status,
    :currency,
    :payment_unavailable,
    :permit_unpaid_invoices,
    :first_promoter_ref,
    :shopify_billing,
    :non_stop_service,
    :using_layer_v9,
    :plan_version
  ]

  @commercial_status_choices [
    "registered",
    "not_used",
    "trial",
    "customer",
    "freemium",
    "freemium_customer",
    "inactive",
    "unknown"
  ]
  @mkt_source_choices [
    "TFNO",
    "TELEMARKETING",
    "ONLINE-Adwords",
    "ONLINE-Banners",
    "ONLINE-Newsletters",
    "ONLINE-Referrals",
    "ONLINE",
    "ONLINE-TFNO",
    "ADWORDS-TFNO",
    "AFILIADOS-TFNO",
    "AFILIADOS",
    "FERIA",
    "RESELLER",
    "BDR",
    "NO-VALID",
    "REPETIDA"
  ]

  @derive {Jason.Encoder, only: @fields}

  @type t :: %__MODULE__{
          code: binary,
          query_limit_reached: boolean,
          pro: boolean,
          temporarily_disabled: boolean,
          start_trial_date: DateTime.t(),
          is_installed: boolean,
          max_searchengines: integer,
          mktcod: binary,
          mkt_source: binary,
          goal_done: boolean,
          created_at: DateTime.t(),
          is_reseller: boolean,
          reseller_account_id: integer,
          sales_person_id: integer,
          commercial_status: binary,
          currency: binary,
          payment_unavailable: boolean,
          permit_unpaid_invoices: boolean,
          first_promoter_ref: binary,
          shopify_billing: boolean,
          non_stop_service: boolean,
          using_layer_v9: boolean,
          plan_version: integer
        }

  schema "helpck_account" do
    field :code, :string
    field :query_limit_reached, :boolean, default: false
    field :pro, :boolean, default: false
    field :temporarily_disabled, :boolean, default: false
    field :start_trial_date, :utc_datetime_usec
    field :is_installed, :boolean, default: false
    field :max_searchengines, :integer, default: 30
    field :mktcod, :string
    field :mkt_source, :string
    field :goal_done, :boolean, default: false
    field :created_at, :utc_datetime_usec, autogenerate: {DateTime, :utc_now, []}
    field :is_reseller, :boolean, default: false
    field :reseller_account_id, :integer
    field :sales_person_id, :integer
    field :commercial_status, :string, default: "registered"
    field :currency, :string, autogenerate: {__MODULE__, :generate_currency, []}
    field :payment_unavailable, :boolean, default: false
    field :permit_unpaid_invoices, :boolean, default: false
    field :first_promoter_ref, :string
    field :shopify_billing, :boolean, default: false
    field :non_stop_service, :boolean, default: false
    field :using_layer_v9, :boolean, default: false
    field :plan_version, :integer, default: 1

    has_many :tokens, TokenSchema
    has_many :users, UserSchema
  end

  @doc false
  @spec changeset(Ecto.Schema.t(), map) :: Ecto.Changeset.t()
  def changeset(account, attrs) do
    account
    |> cast(attrs, @fields)
    |> validate_required(@required_fields)
    |> unique_constraint(:code,
      name: "helpck_account_code_2ca670b0953736c5_uniq",
      message: "This account code already exists."
    )
    |> validate_format(:code, @code_regex)
    |> validate_length(:commercial_status, max: 100)
    |> validate_inclusion(:commercial_status, @commercial_status_choices)
    |> validate_length(:first_promoter_ref, max: 100)
    |> validate_length(:mktcod, max: 100)
    |> validate_length(:mkt_source, max: 100)
    |> validate_inclusion(:mkt_source, @mkt_source_choices)
    |> validate_length(:currency, max: 3)
    |> validate_inclusion(:currency, @currency_choices)
  end

  @spec generate_currency() :: binary
  def generate_currency do
    case Application.get_env(:doomanager, :aws_doof_zone) do
      "eu1" -> "EUR"
      "us1" -> "USD"
    end
  end
end
