defmodule UsersApiWeb.UsersJSON do
  alias UsersApi.User

  @doc """
  Renders a list of users with salaries.
  """
  def index(%{users: users}) do
    for(user <- users, do: data(user))
  end

  defp data(%User{} = user) do
    %{
      name: user.name,
      salary: user.salaries |> List.first() |> Map.take([:currency, :amount, :state])
    }
  end
end
