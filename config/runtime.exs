import Config
import Dotenvy

source(["#{config_env()}.env", System.get_env()])

# config/runtime.exs is executed for all environments, including
# during releases. It is executed after compilation and before the
# system starts, so it is typically used to load production configuration
# and secrets from environment variables or elsewhere. Do not define
# any compile-time configuration in here, as it won't be applied.
# The block below contains prod specific runtime configuration.

# ## Using releases
#
# If you use `mix release`, you need to explicitly enable the server
# by passing the PHX_SERVER=true when you start it:
#
#     PHX_SERVER=true bin/ombu_oss_notifier start
#
# Alternatively, you can use `mix phx.gen.release` to generate a `bin/server`
# script that automatically sets the env var above.
if System.get_env("PHX_SERVER") do
  config :ombu_oss_notifier, OmbuOssNotifierWeb.Endpoint, server: true
end

case config_env() do
  :prod ->
    database_url =
      System.get_env("DATABASE_URL") ||
        raise """
        environment variable DATABASE_URL is missing.
        For example: ecto://USER:PASS@HOST/DATABASE
        """

    maybe_ipv6 = if System.get_env("ECTO_IPV6"), do: [:inet6], else: []

    config :ombu_oss_notifier, OmbuOssNotifier.Repo,
      # ssl: true,
      url: database_url,
      pool_size: String.to_integer(System.get_env("POOL_SIZE") || "10"),
      socket_options: maybe_ipv6

    # The secret key base is used to sign/encrypt cookies and other secrets.
    # A default value is used in config/dev.exs and config/test.exs but you
    # want to use a different value for prod and you most likely don't want
    # to check this value into version control, so we use an environment
    # variable instead.
    secret_key_base =
      System.get_env("SECRET_KEY_BASE") ||
        raise """
        environment variable SECRET_KEY_BASE is missing.
        You can generate one by calling: mix phx.gen.secret
        """

    host = System.get_env("PHX_HOST") || "example.com"
    port = String.to_integer(System.get_env("PORT") || "4000")

    config :ombu_oss_notifier, OmbuOssNotifierWeb.Endpoint,
      url: [host: host, port: 443, scheme: "https"],
      http: [
        # Enable IPv6 and bind on all interfaces.
        # Set it to  {0, 0, 0, 0, 0, 0, 0, 1} for local network only access.
        # See the documentation on https://hexdocs.pm/plug_cowboy/Plug.Cowboy.html
        # for details about using IPv6 vs IPv4 and loopback vs public addresses.
        ip: {0, 0, 0, 0, 0, 0, 0, 0},
        port: port
      ],
      secret_key_base: secret_key_base

    config :ombu_oss_notifier, slack_api_token: env!("SLACK_API_TOKEN", :string!)
    config :ombu_oss_notifier, channel_id: env!("CHANNEL_ID", :string!)
  :dev ->
    config :ombu_oss_notifier, OmbuOssNotifier.Repo,
      username: env!("DATABASE_USERNAME", :string!),
      password: env!("DATABASE_PASSWORD", :string!),
      hostname: env!("DATABASE_HOST", :string!),
      database: env!("DATABASE_NAME", :string!),
      stacktrace: true,
      show_sensitive_data_on_connection_error: true,
      pool_size: 10
    config :ombu_oss_notifier, slack_api_token: env!("SLACK_API_TOKEN", :string!)
    config :ombu_oss_notifier, channel_id: env!("CHANNEL_ID", :string!)
end
