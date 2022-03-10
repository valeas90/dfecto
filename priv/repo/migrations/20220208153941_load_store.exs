defmodule Dfecto.Repo.Migrations.LoadStore do
  use Ecto.Migration

  import Ecto.Query

  def change do
    Dfecto.RepoHelpapp.start_link()
    execute &load_stores/0
  end

  @doc """
  Main function for the migration.

  Live layer clients are migrated to the store table directly.
  The id from installation table is reused for the store record in the store table.
  Some installation records have an account_id from deleted accounts. Those are ommitted.
  The name value from installation is migrated to store table as it is.

  Clients are v7 layer clients if they arent a live layer client, and have at least one non-deleted search engine.
  The name for the store is always Default Store.
  The id for the store is a uuid generated on the spot.

  Insertions are performed in chunks to avoid PostgreSQL protocol errors when the amount of parameters is very long.
  """
  def load_stores() do
    # Collect account_codes into a map. Each key is an account_id. Their value is the corresponding account_code
    account_codes = collect_account_codes()

    # Accounts using live layer
    live_layer_stores = get_live_layer_accounts(account_codes)

    live_layer_account_ids =
      live_layer_stores
      |> Enum.map(fn {key, value} -> Map.get(value, :account_id) end)
      |> MapSet.new()

    # Accounts using layer v7
    v7_stores =
      get_accounts_with_search_engines()
      |> Enum.reject(&MapSet.member?(live_layer_account_ids, &1))
      |> Enum.reduce(%{}, fn account_id, acc ->
        store_id = Ecto.UUID.bingenerate()

        Map.put(acc, store_id, %{
          id: store_id,
          account_id: account_id,
          account_code: Map.get(account_codes, account_id),
          name: "Default Store"
        })
      end)

    all_stores = Map.values(live_layer_stores) ++ Map.values(v7_stores)

    all_stores
    |> Stream.chunk_every(500)
    |> Stream.map(&Dfecto.Repo.insert_all("store", &1))
    |> Stream.run()
  end

  @doc """
  Returns a map with a key for each record from installation table.
  The values for each map element are what we will insert into store table.
  Those installation records with an account_id that is no longer present in helpck_account (MySQL) is ommited.
  The account_code is obtained thanks to the account_codes map received as a param.
  """
  def get_live_layer_accounts(account_codes) do
    Dfecto.Repo.all(from(i in "installation", select: [i.id, i.account_id, i.name]))
    |> Enum.reduce(%{}, fn [installation_id, account_id, name], acc ->
      account_code = Map.get(account_codes, account_id)

      if account_code do
        Map.put(acc, installation_id, %{
          id: installation_id,
          account_id: account_id,
          account_code: account_code,
          name: name
        })
      else
        acc
      end
    end)
  end

  @doc """
  Returns a list with all account_ids existing in the search_engine MySQL table.
  Only accounts with at least one non-deleted search engine are included in the returned list.
  """
  def get_accounts_with_search_engines() do
    from(search_engine in "search_engines_searchengine",
      where: search_engine.deleted == false,
      select: search_engine.account_id
    )
    |> Dfecto.RepoHelpapp.all()
    |> Enum.uniq()
  end

  @doc """
  Auxiliary function that returns a map with account_id and account_code pairs, obtained from account MySQL table.
  """
  def collect_account_codes() do
    from(account in "helpck_account", select: [account.id, account.code])
    |> Dfecto.RepoHelpapp.all()
    |> Enum.reduce(%{}, fn [account_id, account_code], acc ->
      Map.put(acc, account_id, account_code)
    end)
  end
end
