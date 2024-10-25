defmodule UsersApi.SetupHelpers do
  import UsersApi.Fixtures

  def prepare_users(_context) do
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
