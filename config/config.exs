# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# General application configuration
config :short_url,
  ecto_repos: [ShortUrl.Repo]

# Configures the endpoint
config :short_url, ShortUrlWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "vzYVBifbG4UDiX+XqzSESlBHDPqgCAxMbywVF+phMCrBq1/k1fhobUoGqU5SiaZC",
  render_errors: [view: ShortUrlWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: ShortUrl.PubSub,
           adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"
