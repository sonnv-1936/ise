module ApplicationHelper
  def check_noty_type type
    noty_types = %w(alert success warning error info)

    return type if noty_types.any? {|n| n == type}
    noty_types[0]
  end

  def user_image_for user, css_class
    return fa_icon "user-circle" unless user.avatar&.file?
    image_tag user.avatar.file_url, class: css_class
  end

  def rescue_body_class
    return unless check_registration_edit_update_action
    "content #{cookies[:sidebarCollapse]}"
  end

  def check_registration_edit_update_action
    !devise_controller? ||
      edit_user_registration_path == request.original_fullpath ||
      user_registration_path == request.original_fullpath
  end

  def rescue_locale_css locale
    return "button button-text" if locale == I18n.locale
    "btn button-text-default"
  end
end
