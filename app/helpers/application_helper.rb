module ApplicationHelper

  def system_messages
    return "" if session[:system_message].blank?
    str = render(:partial => "layouts/sys_messages")
    session[:system_message] = nil
    return str.html_safe
  end

  def link_cache_key(link)
    return "link_id_#{link.id}_author_id_#{link.user_id}_voted_#{controller.current_user != nil ? link.voted : 1}"
  end

  def comment_cache_key(comment)
    return "comment_id_#{comment.id}_author_id_#{comment.user_id}"
  end

end
