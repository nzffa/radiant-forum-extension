class TopicsController < ReaderActionController
  
  before_filter :find_forum_and_topic, :except => :index

  def index
    params[:per_page] ||= 20
    @topics = Topic.paginate(:all, :order => "topics.sticky desc, topics.replied_at desc", :page => params[:page] || 1, :per_page => params[:per_page], :include => [:forum, :reader])
    render_page_or_feed
  end

  def new
    @topic = Topic.new
  end
  
  def show
    @topic.hit! unless current_reader and @topic.reader == current_reader
    params[:per_page] ||= 20
    params[:page] = 1 if params[:page] == 'first'
    params[:page] = (@topic.posts.count.to_f / params[:per_page].to_f).ceil if params[:page] == 'last'
    @posts = Post.paginate_by_topic_id(@topic.id, :page => params[:page], :per_page => params[:per_page], :include => :reader, :order => 'posts.created_at asc')
    render_page_or_feed(@topic.page ? 'comments' : 'show')
  end
  
  def create
    # post creation is handled by a before_create in the topic model
    # and then calls back to set initial reply data in the topic
    @forum = Forum.find(params[:topic][:forum_id]) if params[:topic][:forum_id]
    @topic = @forum.topics.create!(params[:topic])
    respond_to do |format|
      format.html { redirect_to forum_topic_path(@forum, @topic) }
    end
  rescue ActiveRecord::RecordInvalid => invalid
    flash[:error] = "Sorry: #{invalid}. Please check the form"
    respond_to do |format|
      format.html { render :action => 'new' }
    end
  end
  
  def update
    # post update is handled by a before_update in the topic model
    @topic.attributes = params[:topic]
    @topic.save!
    respond_to do |format|
      format.html { redirect_to forum_topic_path(@forum, @topic) }
    end
  end
  
  def destroy
    @topic.destroy
    flash[:notice] = "Topic '{name}' was deleted."[:topic_deleted_message, CGI::escapeHTML(@topic.name)]
    respond_to do |format|
      format.html { redirect_to forum_path(@forum) }
    end
  end
  
  protected

    def find_forum_and_topic
      @topic = Topic.find(params[:id]) if params[:id]
      @page = @topic.page if @topic
      @forum = @topic.forum if @topic
      @forum ||= Forum.find(params[:forum_id]) if params[:forum_id]
    end
    
end
