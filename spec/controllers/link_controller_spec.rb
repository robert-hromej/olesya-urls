require "spec_helper"

# todo COMMENTS!
describe LinkController do
  render_views

  describe "get show" do

    it "should redirect if get not existing link" do
      # we must be redirected if link doesn't exist
      get "show", :id => 0
      response.should be_redirect
    end

    describe "existing link" do

      before(:each) do
        # create test link
        @link = Factory(:link)
        # create test user
        @user = User.first
      end

      it "should respond success" do
        # show link page
        get :show, :id => @link.id
        response.should be_success
      end

      it "should show link list" do
        # show show all page
        get :index
        response.should be_success
      end

      it "should not be available for comments without signing in" do
        # show link page
        get :show, :id => @link.id
        # we don't see 'add comment form'
        response.body.should_not have_html_tag("textarea", :id => "comment_body")
      end

      describe "registered user" do

        before(:each) do
          # login under test user
          login @user
          @comment_attr = {:body=>'this_is_the_comment_body', :link_id => @link.id}
          # simulate login from link page
          @request.env['HTTP_REFERER'] = "#{DEFAULT_HOST}link/#{@link.id}"
        end

        it "should be available for comments with signing in" do
          # open link page
          get :show, :id => @link.id
          # verify 'new comment' form
          response.body.should have_html_tag("textarea", :id => "comment_body")
        end

        it "should have paginator" do
          6.times { Comment.create!(@comment_attr.merge(:user_id => @user.id)) }
          get :show, :id => @link.id
          response.body.should have_html_tag('a', :class => "next_page")
        end

        it "should create new link" do
          lambda do
            post :create, :new_link_url => "yandex.ru", :new_link_title => 'title'
          end.should change(Link, :count).by(1)
        end

        it "should not create the same link twice" do
          # try to create two identical links
          2.times { post :create, :new_link_url => "http://google.com", :new_link_title => 'google.com' }
          # after second list we must be redirected to first link page with message
          response.should be_redirect
          get :show, :id => Link.where(:url => "http://google.com").first.id
          response.body.should have_html_tag("span", :content => I18n.t(:link_already_added))
        end
      end
    end
  end
end