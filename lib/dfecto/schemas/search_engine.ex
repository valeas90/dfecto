defmodule Doomanager.Schemas.SearchEngine do
  @moduledoc """
  The Search Engine schema
  """

  use Ecto.Schema

  import Ecto.Changeset
  import Ecto.Query

  alias Dfecto.Schemas.Indices.DataSource
  alias Dfecto.Schemas.Indices.DataType
  alias Dfecto.Utils.Ecto.ListField

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

  @spec base :: Ecto.Query.t()
  def base do
    from(search_engine in __MODULE__,
      where: search_engine.deleted == false
    )
  end

  @doc """
  Reduces a query to return all SearchEngines with a hasid in the list passed by param
  """
  @spec for_hashid_list(Ecto.Query.t(), list(binary)) :: Ecto.Query.t()
  def for_hashid_list(query \\ base(), hashid_list) do
    where(query, [se], se.hashid in ^hashid_list)
  end

  @doc """
  Reduces a query to return only the SearchEngines related to the Store passed by parameter.
  """
  @spec for_store(Ecto.Query.t(), binary()) :: Ecto.Query.t()
  def for_store(query \\ base(), store_id) do
    where(query, [se], se.store_id == ^store_id)
  end

  @doc """
  Reduces a query to return the SearchEngines filtered by a list of store codes.
  """
  @spec for_store_list(Ecto.Query.t(), list(binary())) :: Ecto.Query.t()
  def for_store_list(query \\ base(), store_id_list) do
    where(query, [se], se.store_id in ^store_id_list)
  end

  @doc """
  Reduces a query to return the SearchEngines filtered by a datasource
  """
  @spec for_datasource(Ecto.Query.t(), non_neg_integer()) :: Ecto.Query.t()
  def for_datasource(query \\ base(), datasource_id) do
    query
    |> join(:inner, [se], ds in DataSource, on: ds.id == ^datasource_id)
    |> join(:inner, [se, ds], dt in DataType, on: dt.id == ds.datatype_id)
    |> where([se, ds, dt], se.id == dt.search_engine_id)
  end

  @doc """
  Apply some conditions to query based on keyword options

  Eg: [active: true] will apply for the given query, the logic to remove inactive and deleted engines.
  """
  @spec apply_options(Ecto.Query.t(), Keyword.t()) :: Ecto.Query.t()
  def apply_options(query, options) do
    Enum.reduce(options, query, fn
      # remove inactive or deleted engines from query
      {:active, true}, query ->
        where(query, [se], se.inactive == false and se.deleted == false)
    end)
  end
end
