module ForumReaderHelperExtension
  def self.included(base)
    base.class_eval do
      
      def standard_gravatar_for(reader=nil, url=nil)
        size = Radiant::Config['reader.gravatar_size'] || 40
        url ||= reader_url(reader)
        gravatar = gravatar_for(reader, {:size => size}, {:class => 'gravatar offset', :width => size, :height => size})
        # This is why this is here; https://github.com/nzffa/radiant-forum-extension/commit/08779fc303cfce581c55e3b052d5d642fb0a2cc5
        content = (url == :false ? gravatar : link_to(gravatar, url))
        content_tag(:div, content, :class => "speaker", :width => size, :height => size)
      end
      
    end
  end
  
  
end