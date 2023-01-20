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
    config :ombu_oss_notifier, slack_api_token: env!("SLACK_API_TOKEN", :string!)
    config :ombu_oss_notifier, channel_id: env!("CHANNEL_ID", :string!)

  :dev ->
    config :ombu_oss_notifier, slack_api_token: env!("SLACK_API_TOKEN", :string!)
    config :ombu_oss_notifier, channel_id: env!("CHANNEL_ID", :string!)
end
