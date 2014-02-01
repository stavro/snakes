class User < Shared::User
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  devise :omniauthable, :omniauth_providers => [:facebook]

  def self.find_for_facebook_oauth(auth)
    user = find_or_create_by(facebook_uid: auth.uid) do |user|
      user.email = auth.info.email
      user.password = Devise.friendly_token[0,20]
      user.first_name = auth.info.first_name   # assuming the user model has a name
      user.last_name = auth.info.last_name   # assuming the user model has a name
      user.image_url = auth.info.image # assuming the user model has an image
      user.location = auth.info.location
    end
  end
end

# {"provider"=>"facebook",
#  "uid"=>"6411701",
#  "info"=>
#   {"nickname"=>"sean.stavro",
#    "email"=>"sean.stavro@gmail.com",
#    "name"=>"Sean Stavropoulos",
#    "first_name"=>"Sean",
#    "last_name"=>"Stavropoulos",
#    "image"=>"http://graph.facebook.com/6411701/picture",
#    "urls"=>{"Facebook"=>"https://www.facebook.com/sean.stavro"},
#    "location"=>"Los Angeles, California",
#    "verified"=>true},
#  "credentials"=>
#   {"token"=>
#     "CAAIOMevKZBsQBAOZALeXwwExP6edWrG2crpObofncz9ITdutBduLGGwEPFfG9GgPneZAfA49KbRSIuACkw49xlHRpEUxKeWSdPsoBAeN0BhBBx2e9rIM1SreNl2CcZA1DulSWX1DpUieZAuQq9Hd8BeKcq9YMXD3ETMI59D0v33Ok1xUL5ZA5v",
#    "expires_at"=>1396381796,
#    "expires"=>true},
#  "extra"=>
#   {"raw_info"=>
#     {"id"=>"6411701",
#      "name"=>"Sean Stavropoulos",
#      "first_name"=>"Sean",
#      "last_name"=>"Stavropoulos",
#      "link"=>"https://www.facebook.com/sean.stavro",
#      "hometown"=>{"id"=>"109327015753865", "name"=>"Moorpark, California"},
#      "location"=>{"id"=>"110970792260960", "name"=>"Los Angeles, California"},
#      "quotes"=>
#       "Faith is a device of self-delusion, a sleight of hand done with words and emotions founded on any irrational notion that can be dreamed up. Faith is the attempt to coerce truth to surrender to whim. In simple terms, it is trying to breathe life into a lie by trying to outshine reality with the beauty of wishes. Faith is the refuge of fools, the ignorant, and the deluded, not of thinking, rational men. -Terry Goodkind\r\n\r\nGravity is not responsible for two people falling in love. - Einstein. \r\n\r\nWomen might be able to fake an orgasm for a relationship... but Men are able to fake a whole relationship just to have an orgasm! -Matt",
#      "gender"=>"male",
#      "email"=>"sean.stavro@gmail.com",
#      "timezone"=>-8,
#      "locale"=>"en_US",
#      "verified"=>true,
#      "updated_time"=>"2013-12-20T21:53:24+0000",
#      "username"=>"sean.stavro"}}}