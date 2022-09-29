defmodule OmbuOssNotifierWeb.Router do
  use OmbuOssNotifierWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api", OmbuOssNotifierWeb do
    pipe_through :api
  end
end
