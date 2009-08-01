require_dependency 'application_controller'
# require 'will_paginate'

class ForumExtension < Radiant::Extension
  version "0.2"
  description "Simple forums and page comments for inclusion in your radiant site. Derived long ago from beast. Requires the reader extension and share_layouts."
  url "http://spanner.org/radiant/forum"

  define_routes do |map|
    map.resources :forums do |forum|
      forum.resources :topics, :name_prefix => nil do |topic|
        topic.resources :posts, :name_prefix => nil
        topic.resource :monitorship, :controller => :monitorships, :name_prefix => nil
      end
    end
    
    map.namespace :admin, :member => { :remove => :get } do |admin|
      admin.resources :forums
      # admin.resources :topics   for moderation
    end

    %w(reader forum page).each do |attr|
      map.resources :posts, :name_prefix => "#{attr}_", :path_prefix => "/#{attr.pluralize}/:#{attr}_id", :collection => 'preview'
    end

    map.with_options :controller => 'topics' do |topics|
      topics.topics_list '/topics', :action => 'index'
      topics.topics_feed '/topics/feed', :action => 'index', :format => 'rss'
      topics.new_topic_somewhere '/topics/new', :action => 'new'
      topics.create_topic_somewhere '/topics/create', :action => 'create', :method => :post
    end

    map.with_options :controller => 'posts' do |posts|
      posts.posts_monitored '/posts/monitored', :action => 'monitored'
      posts.posts_feed '/posts/feed', :action => 'index', :format => 'rss'
      posts.posts_list '/posts', :action => 'index'
    end
  end
  
  def activate
    Reader.send :include, ForumReader
    ReaderNotifier.send :include, ForumReaderNotifier
    ReadersController.send :include, ForumReadersController
    Page.send :include, ForumPage
    UserActionObserver.instance.send :add_observer!, Forum
    UserActionObserver.instance.send :add_observer!, Topic
    UserActionObserver.instance.send :add_observer!, Post
 
    Page.send :include, ForumTags
    
    unless defined? admin.forum # UI is a singleton and already loaded
      Radiant::AdminUI.send :include, ForumAdminUI
      admin.forum = Radiant::AdminUI.load_default_forum_regions
      admin.pages.edit.add :parts_bottom, "edit_commentability", :after => "edit_layout_and_type"
      if defined? Site && admin.sites       # currently we know it's the spanner multi_site if admin.sites is defined
        Site.send :include, ForumSite
        admin.sites.edit.add :form, "admin/sites/choose_forum_layout", :after => "edit_homepage"
      end
    end
    
    if defined? RedCloth::DEFAULT_RULES
      RedCloth.send :include, ForumRedCloth3
      RedCloth::DEFAULT_RULES.push(:smilies)
    else
      RedCloth::TextileDoc.send :include, ForumRedCloth4
    end
    
    ApplicationHelper.send :include, ForumHelper

    ActiveSupport::CoreExtensions::Time::Conversions::DATE_FORMATS.merge!( 
      :informal => %{%B %d %Y at %H:%M},
      :html_date => %{<span class="date">%e %b %Y</span> at <span class="time">%l:%M</span><span class="meridian">%p</span>},
      :short_time => %{%l:%M<span class="meridian">%p</span>}
    )

    if defined? ActiveRecord::SiteNotFound
      admin.forums.index.add :top, "admin/shared/site_jumper"
    end
    admin.tabs.add "Forum", "/admin/forums", :after => "Readers", :visibility => [:all]
  end
  
  def deactivate
    admin.tabs.remove "Forum"
  end
  
end

