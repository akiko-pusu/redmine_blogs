#require 'tag'
class BlogsController < ApplicationController
  unloadable

  helper :attachments
  include AttachmentsHelper


  before_filter :find_blog, :except => [:new, :index, :preview, :show_by_tag, :get_tag_list, :show_all_tags]
  before_filter :find_user, :only => [:index]

  # get project information from path & parameter "project_id"
  before_filter :find_optional_project, :only => [:show_by_tag, :get_tag_list, :new, :edit, :show, :destroy, :add_comment, :show_all_tags]
  before_filter :find_project, :only => [:index, :preview]
  before_filter :authorize, :except => [:preview]

  # Enabled Feed when using key
  accept_key_auth :index, :show_by_tag
 

  def index
    find_project

    	@blogs_pages, @blogs = paginate :blogs,
      	    :per_page => 10,
      	    :conditions => (@user ? ["author_id = ? and project_id = ?", 
                       @user, @project] : ["project_id = ?", @project]),
      	    :include => [:author,:project],
      	    :order => "#{Blog.table_name}.created_on DESC"
        respond_to do |format|
            format.html { render :layout => false if request.xhr? }
            format.atom { render_feed(@blogs, :title => "#{Setting.app_title}: Blogs") }
	    format.rss  { render_feed(@blogs, :title => "#{Setting.app_title}: Blogs", :format => 'rss' ) }
        end
  end

  def show_by_tag
      find_optional_project
      @blogs_pages, @blogs = paginate :blogs,
          :per_page => 10,
          :conditions => ["#{Tag.table_name}.name = ? and project_id = ?", params[:id], @project], 
          :include => [:author,:tags,:project],
          :order => "#{Blog.table_name}.created_on DESC"
      respond_to do |format|
          format.html { render :action => 'index', :layout => !request.xhr? }
          format.atom { render_feed(@blogs, :title => "#{Setting.app_title}: Blogs") }
      end
  end
	
  def show
      @comments = @blog.comments
      @comments.reverse! if User.current.wants_comments_in_reverse_order?
  end

  def new
      find_optional_project
      @blog = Blog.new(:author => User.current, :project => @project)
      if request.post?
          @blog.attributes = params[:blog]
          if @blog.save
              defined?(attach_files) ? attach_files(@blog, params[:attachments]) : Attachment.attach_files(@blog, params[:attachments])
              #Attachment.attach_files(@blog, params[:attachments])
              flash[:notice] = l(:notice_successful_create)
              # Mailer.deliver_blog_added(@blog) if Setting.notified_events.include?('blog_added')
              redirect_to :controller => 'blogs', :action => "index",:project_id => @project
          end
      end
  end

  def edit
      find_optional_project
      render_403 if User.current != @blog.author
      if request.post? and @blog.update_attributes(params[:blog])
          if defined?(attach_files)
             attachments = attach_files(@blog, params[:attachments])
          else 
             attachments = Attachment.attach_files(@blog, params[:attachments])
          end      
          flash[:notice] = l(:notice_successful_update)
      end
      redirect_to :controller => 'blogs', :action => "show",:id => @blog, :project_id => @project
  end

  def show_all_tags
      find_optional_project
      respond_to do |format|
          format.html { render :template => 'blogs/show_all_tags.rhtml' }
      end
  end

  def add_comment
      find_optional_project
      @comment = Comment.new(params[:comment])
      @comment.author = User.current
      if @blog.comments << @comment
          flash[:notice] = l(:label_comment_added)
          redirect_to :controller => 'blogs', :action => "show",:id => @blog, :project_id => @project
      else
          render :action => 'show'
      end
  end

  def destroy_comment
      @blog.comments.find(params[:comment_id]).destroy
      redirect_to :action => 'show', :id => @blog
  end

  def destroy
      find_optional_project
      render_403 if User.current != @blog.author
      @blog.destroy
      redirect_to :action => 'index',:project_id => @project
  end

  def preview
      find_project
      @text = (params[:blog] ? params[:blog][:description] : nil)
      @blog = Blog.find(params[:id]) if params[:id]
		@attachements = @blog.attachments if @blog
      render :partial => 'common/preview'
  end
	

  def get_tag_list
      render :text => Tag.find(:all) * ","
      return
  end

private
  def find_blog
      @blog = Blog.find(params[:id])
      @project = @blog.project
      rescue ActiveRecord::RecordNotFound
      render_404
  end

  def find_user
      @user = User.find(params[:id]) if params[:id]
      rescue ActiveRecord::RecordNotFound
      render_404
  end

  def find_optional_project
      @project = Project.find(params[:project_id]) unless params[:project_id].blank?
      allowed = User.current.allowed_to?({:controller => params[:controller], :action => params[:action]}, @project, :global => true)
      allowed ? true : deny_access

      rescue ActiveRecord::RecordNotFound
      render_404
  end

 
  def find_project
      @project = Project.find(params[:project_id])
      rescue ActiveRecord::RecordNotFound
      render_404
  end
end
