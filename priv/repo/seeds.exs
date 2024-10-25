defmodule UsersApi.Seeds do
  alias UsersApi.Repo
  alias UsersApi.{User, Salary}

  @total_users 20_000
  @batch_size 1000

  def run() do
    batches = 1..div(@total_users, @batch_size)

    Enum.each(batches, fn _batch ->
      timestamp = NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second)

      {_, users} =
        Repo.insert_all(User, generate_user_data(timestamp), returning: [:id])

      Repo.insert_all(Salary, generate_salaries_data(users, timestamp))
    end)
  end

  defp generate_user_data(timestamp) do
    Enum.map(1..@batch_size, fn _ ->
      %{
        name: random_name(),
        inserted_at: timestamp,
        updated_at: timestamp
      }
    end)
  end

  defp generate_salaries_data(users, timestamp) do
    Enum.reduce(users, [], fn user, salaries ->
      [
        %{
          active_since: NaiveDateTime.add(timestamp, 1, :second),
          amount: Enum.random(100..2000) * 10,
          currency: Enum.random(Salary.currencies()),
          state: :inactive,
          user_id: user.id,
          inserted_at: timestamp,
          updated_at: timestamp
        },
        %{
          active_since: NaiveDateTime.add(timestamp, 2, :second),
          amount: Enum.random(100..2000) * 10,
          currency: Enum.random(Salary.currencies()),
          state: Enum.random(Salary.states()),
          user_id: user.id,
          inserted_at: timestamp,
          updated_at: timestamp
        }
        | salaries
      ]
    end)
  end

  defp random_name() do
    names()
    |> Enum.take_random(3)
    |> Enum.join(" ")
  end

  defp names() do
    [File.cwd!(), "priv", "data", "names.txt"]
    |> Path.join()
    |> File.read!()
    |> String.split("\n")
  end
end

UsersApi.Seeds.run()
