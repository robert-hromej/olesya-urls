module ApplicationHelper
  def system_messages
    if not session[:system_message]
      return ""
    end

    str = session[:system_message].clone
    session[:system_message] = ""

    str.html_safe
  end

  def day_of_week(date)
    days = ['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday']
    result = days[date.wday]
  end

  def month(date)
    months = ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December']
    result = months[date.month-1]
  end

  def link_cache_key(link)
    return "link_id_#{link.id}_author_id_#{link.user_id}_voted_#{controller.current_user != nil ? link.voted : 1}"
  end

  def comment_cache_key(comment)
    return "comment_id_#{comment.id}_author_id_#{comment.user_id}"
  end

end
