def login(user)
  session[:current_user_id] = user.nil? ? Factory(:user, :screen_name => Factory.next(:screen_name)) : user
end

#  <b>==DOCUMENTATION==</b>
#  <b>logs in with twitter to create session</b>
#
#  <b>Usage</b>
#    integration_login
#
#    note you can add parameters when using this function to login by other user
def integration_login(options = nil)
  visit root_path
  click_link LOGIN_BUTTON
  fill_in TWITTER_LOGIN_FIELD, :with => options.nil? ? TWITTER_CREDENTIALS[:login] : options[:login]
  fill_in TWITTER_PASSWORD_FIELD, :with => options.nil? ? TWITTER_CREDENTIALS[:pass] : options[:pass]
  click_button ALLOW_BUTTON
  #visit root_path
  sleep 20
  click_link LOGOUT_BUTTON
end

#  <b>==DOCUMENTATION==</b>
#  <b>creates new link</b>
#
#  <b>Usage</b>
#    create_link(:title=>'new_link_title', :url=>'http://valid_url')
#    create_link(:test=>false, :title=>'new_link_title', :url=>'http://valid_url')
#
#    parameter [test] must be false to add new link if it already exists
def create_link(options = {})
  test = !(options[:test].nil? ? true : options[:test])
  visit root_path
  if ((!page.html.has_html_tag?(:a, :class => 'title_link', :content => options[:title], :print => false)) || test)
    page.should have_selector('a#add_link')
    click_link ADD_LINK_BUTTON
    fill_in NEW_LINK_TITLE_FIELD, :with => options[:title]
    fill_in NEW_LINK_URL_FIELD, :with => options[:url]
    click_button CREATE_LINK_BUTTON
  end
end
