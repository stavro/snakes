module ApplicationHelper

  def omniauth_authorize_path(resource_name, provider)
    send "#{resource_name}_omniauth_authorize_path", provider
  end

  def user_id_tag
    tag('meta', :name => 'user_id', :content => current_user && current_user.id || "").html_safe
  end

  def user_id_hash_tag
    tag('meta', :name => 'user_id_hash', :content => current_user && current_user.user_id_hash || "").html_safe
  end

end
