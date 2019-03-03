defmodule ShortUrlWeb.Router do
  use ShortUrlWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", ShortUrlWeb do
    pipe_through :browser # Use the default browser stack

    resources "/", LinkController, only: [:index, :show, :create]
  end

  scope "/api", ShortUrlWeb.API do
    pipe_through :api

    post "/shorten", LinkController, :shorten
    get "/lengthen", LinkController, :lengthen
  end

  # Other scopes may use custom stacks.
  # scope "/api", ShortUrlWeb do
  #   pipe_through :api
  # end
end
