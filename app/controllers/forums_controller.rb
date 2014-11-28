class ForumsController < ForumBaseController
  
  def index
    @forums = Forum.visible_to(current_reader).all
    render_page_or_feed
  end

  def show
    @forum = Forum.visible_to(current_reader).find(params[:id])
    @topics = @forum.topics.stickyfirst.paginate(pagination_parameters.merge(:per_page => Radiant.config['forum.posts_per_page']))
    render_page_or_feed
  end
  
end
