defmodule Dfecto.LiveLayer.Contexts.Screens do
  @moduledoc """
  Context for LiveLayer's screens.
  """
  import Ecto.Query, warn: false
  import Dfecto.Repo, only: [repo: 0]

  alias Dfecto.Events
  alias Dfecto.LiveLayer.Contexts.Layers
  alias Dfecto.LiveLayer.Schemas.Layer
  alias Dfecto.LiveLayer.Schemas.Screen

  @doc """
  Returns the list of screen.
  """
  @spec list(Ecto.Repo.t()) :: [Screen.t()]
  def list(r \\ repo()), do: r.all(Screen)

  @doc """
  Gets a single screen.

  Raises `Ecto.NoResultsError` if the New screen does not exist.
  """
  @spec get!(Ecto.Repo.t(), pos_integer) :: Screen.t()
  def get!(r \\ repo(), id), do: r.get!(Screen, id)

  @doc """
  Get the screens assosicated with a layer
  """
  @spec get_layer_screens(Ecto.Repo.t(), pos_integer()) :: [Screen.t()]
  def get_layer_screens(layer_id) do
    layer_id
    |> ScreenQuery.for_layer()
    |> r.all()
  end

  @doc """ScreenSchema
  def create(attrs \\ %{}) do
    attrs =
      with {:ok, layer_id} <- Map.fetch(attrs, :layer_id),
           {:ok, device} <- Map.fetch(attrs, :device),
           %Layer{options: layer_options} <- Layer.get(layer_id),
           %{^device => options_for_device} <- layer_options do
        screen_options = Map.get(attrs, :options, %{})
        merged_options = Map.merge(screen_options, options_for_device)

        Map.put(attrs, :options, merged_options)
      else
        _ -> attrs
      end

    Repo.transaction(fn ->
      created_screen =
        %Screen{}
        |> Screen.changeset(attrs)
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
  @spec update(Screen.t(), map) ::
          {:ok, Screen.t()} | {:error, Ecto.Changeset.t() | any()}
  def update(%Screen{} = screen, attrs) do
    Repo.transaction(fn ->
      updated_screen =
        screen
        |> Screen.changeset(attrs)
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
  @spec delete(Screen.t()) :: {:ok, Screen.t()} | {:error, Ecto.Changeset.t() | any()}
  def delete(%Screen{} = screen) do
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
