# Be sure to restart your server when you modify this file.

cookie_key = "_snakesnack_session_web"

cookie_store_options = {
  key: cookie_key
}

SnakeSnack::Application.config.session_store :cookie_store, cookie_store_options
