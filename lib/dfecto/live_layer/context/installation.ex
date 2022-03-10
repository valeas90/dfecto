defmodule Dfecto.LiveLayer.Context.Installations do
  @moduledoc """
  Module for managing Installations
  """
  import Ecto.Query, warn: false
  import Dfecto.Repo, only: [repo: 0]

  alias Dfecto.Events
  alias Dfecto.LiveLayer.Schemas.Installation, as: InstallationSchema

  @default_config %{
    "url_hash" => true
  }

  @doc """
  Returns the list of installations.
  """
  @spec list(Ecto.Repo.t(), pos_integer) :: [InstallationSchema.t()]
  def list(r \\ repo(), account_id) do
    account_id
    |> InstallationQuery.for_account()
    |> r.all()
  end
  |> r.insert()

with {:ok, installation} <- created_installation

  @doc """
  Gets a single installation.
  """
  @spec get!(Ecto.Repo.t(), binary) :: InstallationSchema.t()
  def get!(r \\ repo(), id), do: Repo.get!(InstallationSchema, id)

  @doc """
   Gets a single installation.
  """
  @spec get(Ecto.Repo.t(), binary) :: InstallationSchema.t() | nil
  def get(id), do: Repo.get(InstallationSchema, id)

  @doc """
  Creates a installation.
  """
  @spec create(map) :: {:ok, InstallationSchema.t()} | {:error, Ecto.Changeset.t() | any()}
  def create(attrs \\ %{}), do: create(repo(), attrs)

  @spec create(Ecto.Repo.t(), map) ::
          {:ok, InstallationSchema.t()} | {:error, Ecto.Changeset.t() | any()}
  def create(r, attrs) do
    attrs =
      if is_map(Map.get(attrs, :config)),
        do: Map.update(attrs, :config, %{}, &Map.merge(@default_config, &1)),
        else: attrs

    r.transaction(fn ->
      created_installation =
        %InstallationSchema{}
        |> InstallationSchema.changeset(attrs)
        |> r.insert()

      with {:ok, installation} <- created_installation,
           :ok <- Events.trigger_event(installation, :created) do
        installation
      else
        {:error, error} ->
          r.rollback(error)
      end
    end)
  end

  @doc """
  Updates a installation.
  """
  @spec update(Ecto.Repo.t(), InstallationSchema.t(), map) ::
          {:ok, InstallationSchema.t()} | {:error, Ecto.Changeset.t() | any()}
  def update(r \\ repo(), %InstallationSchema{} = installation, attrs) do
    r.transaction(fn ->
      updated_installation =
        installation
        |> InstallationSchema.changeset(attrs)
        |> r.update()

      with {:ok, installation} <- updated_installation,
           :ok <- Events.trigger_event(installation, :updated) do
        installation
      else
        {:error, error} ->
          r.rollback(error)
      end
    end)
  end

  @doc """
  Deletes a installation.
  """
  @spec delete(Ecto.Repo.t(), InstallationSchema.t()) ::
          {:ok, InstallationSchema.t()} | {:error, Ecto.Changeset.t() | any()}
  def delete(r \\ repo(), %InstallationSchema{} = installation) do
    r.transaction(fn ->
      with {:ok, _} <- r.delete(installation),
           :ok <- Events.trigger_event(installation, :deleted) do
        installation
      else
        {:error, error} ->
          r.rollback(error)
      end
    end)
  end
end
