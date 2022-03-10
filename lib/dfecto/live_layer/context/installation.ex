defmodule Doomanager.LiveLayer.Installation do
  @moduledoc """
  Module for managing Installations
  """
  import Ecto.Query, warn: false

  alias Doomanager.Events
  alias Doomanager.LiveLayer.Queries.Installation, as: InstallationQuery
  alias Doomanager.LiveLayer.Schemas.Installation, as: InstallationSchema
  alias Doomanager.Repo

  @default_config %{
    "url_hash" => true
  }

  @doc """
  Returns the list of installations.
  """
  @spec list(pos_integer) :: [InstallationSchema.t()]
  def list(account_id) do
    account_id
    |> InstallationQuery.for_account()
    |> Repo.all()
  end

  @doc """
  Gets a single installation.
  """
  @spec get!(binary) :: InstallationSchema.t()
  def get!(id), do: Repo.get!(InstallationSchema, id)

  @doc """
   Gets a single installation.
  """
  @spec get(binary) :: InstallationSchema.t() | nil
  def get(id), do: Repo.get(InstallationSchema, id)

  @doc """
  Creates a installation.
  """
  @spec create(map) ::
          {:ok, InstallationSchema.t()} | {:error, Ecto.Changeset.t() | any()}
  def create(attrs \\ %{}) do
    attrs =
      if is_map(Map.get(attrs, :config)),
        do: Map.update(attrs, :config, %{}, &Map.merge(@default_config, &1)),
        else: attrs

    Repo.transaction(fn ->
      created_installation =
        %InstallationSchema{}
        |> InstallationSchema.changeset(attrs)
        |> Repo.insert()

      with {:ok, installation} <- created_installation,
           :ok <- Events.trigger_event(installation, :created) do
        installation
      else
        {:error, error} ->
          Repo.rollback(error)
      end
    end)
  end

  @doc """
  Updates a installation.
  """
  @spec update(InstallationSchema.t(), map) ::
          {:ok, InstallationSchema.t()} | {:error, Ecto.Changeset.t() | any()}
  def update(%InstallationSchema{} = installation, attrs) do
    Repo.transaction(fn ->
      updated_installation =
        installation
        |> InstallationSchema.changeset(attrs)
        |> Repo.update()

      with {:ok, installation} <- updated_installation,
           :ok <- Events.trigger_event(installation, :updated) do
        installation
      else
        {:error, error} ->
          Repo.rollback(error)
      end
    end)
  end

  @doc """
  Deletes a installation.
  """
  @spec delete(InstallationSchema.t()) ::
          {:ok, InstallationSchema.t()} | {:error, Ecto.Changeset.t() | any()}
  def delete(%InstallationSchema{} = installation) do
    Repo.transaction(fn ->
      with {:ok, _} <- Repo.delete(installation),
           :ok <- Events.trigger_event(installation, :deleted) do
        installation
      else
        {:error, error} ->
          Repo.rollback(error)
      end
    end)
  end
end
