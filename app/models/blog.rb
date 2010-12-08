# copied from /app/models/news.rb

class Blog < ActiveRecord::Base
  belongs_to :project
  belongs_to :author, :class_name => 'User', :foreign_key => 'author_id'
  has_many :comments, :as => :commented, :dependent => :delete_all, :order => "created_on"
  acts_as_taggable
  acts_as_attachable

  validates_presence_of :title, :description
  validates_length_of :title, :maximum => 255
  validates_length_of :summary, :maximum => 255

  acts_as_searchable :columns => ['title',"#{table_name}.description"], :include => :project
  #acts_as_searchable :columns => ['title', "#{table_name}.description"]
  acts_as_event :url => Proc.new {|o| {:controller => 'blogs', :action => 'show', :id => o.id}}
  #acts_as_activity_provider :find_options => {:include => [:author]}
  #acts_as_activity_provider :find_options => {:include => [:author]},
  #                          :author_key => :author_id

#  acts_as_activity_provider :type => 'blog',
#                              :timestamp => "#{Blog.table_name}.updated_on",
#                              :author_key => "#{Blog.table_name}.author_id",
#                              :find_options => {:include => [:author, :project]}
                              
 acts_as_activity_provider :find_options => {:include => [:project, :author]},
                            :author_key => :author_id

	
  # returns latest blogs for projects visible by user
  def self.latest(user = User.current, count = 5)
    #find(:all, :limit => count, :conditions => Project.allowed_to_condition(user, :view_news), :include => [ :author ], :order => "#{Blog.table_name}.created_on DESC")
    #find(:all, :limit => count, :conditions => Project.allowed_to_condition(user, :view_blogs), :include => [ :author, :project ], :order => "#{Blog.table_name}.created_on DESC") 

 find(:all, :limit => count, :conditions => Project.allowed_to_condition(user, :view_blogs), :include => [ :author, :project ], :order => "#{Blog.table_name}.created_on DESC")

  end
  def attachments_deletable?(user=User.current)
    true
  end
  def attachments_visible?(user=User.current)
    true
  end
  def project
    nil
  end
	def short_description()
		desc, more = description.split(/\{\{more\}\}/mi)
		desc
	end
	def has_more?()
		desc, more = description.split(/\{\{more\}\}/mi)
		more
	end
	def full_description()
		description.gsub(/\{\{more\}\}/mi,"")
	end
end
