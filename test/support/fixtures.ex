defmodule UsersApi.Fixtures do
  alias UsersApi.Repo
  alias UsersApi.{Salary, User}

  def user_fixture(attrs \\ %{}) do
    %User{}
    |> Map.merge(attrs)
    |> Repo.insert!()
  end

  def salary_fixture(attrs \\ %{}) do
    salary =
      %Salary{
        amount: 1000,
        state: :inactive,
        currency: :EUR,
        active_since: NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second)
      }
      |> Map.merge(attrs)

    Repo.insert!(salary)
  end
end
