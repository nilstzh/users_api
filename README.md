# Users API

This repo contains a Phoenix API application example.

## Features

1. **User and Salary Storage**: A PostgreSQL database stores user profiles and their associated salaries.
2. **User Details**: Each user has a required `name` field and supports linking to multiple salary records.
3. **Salary Details**: Each salary has a required `currency`, `amount` and `state` fields.
4. **Single Active Salary Constraint**: Users can have only one active salary at any time.
6. **JSON Responses**: All API endpoints return data in JSON format.

## Setup

### Prerequisites
```
elixir          1.17.2-otp-27
erlang          27.0.1

postgres
```

### Installation

1. Install the dependencies and setup the database:

```sh
asdf install

mix deps.get
mix setup
```

This will:

- Install dependencies
- Setup the database
- Seed the database with 20k users and 40k salaries (2 salaries per user)

2. Start the Phoenix server:

```sh
mix phx.server
```

3. Access the application at http://localhost:4000.

## Database schema

### `users` table

Table Structure:
- **id**: Primary key (UUID) automatically generated.
- **name**: A string representing the user's name (cannot be null).
- **timestamps**: Includes `inserted_at` and `updated_at` timestamps.

### `salaries` table

Table Structure:
- **id**: Primary key (UUID) automatically generated.
- **amount**: The salary amount, stored as an integer (cannot be null).
- **currency**: A string representing the currency of the salary (cannot be null).
- **state**: A string representing the state of the salary (cannot be null). A salary can be either `active` or `inactive`.
- **active_since**: A timestamp indicating when the salary became active.
- **user_id**: Foreign key referencing the users table, indicating which user the salary belongs to (cannot be null).
- **timestamps**: Includes `inserted_at` and `updated_at` timestamps.

### Indexes

- An index on the `user_id` in the `salaries` table improves query performance when fetching salaries for a specific user.
- A unique index on the `user_id` and `state` ensures that each user can have only one active salary at any given time.

## Endpoints

The application exposes two primary API endpoints to interact with the *users* and *salaries*. These endpoints support the following operations:

- `GET /api/users` - Retrieve a list of users along with their active salaries.
- `POST /api/invite-users` - Send an email to all users with active salaries.

### `GET /api/users`

This endpoint retrieves a list of users and their salaries.

The **response** includes a list of objects with the following fields
- `name`: String - the user's name,
- `salary`: Object - details of the user's active (or the most recently active) salary (*the most recently active salary* is identified by the most recent `active_since` timestamp)
  - `amount`: Integer,
  - `currency`: String,
  - `state`: String.

#### Query Parameters

- `name` (optional): Filters users by partial name match. The results will include all users whose names match the query string (case-insensitive). If no user with matching name is found, an empty list is returned.

- Any other query parameters are ignored.

#### Examples

##### Basic usage

Request:
```sh
curl http://localhost:4000/api/users
```

Response:
```json
[
  {
    "name": "John",
    "salary": {"amount": 2000, "currency": "EUR", "state": "active"}
  },
  {
    "name": "Satomi",
    "salary": {"amount": 2000, "currency": "EUR", "state": "inactive"}
  },
  {
    "name": "Tom",
    "salary": {"amount": 2000, "currency": "EUR", "state": "active"}
  }
]
```

##### Searching by name

Request:
```sh
curl http://localhost:4000/api/users?name=Tom
```

Response:
```json
[
  {
    "name": "Satomi",
    "salary": {"amount": 2000, "currency": "EUR", "state": "inactive"}
  },
  {
    "name": "Tom",
    "salary": {"amount": 2000, "currency": "EUR", "state": "active"}
  }
]
```

### `POST /api/invite-users`

This endpoint sends an email invitation to all users with an active salary. The sending of emails is simulated using the [Remote’s Challenge lib](https://github.com/remotecom/be_challengex).

The **response** includes
- `errors`: Array - list of errors,
- `status`: String - response status,
- `succesfully_sent`: Integer - namber of successfully sent emails

#### Example

Request:
```sh
curl http://localhost:4000/api/invite-users
```

Response:
```json
{
  "errors": [],
  "status": "success",
  "succesfully_sent": 2
}
```

---

## Implementation details

### Configuration

- Primary key defaults set to UUID. For uniqness and security reasons I believe that UUID is a better choice for production systems in the most cases.
- Mox dependency added for tests. To test parts communicating with the outside world (in this particular case Mailer) I used Mox library.

### Functionality

- `active_since` column in the `salaries` table is used to identify the most recently active salary, it is meant to be updated any time a salary `state` is set to `active` (with create or update).
- The `Mailer` module implements a mechanism to retry email sending if error occurs. The default retry limit is set to 3 attempts.
- Unsuccessful attempts to send an email are logged to provide feedback.
- Only one active salary per user limit is enforced on a DB level with a unique index.
- Any unexpected parameters in requests are ignored.

### Improvement areas

1. Mailer is currently simulates sending emails with `simulate_email_service/1` function. It handles well the responses this function provides. However to handle real-world email sending it would need **better error handling** mechanism for different kinds of possible cases.

2. Current application doesn't implement any **pagination**. To handle more data pagination would be necessary to improve performance and reduce memory usage. If I would have to implement it, I would use cursor-based pagination (probably based on `name`, to preserve sorting, and `inserted_at` as a tie-breaker, since `name` is not unique).

3. `/api/invite-users` endpoint response is currently synchronous and takes a few seconds. With bigger dataset this would be an issue. To resolve this, we could respond with success to the request and **handle sending emails asynchronously**. In this case some way to check the result of the action later would have to be implemented.

4. If this app would need to scale or handle high traffic, **caching** could be considered for common queries like fetching users.
