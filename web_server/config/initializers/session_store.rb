# Be sure to restart your server when you modify this file.

cookie_key = "_snakes_session"

cookie_store_options = {
  key: cookie_key
}

Snakes::Application.config.session_store :cookie_store, cookie_store_options
