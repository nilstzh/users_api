defmodule UsersApi.User do
  use UsersApi.Schema

  import Ecto.Changeset
  alias UsersApi.Salary

  schema "users" do
    field :name, :string
    has_many :salaries, Salary
    timestamps()
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:name])
    |> validate_required([:name])
  end
end
