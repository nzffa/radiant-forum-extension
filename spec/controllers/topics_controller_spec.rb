require File.dirname(__FILE__) + '/../spec_helper'
Radiant::Config['reader.layout'] = 'Main'

describe TopicsController do
  dataset :forum_sites
  dataset :forum_readers
  dataset :layouts
  dataset :topics

  before do
    controller.stub!(:request).and_return(request)
    controller.set_current_site
  end

  describe "on get to index" do
    before do
      get :index, :forum_id => forum_id(:public)
    end

    it "should redirect to the forum page" do
      response.should be_redirect
      response.should redirect_to(forum_url(forums(:public)))
    end  
  end
    
  describe "on get to show" do
    before do
      @topic = topics(:older)
      get :show, :id => topic_id(:older), :forum_id => forum_id(:public)
    end
    
    it "should render the show template" do
      response.should be_success
      response.should render_template("show")
    end
        
    it "should  show a topic from this site" do
      
    end
    it "should not show a topic from another site" do
      
    end
  end
  
  describe "on get to new" do
    describe "without a logged-in reader" do
      before do
        logout_reader
        get :new, :forum_id => forum_id(:public)
      end
      it "should redirect to login" do
        response.should be_redirect
        response.should redirect_to(reader_login_url)
      end
      it "should store the return address in the session" do
        request.session[:return_to].should == request.request_uri
      end
    end

    describe "with a logged-in reader" do
      before do
        login_as_reader(:normal)
        get :new, :forum_id => forum_id(:public)
      end
      it "should render the new topic form" do
        response.should be_success
        response.should render_template("new")
      end  
    end
  end

  describe "on post to create" do
    describe "without a logged-in reader" do
      before do
        logout_reader
        post :create, :forum_id => forum_id(:public), :topic => {:name => 'another test topic', :body => 'topic body'}
      end
      it "should redirect to login" do
        response.should be_redirect
        response.should redirect_to(reader_login_url)
      end
    end

    describe "with a logged-in reader" do
      before do
        login_as_reader(:normal)
      end
      describe "but an invalid request" do
        before do
          post :create, :forum_id => forum_id(:public), :topic => {:body => 'topic body'}
        end
        it "should rerender the topic form" do
          response.should be_success
          response.should render_template("new")
        end
      end

      describe "and a valid request" do
        before do
          post :create, :forum_id => forum_id(:public), :topic => {:name => 'another test topic', :body => 'topic body'}
          @topic = Topic.find_by_name('another test topic')
        end
        it "should create the topic" do
          @topic.should_not be_nil
          @topic.forum.should == forums(:public)
          @topic.posts.first.should_not be_nil
          @topic.posts.first.body.should == 'topic body'
        end
        it "should assign the topic to the current reader" do
          @topic.reader.should_not be_nil
          @topic.reader.should == readers(:normal)
        end
        it "should redirect to the topic page" do
          response.should be_redirect
          response.should redirect_to(topic_url(@topic.forum, @topic))
        end
      end
    end
    
    describe "on another site" do
      it "should throw a FileNotFound error" do
      
      end
    end
  end



end