module LinkHelper
  def link_full_url link
    this_link_url = "http://" + request.host
    this_link_url << ":#{request.port}" if request.port != 80
    this_link_url << link_path(link.id)
    this_link_url
  end
end
