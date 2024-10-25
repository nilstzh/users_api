defmodule UsersApi.UsersTest do
  use UsersApi.DataCase
  import UsersApi.SetupHelpers

  alias UsersApi.{Salary, Users}

  setup [:prepare_users]

  describe "list_users_salaries/1" do
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
end
