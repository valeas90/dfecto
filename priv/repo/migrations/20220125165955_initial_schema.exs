defmodule Dfecto.Repo.Migrations.InitialSchema do
  @moduledoc """
  Updates resources based on their most recent snapshots.
  This file is the result of performing a manual squash on the existing migrate_resource files
  """

  use Ecto.Migration

  def up do
    create table(:layer, primary_key: false) do
      add :id, :bigserial, null: false, primary_key: true
      add :account_id, :bigint, null: false
      add :name, :text
      add :inserted_at, :utc_datetime_usec, null: false, default: fragment("now()")
      add :updated_at, :utc_datetime_usec, null: false, default: fragment("now()")
      add :type, :text
      add :options, :map, null: false, default: %{}
      add :css, :map, null: false, default: %{}
    end

    create table(:new_screen, primary_key: false) do
      add :id, :bigserial, null: false, primary_key: true

      add :layer_id,
          references(:layer,
            column: :id,
            name: "new_screen_layer_id_fkey",
            type: :bigint,
            on_delete: :delete_all,
            on_update: :update_all
          )

      add :order, :bigint, null: false, default: 0
      add :device, :text, null: false
      add :theme, :text
      add :type, :text, null: false
      add :template, :text
      add :indices, {:array, :text}, null: false, default: [""]
      add :options, :map, null: false, default: %{}
      add :params, :map, null: false, default: %{}
      add :sort, :map, null: false, default: %{}
      add :translations, :map, null: false, default: %{}
      add :currencies, :map, null: false, default: %{}
      add :enabled, :boolean, default: true
      add :inserted_at, :utc_datetime_usec, null: false, default: fragment("now()")
      add :updated_at, :utc_datetime_usec, null: false, default: fragment("now()")
    end

    create table(:installation, primary_key: false) do
      add :id, :uuid, null: false, primary_key: true
      add :account_id, :bigint, null: false
      add :name, :text
      add :config, :map, null: false, default: %{}
      add :inserted_at, :utc_datetime_usec, null: false, default: fragment("now()")
      add :updated_at, :utc_datetime_usec, null: false, default: fragment("now()")

      add :layer_id,
          references(:layer,
            column: :id,
            name: "installation_layer_id_fkey",
            type: :bigint,
            on_delete: :nilify_all,
            on_update: :update_all
          )
    end

    create unique_index(:new_screen, [:layer_id, :order, :device])
  end

  def down do
    raise "Rollback of initial schema is not allowed"
  end
end
