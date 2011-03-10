require 'redmine'

Dir[File.join(directory,'vendor','plugins','*')].each do |dir|
  path = File.join(dir, 'lib')
  $LOAD_PATH << path
  ActiveSupport::Dependencies.load_paths << path
  ActiveSupport::Dependencies.load_once_paths.delete(path)
end
# see http://www.redmine.org/issues/show/783#note-7
#require_dependency "#{RAILS_ROOT}/vendor/plugins/redmine_blogs/project_patch"
require_dependency 'acts_as_taggable'
require_dependency 'application_helper_global_patch'
require_dependency 'comment_patch'
require 'blog'

Redmine::Plugin.register :redmine_blogs do
  name 'Redmine Blogs plugin'
  author 'A. Chaika'
  description 'Redmine Blog engine [froked from Kyanh version]'
  version '0.1.0'

  project_module :blogs do
  permission :manage_blogs, :blogs => [:new, :delete, :edit, :destroy_comment, :destroy]
  permission :comment_blogs, :blogs => :add_comment
  permission :view_blogs, :blogs => [:index, :show, :show_by_tag, :history, :show_all_tags]
  #permission :view_blogs, :blogs => [:index, :show]
  end

  menu :project_menu, :blogs, {:controller => 'blogs', :action => 'index', :path => nil},
    :caption => 'Blog', :after => :news, :param => :project_id

  #menu :application_menu, :blogs, { :controller => 'blogs', :action => 'index' }, :caption => 'Blogs'
  #menu :project_menu, :blogs, { :controller => 'blogs', :action => 'index' }, :caption => 'Blogs'

end

Redmine::Activity.map do |activity|
  activity.register :blogs
end

# Ability to add search providers from plugins 
# See: http://www.redmine.org/issues/3936
Redmine::Search.map do |search|
  search.register :blogs
end

class RedmineBlogsHookListener < Redmine::Hook::ViewListener
  render_on :view_layouts_base_html_head, :inline => "<%= stylesheet_link_tag 'stylesheet', :plugin => 'redmine_blogs' %>"
end 

# Routes
class << ActionController::Routing::Routes;self;end.class_eval do
  define_method :clear!, lambda {}
end

ActionController::Routing::Routes.draw do |map|
  #map.connect 'blogs/:id/*path', :controller => 'blogs', :action => 'index'
  map.connect 'projects/:project_id/blogs/:action', :controller => 'blogs'
  map.connect 'projects/:project_id/blogs/:action/:id', :controller => 'blogs', :action => 'show'
end
