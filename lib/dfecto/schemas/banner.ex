defmodule Dfecto.Schemas.Banner do
  @moduledoc """
  The Banners schema.
  """

  use Ecto.Schema

  import Ecto.Changeset

  alias Dfecto.Schemas.BusinessRules

  @url_or_empty_regex ~r/^$|[-a-zA-Z0-9@:%._\+~#=]{2,256}\.[a-z]{2,6}\b([-a-zA-Z0-9@:%_\+.~#?&\/\/=]*)/
  @url_regex ~r/[-a-zA-Z0-9@:%._\+~#=]{2,256}\.[a-z]{2,6}\b([-a-zA-Z0-9@:%_\+.~#?&\/\/=]*)/

  @fields [
    :image,
    :mobile_image,
    :link,
    :enabled,
    :html_code,
    :is_default,
    :target_blank,
    :business_rules_id
  ]

  @derive {Jason.Encoder, only: @fields}

  @type t :: %__MODULE__{
          image: binary,
          mobile_image: binary,
          link: binary,
          enabled: boolean,
          html_code: binary,
          is_default: boolean,
          target_blank: boolean,
          business_rules_id: integer
        }

  schema "search_engines_bannerbr" do
    # Database configuration is wrong. It is not nullable and should be.
    field :image, :string, default: ""
    field :mobile_image, :string, default: ""
    # Database configuration is wrong. It is not nullable and should be.
    field :link, :string, default: ""
    field :enabled, :boolean, default: true
    field :html_code, :string
    field :is_default, :boolean, default: false
    field :target_blank, :boolean, default: false

    belongs_to :business_rules, BusinessRules, on_replace: :update
  end

  @doc false
  @spec changeset(Ecto.Schema.t(), map) :: Ecto.Changeset.t()
  def changeset(banner, attrs) do
    banner
    |> cast(attrs, @fields)
    |> validate_length(:image, max: 255)
    |> validate_length(:mobile_image, max: 255)
    |> validate_length(:link, max: 300)
    |> validate_format(:image, @url_or_empty_regex)
    |> validate_format(:mobile_image, @url_or_empty_regex)
    |> validate_format(:link, @url_regex)
    |> cast_assoc(:business_rules,
      required: true,
      on_replace: :update,
      with: &BusinessRules.changeset/2
    )
  end
end
