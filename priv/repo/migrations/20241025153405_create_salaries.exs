defmodule UsersApi.Repo.Migrations.CreateSalaries do
  use Ecto.Migration

  def change do
    create table(:salaries) do
      add :amount, :integer, null: false, default: 0
      add :currency, :string, null: false
      add :state, :string, null: false
      add :active_since, :naive_datetime
      add :user_id, references(:users, on_delete: :delete_all), null: false
      timestamps()
    end

    create index(:salaries, [:user_id])
    create unique_index(:salaries, [:user_id, :state], where: "state = 'active'")
  end
end
