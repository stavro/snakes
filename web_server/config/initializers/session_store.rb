# Be sure to restart your server when you modify this file.

domain_map = {
  'development' => '.snakesnack.dev',
  'production' => '.herokuapp.com',
  'staging'    => '.herokuapp.com'
}

cookie_key = "_snakesnack_session"

custom_domain = domain_map[Rails.env].presence || nil

cookie_store_options = {
  key: cookie_key,
  domain: custom_domain,
}

SnakeSnack::Application.config.session_store :cookie_store, cookie_store_options
