module ApplicationHelper

  def display_game?
    current_user || session[:guest_id]
  end

  def omniauth_authorize_path(resource_name, provider)
    send "#{resource_name}_omniauth_authorize_path", provider
  end

  def user_id_tag
    if display_game?
      tag('meta', :name => 'user_id', :content => current_user && current_user.id || session[:guest_id]).html_safe
    end
  end

  def user_id_hash_tag
    if display_game?
      tag('meta', :name => 'user_id_hash', :content => current_user && current_user.user_id_hash || User.guest_user_id_hash(session[:guest_id])).html_safe
    end
  end

  def game_server_host_tag
    if Rails.env.production?
      host = "snakesnack-game.herokuapp.com"
    else
      host = "localhost:1234"
    end

    tag('meta', :name => 'game_server_host', :content => host).html_safe
  end

end
