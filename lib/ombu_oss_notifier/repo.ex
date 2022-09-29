defmodule OmbuOssNotifier.Repo do
  use Ecto.Repo,
    otp_app: :ombu_oss_notifier,
    adapter: Ecto.Adapters.Postgres
end
