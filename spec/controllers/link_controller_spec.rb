require "spec_helper"
describe LinkController do
  render_views

  describe "get show" do

    it "should redirect if get not existing link" do
      get "show", :id => 1
      response.should be_redirect
    end

    describe "existing link" do

      before(:each) do
        @link = Factory(:link)
        @user = User.first
      end

      it "should respond success" do
        get :show, :id => @link.id
        response.should be_success
      end

      it "should show link list" do
        get :list
        response.should be_success
      end

      it "should not be available for comments without signing in" do
        get :show, :id => @link.id
        response.should_not have_selector("textarea#comment_body")
      end

      describe "registered user" do

        before(:each) do
          login @user
          @comment_attr = {:user_id=>'1', :body=>'this_is_the_comment_body', :link_id=>@link.id}
          @request.env['HTTP_REFERER'] = "#{DEFAULT_HOST}link/show/#{@link.id}"
        end

        it "should be available for comments with signing in" do
          get :show, :id => @link.id
          response.should have_selector("textarea#comment_body")
        end

        it "should create comment" do
          post :comment, :comment => @comment_attr
          response.should have_selector(:a, :href=>"#{DEFAULT_HOST}link/show/#{@link.id}")
        end

        it "(comment) should appear in the db" do
          lambda do
            post :comment, :comment=>@comment_attr
          end.should change(Comment, :count).by(1)
        end

        it "should have paginator" do
          6.times { Comment.create!(@comment_attr.merge(:user_id=>@user.id)) }
          get :show, :id=>@link.id
          response.should have_selector(:a, :class=>"next_page")
        end

        it "should add vote to the db" do
          lambda do
            post :vote, :kind=>1, :link_id=>@link.id
          end.should change(Vote, :count).by(1)
        end

        it "should create new link" do
          lambda do
            post :create, :new_link_url => "this_is_new_link.com", :new_link_title => 'title'
          end.should change(Link, :count).by(1)
        end

        it "should not create the same link twice" do
          2.times { post :create, :new_link_url => "this_is_new_link.com", :new_link_title => 'title' }
          response.should be_redirect
          get :show, :id => @link.id
          response.should have_selector(:span, :content=>'Link with such URL is already added')
        end
      end
    end
  end
end