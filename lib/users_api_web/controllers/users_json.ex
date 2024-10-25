defmodule UsersApiWeb.UsersJSON do
  alias UsersApi.User

  @doc """
  Renders a list of users with salaries.
  """
  def index(%{users: users}) do
    for(user <- users, do: user_data(user))
  end

  def invite(%{total_count: total_count, errors: errors}) do
    %{status: "success", succesfully_sent: total_count - Enum.count(errors), errors: errors}
  end

  defp user_data(%User{} = user) do
    %{
      name: user.name,
      salary: user.salaries |> List.first() |> Map.take([:currency, :amount, :state])
    }
  end
end
