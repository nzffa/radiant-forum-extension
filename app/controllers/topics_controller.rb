class TopicsController < ForumBaseController

  def index
    @topics = Topic.visible_to(current_reader).bydate.paginate(pagination_parameters)
    render_page_or_feed
  end

  def show
    @topic = Topic.visible_to(current_reader).find(params[:id])
    @forum = @topic.forum
    @posts = @topic.replies.reverse
    @posts.unshift(@posts.pop) # because the oldest post is the topic, the others are rendered new to old 
    render_page_or_feed
  end

end
