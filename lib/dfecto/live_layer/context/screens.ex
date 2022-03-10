defmodule Dfecto.LiveLayer.Screens do
  @moduledoc """
  Context for LiveLayer's screens.
  """
  import Ecto.Query, warn: false

  alias Doomanager.Events
  alias Doomanager.LiveLayer.Layer
  alias Doomanager.LiveLayer.Queries.Screen, as: ScreenQuery
  alias Doomanager.LiveLayer.Schemas.Layer, as: LayerSchema
  alias Doomanager.LiveLayer.Schemas.Screen, as: ScreenSchema
  alias Doomanager.Repo

  @doc """
  Returns the list of screen.
  """
  @spec list :: [ScreenSchema.t()]
  def list, do: Repo.all(ScreenSchema)

  @doc """
  Gets a single screen.

  Raises `Ecto.NoResultsError` if the New screen does not exist.
  """
  @spec get!(pos_integer) :: ScreenSchema.t()
  def get!(id), do: Repo.get!(ScreenSchema, id)

  @doc """
  Get the screens assosicated with a layer
  """
  @spec get_layer_screens(pos_integer()) :: [ScreenSchema.t()]
  def get_layer_screens(layer_id) do
    layer_id
    |> ScreenQuery.for_layer()
    |> Repo.all()
  end

  @doc """
  Creates a screen.
  """
  @spec create(map) :: {:ok, ScreenSchema.t()} | {:error, Ecto.Changeset.t() | any()}
  def create(attrs \\ %{}) do
    attrs =
      with {:ok, layer_id} <- Map.fetch(attrs, :layer_id),
           {:ok, device} <- Map.fetch(attrs, :device),
           %LayerSchema{options: layer_options} <- Layer.get(layer_id),
           %{^device => options_for_device} <- layer_options do
        screen_options = Map.get(attrs, :options, %{})
        merged_options = Map.merge(screen_options, options_for_device)

        Map.put(attrs, :options, merged_options)
      else
        _ -> attrs
      end

    Repo.transaction(fn ->
      created_screen =
        %ScreenSchema{}
        |> ScreenSchema.changeset(attrs)
        |> Repo.insert()

      with {:ok, screen} <- created_screen,
           :ok <- Events.trigger_event(screen, :created) do
        screen
      else
        {:error, error} ->
          Repo.rollback(error)
      end
    end)
  end

  @doc """
  Updates a screen.
  """
  @spec update(ScreenSchema.t(), map) ::
          {:ok, ScreenSchema.t()} | {:error, Ecto.Changeset.t() | any()}
  def update(%ScreenSchema{} = screen, attrs) do
    Repo.transaction(fn ->
      updated_screen =
        screen
        |> ScreenSchema.changeset(attrs)
        |> Repo.update()

      with {:ok, screen} <- updated_screen,
           :ok <- Events.trigger_event(screen, :updated) do
        screen
      else
        {:error, error} ->
          Repo.rollback(error)
      end
    end)
  end

  @doc """
  Deletes a screen.
  """
  @spec delete(ScreenSchema.t()) :: {:ok, ScreenSchema.t()} | {:error, Ecto.Changeset.t() | any()}
  def delete(%ScreenSchema{} = screen) do
    Repo.transaction(fn ->
      with {:ok, screen} <- Repo.delete(screen),
           :ok <- Events.trigger_event(screen, :deleted) do
        screen
      else
        {:error, error} -> Repo.rollback(error)
      end
    end)
  end
end
