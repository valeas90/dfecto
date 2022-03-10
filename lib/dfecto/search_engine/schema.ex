defmodule Doomanager.SearchEngines.SearchEngine do
  @moduledoc """
  The Search Engine schema
  """

  use Ecto.Schema

  import Ecto.Changeset

  alias Dfecto.EctoUtils.ListField

  @valid_search_zones ["eu1", "us1"]
  @valid_languages [
    nil,
    "ar",
    "bg",
    "ca",
    "cs",
    "da",
    "de",
    "el",
    "en",
    "es",
    "eu",
    "fi",
    "fr",
    "hi",
    "hu",
    "hy",
    "id",
    "it",
    "nl",
    "no",
    "pt",
    "pt-br",
    "ro",
    "ru",
    "sv",
    "tr"
  ]
  @hash_id_regex ~r/^[a-f0-9]{32}$/

  @fields [
    :name,
    :hashid,
    :created_at,
    :store_id,
    :language,
    :search_zone,
    :account_id,
    :platform,
    :auto_process,
    :_facets_value,
    :deleted,
    :inactive,
    :site_url,
    :checkout_url
  ]

  @required_fields [
    :name,
    :hashid,
    :store_id,
    :language,
    :search_zone,
    :account_id,
    :inactive,
    :auto_process,
    :_facets_value
  ]

  @derive {Jason.Encoder, only: @fields}

  @type t :: %__MODULE__{
          name: binary(),
          hashid: binary(),
          created_at: DateTime.t(),
          store_id: binary(),
          language: binary(),
          search_zone: binary(),
          account_id: integer(),
          platform: binary(),
          auto_process: boolean(),
          _facets_value: list(),
          deleted: boolean(),
          inactive: boolean(),
          site_url: binary(),
          checkout_url: binary()
        }

  schema "search_engines_searchengine" do
    field :name, :string
    field :hashid, :string
    field :store_id, :string
    field :language, :string
    field :search_zone, :string
    field :account_id, :integer
    field :platform, :string
    field :auto_process, :boolean, default: true
    field :_facets_value, ListField, default: []
    field :deleted, :boolean, default: false
    field :inactive, :boolean, default: false
    field :site_url, :string, default: ""
    field :checkout_url, :string, default: ""
    timestamps(inserted_at: :created_at, updated_at: false)
  end

  @spec changeset(Ecto.Schema.t(), map) :: Ecto.Changeset.t()
  def changeset(search_engine, attrs) do
    search_engine
    |> cast(attrs, @fields)
    |> validate_required(@required_fields)
    |> validate_format(:hashid, @hash_id_regex)
    |> validate_inclusion(:search_zone, @valid_search_zones)
    |> validate_inclusion(:language, @valid_languages)
  end
end
