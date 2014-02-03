module Shared
  class User
    include Mongoid::Document

    field :name, type: String
    field :email, type: String
    field :encrypted_password, type: String
    field :reset_password_token, type:String
    field :reset_password_sent_at, type:DateTime
    field :remember_created_at, type:DateTime
    field :sign_in_count, type:Integer
    field :current_sign_in_at, type:DateTime
    field :last_sign_in_at, type:DateTime
    field :current_sign_in_ip, type:String
    field :last_sign_in_ip, type:String
    field :created_at, type:DateTime
    field :updated_at, type:DateTime

    field :facebook_uid, type:String
    field :first_name, type:String
    field :last_name, type:String
    field :image_url, type:String
    field :rank, type:Integer
    field :location, type:String
    field :wins, type:Integer, default: 0
    field :losses, type:Integer, default: 0

    def self.encryption_key
      ENV["ENCRYPTION_SECRET_KEY"] || 'secret'
    end

    def self.from_encrypted_id(encrypted_id)
      encrypted_id = Base64.decode64(encrypted_id)
      id = Encryptor.decrypt(encrypted_id, :key => encryption_key) rescue nil
      id && User.find(id)
    end

    def user_id_hash
      Base64.encode64(Encryptor.encrypt(id.to_s, :key => ENV['ENCRYPTION_SECRET_KEY'])).chomp
    end
    
  end
end
