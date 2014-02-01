Rails.application.config.middleware.use OmniAuth::Builder do
  provider :facebook, ENV['SNAKESNACK_FB_APP_ID'], ENV['SNAKESNACK_FB_APP_SECRET'],
           :display => 'popup'
end