defmodule ShortUrl.Repo.Migrations.CreateLink do
  use Ecto.Migration

  def change do
    create table(:links) do
      add :url, :text, null: false
      add :keyword, :string
      add :type, :string

      timestamps()
    end

    create unique_index(:links, [:url])
    create unique_index(:links, [:keyword])

    execute "ALTER SEQUENCE links_id_seq RESTART WITH 3844;"
  end
end
