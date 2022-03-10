defmodule Dfecto.Repo.Migrations.AddStoreTable do
  @moduledoc """
  Updates resources based on their most recent snapshots.
  This file is the result of performing a manual squash on the existing migrate_resource files
  """

  use Ecto.Migration

  def up do
    create table(:store, primary_key: false) do
      add :id, :uuid, null: false, primary_key: true
      add :account_id, :bigint, null: false
      add :account_code, :text, null: false
      add :name, :text
      add :inserted_at, :utc_datetime_usec, null: false, default: fragment("now()")
      add :updated_at, :utc_datetime_usec, null: false, default: fragment("now()")
    end

    create index(:store, [:account_id])
    create index(:store, [:account_code])
  end

  def down do
    drop table(:store)
  end
end
