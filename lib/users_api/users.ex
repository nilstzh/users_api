defmodule UsersApi.Users do
  @moduledoc """
  The `Users` context manages user-related operations, including querying for users and their salary details.
  """

  import Ecto.Query

  alias UsersApi.{Repo, User}

  @doc """
  Returns the list of users along with their most recently active salary.
  If a `name` filter is provided, it returns only users whose names match the given pattern.
  The results are sorted by user name alphabetically.

  ## Parameters

    - `name` (optional): The name or partial name of the users to search for.

  ## Examples

      iex> list_users_salaries("John")
      [%User{name: "John Doe", salaries: [...]}, ...]
      iex> list_users_salaries()
      [%User{}, ...]
  """
  @spec list_users_salaries(String.t() | nil) :: [User.t()]
  def list_users_salaries(name) do
    User
    |> join(:inner, [u], s in assoc(u, :salaries))
    |> where(^find_name(name))
    |> distinct([u, s], u.id)
    |> order_by([u, s], desc: s.state == :active, desc_nulls_last: s.active_since)
    |> preload([u, s], salaries: s)
    |> Repo.all()
    |> Enum.sort_by(& &1.name)
  end

  defp find_name(nil), do: dynamic(true)
  defp find_name(name), do: dynamic([u], ilike(u.name, ^"%#{name}%"))
end
