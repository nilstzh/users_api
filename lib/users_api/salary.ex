defmodule UsersApi.Salary do
  use UsersApi.Schema

  import Ecto.Changeset
  alias UsersApi.User

  @states [:active, :inactive]
  @currencies [:USD, :EUR, :JPY, :GBP]
  schema "salaries" do
    field :amount, :integer
    field :state, Ecto.Enum, values: @states
    field :currency, Ecto.Enum, values: @currencies
    field :active_since, :naive_datetime
    belongs_to :user, User
    timestamps()
  end

  @doc false
  def changeset(salary, attrs) do
    salary
    |> cast(attrs, [:amount, :currency, :state, :active_since])
    |> validate_required([:amount, :currency, :state, :active_since])
  end

  def states, do: @states
  def currencies, do: @currencies
end
