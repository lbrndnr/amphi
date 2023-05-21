defmodule Amphi.Repo do
  use Ecto.Repo,
    otp_app: :amphi,
    adapter: Ecto.Adapters.Postgres
end
