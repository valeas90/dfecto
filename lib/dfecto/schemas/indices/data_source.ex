defmodule Dfecto.Schemas.Indices.DataSource do
  @moduledoc """
  The DataSource schema
  """

  use Ecto.Schema

  import Ecto.Changeset

  alias Dfecto.Schemas.Indices.DataType
  alias Ecto.Changeset

  @source_types ["bigcommerce", "ekm", "file", "shopify", "magento2"]

  defguard is_source_type(source_type) when source_type in @source_types

  @type t :: %__MODULE__{
          type: binary(),
          options: map(),
          datatype_id: integer()
        }

  schema "search_engines_datasource" do
    field(:type, :string)
    field(:options, :map, default: %{})

    belongs_to(:datatype, DataType, foreign_key: :datatype_id)
  end

  @doc """
  Changeset used to create a new datasource.
  """
  @spec changeset(Ecto.Schema.t(), map) :: Ecto.Changeset.t()
  def changeset(datasource, params \\ %{}) do
    datasource
    |> cast(params, [:type, :options, :datatype_id])
    |> validate_required([:type])
    |> validate_inclusion(:type, @source_types)
    |> validate_json_size(:options, 1_500)
    |> foreign_key_constraint(:index,
      name: "datasources_feedsett_datatype_id_088f4d01_fk_datasourc"
    )
  end

  @spec validate_json_size(Changeset.t(), atom(), integer()) :: Changeset.t()
  defp validate_json_size(changeset, field, max_size) do
    {res, value} =
      changeset
      |> get_field(field)
      |> Jason.encode()

    cond do
      res != :ok ->
        add_error(changeset, field, "is not a valid JSON")

      byte_size(value) >= max_size ->
        add_error(
          changeset,
          field,
          "is bigger than maximum size (#{max_size}B)"
        )

      true ->
        changeset
    end
  end
end
