defmodule Dfecto.Schemas.Indices.DataType do
  @moduledoc """
  The DataType schema
  """

  use Ecto.Schema

  import Ecto.Changeset
  import Ecto.Query

  alias Dfecto.Schemas.Indices.DataSource
  alias Dfecto.Schemas.SearchEngine

  @presets ["generic", "product", "page", "category"]

  @type t :: %__MODULE__{
          name: binary(),
          preset: binary(),
          options: map(),
          normalization: map(),
          overrides: map(),
          search_engine_id: integer()
        }

  schema "search_engines_datatype" do
    field(:name, :string)
    field(:preset, :string)
    field(:options, :map, default: %{})
    field(:normalization, :map, default: %{})
    field(:overrides, :map, default: %{})

    belongs_to(:search_engine, SearchEngine, foreign_key: :search_engine_id)

    has_many(:datasources, DataSource,
      foreign_key: :datatype_id,
      references: :id,
      on_delete: :delete_all
    )
  end

  @doc """
  Changeset used to create a new index.
  """
  @spec changeset(Ecto.Schema.t(), map) :: Ecto.Changeset.t()
  def changeset(index, params \\ %{}) do
    index
    |> cast(params, [:name, :preset, :search_engine_id, :options])
    |> cast_assoc(:datasources, required: false)
    |> validate_required([:name, :preset, :search_engine_id])
    |> validate_format(:name, ~r/^[a-z][a-z0-9_]*$/)
    |> validate_inclusion(:preset, @presets)
    |> unique_constraint(:name,
      name: "datasources_datasource_name_engine_id_d7fb8043_uniq"
    )
    |> foreign_key_constraint(:search_engine,
      name: "datasources_datasour_search_engine_id_c51c9be0_fk_search_en"
    )
  end

  @spec base :: Ecto.Query.t()
  def base, do: Ecto.Queryable.to_query(__MODULE__)

  @doc """
  Reduces a query to return all DataTypes related to the search_engine_id passed by param
  """
  @spec for_search_engine(Ecto.Query.t(), non_neg_integer()) :: Ecto.Query.t()
  def for_search_engine(query \\ base(), search_engine_id) do
    where(query, [dt], dt.search_engine_id == ^search_engine_id)
  end
end
