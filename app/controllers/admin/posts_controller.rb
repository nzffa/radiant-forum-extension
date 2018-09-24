class Admin::PostsController < Admin::ResourceController
  helper :forum
  paginate_models
  before_filter :flatten_attachments_params, :only => [:create, :update]
  only_allow_access_to :index, :show, :new, :create, :edit, :update, :remove, :destroy,
    :when => :admin,
    :denied_url => { :controller => 'pages', :action => 'index' },
    :denied_message => 'You must be an administrator to edit posts.'

  def flatten_attachments_params
    if attachments = params[:post].delete(:attachments_attributes)
      params[:post][:attachments_attributes] = {}
      counter = 0
      attachments.to_a.each do |i, att_fields|
        if att_fields[:file]
          att_fields[:file].each do |uploaded|
            params[:post][:attachments_attributes][counter.to_s.to_sym] = {}
            params[:post][:attachments_attributes][counter.to_s.to_sym][:file] = uploaded
            counter+=1
          end
        elsif att_fields[:_destroy]
          params[:post][:attachments_attributes][counter.to_s.to_sym] = {}
          params[:post][:attachments_attributes][counter.to_s.to_sym][:_destroy] = attachments[i][:_destroy]
          params[:post][:attachments_attributes][counter.to_s.to_sym][:id] = attachments[i][:id]
          counter+=1
        end
      end
    end
  end
end
