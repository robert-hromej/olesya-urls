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

  def vote kind, link
    k = (kind == :up ? 1 : -1)
    c = (kind == :up ? "Plus" : "Minus")

    fields = ""
    fields << hidden_field_tag("link_id", link.id)
    fields << hidden_field_tag("kind", k)
    fields << submit_tag("", {:class => c})

    html = form_for(Vote.new, :url => "/link/vote", :method=>"post", :remote => true) { fields.html_safe }

    return html
  end


end
