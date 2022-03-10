defmodule Dfecto.Repo.Migrations.AddCurrenciesAndTranslationsLayer do
  use Ecto.Migration

  def change do
    alter table(:layer) do
      add :currencies, :map, null: false, default: %{}
      add :translations, :map, null: false, default: %{}
    end
  end
end
