require File.dirname(__FILE__) + '/../spec_helper'

describe Post do
  dataset :posts
  dataset :forum_readers
  
  before do
    @site = Page.current_site = sites(:test) if defined? Site
    @reader = Reader.current = readers(:normal)
  end
  
  describe "on creation" do
  
    it "should require a topic" do
      post = Post.new(:body => 'hullabaloo')
      post.should_not be_valid
    end
    
    it "should require body text" do
      post = topics(:older).posts.build(:body => nil)
      post.should_not be_valid
    end

    it "should get a reader automatically" do
      post = topics(:older).posts.build(:body => 'authorless')
      post.should be_valid
      post.reader.should == @reader
    end
    
    it "should update topic reply data" do
      post = topics(:older).posts.create!(:body => 'hullabaloo')
      topic = Topic.find(topic_id(:older))
      topic.last_post.should == post
      topic.replied_by.should == @reader
      topic.replied_at.should be_close(Time.now, 5.seconds)
    end
    
    it "should remain editable only for a configurable period" do
      Radiant::Config['forum.editable_period'] = 15
      post = topics(:older).posts.create!(:body => 'foo')
      post.still_editable?.should be_true
      post.created_at = Time.now - 14.minutes
      post.still_editable?.should be_true
      post.created_at = Time.now - 16.minutes
      post.still_editable?.should be_false
    end

    it "should be editable only by its author" do 
      Radiant::Config['forum.editable_period'] = 15
      post = topics(:older).posts.create!(:body => 'bar')
      post.editable_by?(post.reader).should be_true
      post.editable_by?(readers(:idle)).should be_false
    end

    it "should remain editable by an administrator" do 
      Radiant::Config['forum.editable_period'] = 15
      post = topics(:older).posts.create!(:body => 'baz')
      post.editable_by?(readers(:admin)).should be_true
      post.created_at = Time.now - 16.minutes
      post.editable_by?(readers(:admin)).should be_true
    end
  end

  describe "on removal" do
    it "should revert topic reply data" do
      topicbefore = topics(:older)
      last = topicbefore.last_post
      post = topicbefore.posts.create!(:body => 'uh oh')

      post.destroy
      topicafter = Topic.find(topic_id(:older))
      topicafter.last_post.should == last
      topicafter.replied_by.should == last.reader
      topicafter.replied_at.should == last.created_at
    end
  end
  
  it "should report on which page of its topic it can be found" do
    
  end

end
