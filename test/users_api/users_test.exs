defmodule UsersApi.UsersTest do
  use UsersApi.DataCase
  import UsersApi.Fixtures

  alias UsersApi.{Salary, Users}

  describe "list_users_salaries/1" do
    setup [:prepare_users]

    test "returns users with their most recent active salary" do
      result = Users.list_users_salaries(nil)
      assert Enum.count(result) == 3

      assert Enum.any?(
               result,
               &match?(%{name: "Tom", salaries: [%{state: :active, amount: 2000}]}, &1)
             )

      assert Enum.any?(
               result,
               &match?(%{name: "John", salaries: [%{state: :active, amount: 2000}]}, &1)
             )

      assert Enum.any?(
               result,
               &match?(%{name: "Satomi", salaries: [%{state: :inactive, amount: 2000}]}, &1)
             )

      refute Enum.any?(result, &match?(%{name: "Mike"}, &1))
    end

    test "returns users filtered by name" do
      result = Users.list_users_salaries("Tom")
      assert length(result) == 2

      assert Enum.any?(
               result,
               &match?(%{name: "Tom", salaries: [%{state: :active, amount: 2000}]}, &1)
             )

      assert Enum.any?(
               result,
               &match?(%{name: "Satomi", salaries: [%{state: :inactive, amount: 2000}]}, &1)
             )

      refute Enum.any?(result, &match?(%{name: "John"}, &1))
      refute Enum.any?(result, &match?(%{name: "Mike"}, &1))
    end

    test "returns an empty list when no user matches the name filter" do
      result = Users.list_users_salaries("Non Existent User")
      assert result == []
    end
  end

  describe "list_active_users/0" do
    setup [:prepare_users]

    test "returns users with active salaries" do
      result = Users.list_active_users()
      assert length(result) == 2
      assert Enum.any?(result, &(&1.name == "Tom"))
      assert Enum.any?(result, &(&1.name == "John"))
    end

    test "returns an empty list when there are no active users" do
      Repo.delete_all(Salary)
      result = Users.list_active_users()
      assert result == []
    end
  end

  defp prepare_users(_context) do
    user_with_active_salary_id = Ecto.UUID.generate()
    user_fixture(%{id: user_with_active_salary_id, name: "Tom"})

    salary_fixture(%{user_id: user_with_active_salary_id, state: :inactive, amount: 1000})
    salary_fixture(%{user_id: user_with_active_salary_id, state: :active, amount: 2000})

    another_user_with_active_salary_id = Ecto.UUID.generate()
    user_fixture(%{id: another_user_with_active_salary_id, name: "John"})

    salary_fixture(%{user_id: another_user_with_active_salary_id, state: :inactive, amount: 1000})
    salary_fixture(%{user_id: another_user_with_active_salary_id, state: :active, amount: 2000})

    user_without_active_salary_id = Ecto.UUID.generate()
    user_fixture(%{id: user_without_active_salary_id, name: "Satomi"})

    salary_fixture(%{
      user_id: user_without_active_salary_id,
      state: :inactive,
      amount: 1000,
      active_since: ~N[2024-01-01 00:00:00Z]
    })

    salary_fixture(%{
      user_id: user_without_active_salary_id,
      state: :inactive,
      amount: 2000,
      active_since: ~N[2024-01-02 00:00:00Z]
    })

    # user without associated salary records
    user_fixture(%{name: "Mike"})
    :ok
  end
end
