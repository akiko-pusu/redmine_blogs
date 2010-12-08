#
# Added by Akiko
#
class AddBlogsUpdatedOn < ActiveRecord::Migration
  def self.up
        add_column(:blogs, "updated_on", :datetime) 
        #add_column(:blogs, "project_id", integer)  
       # add_index "blogs", ["project_id"], :name => "news_project_id"   
  end

  def self.down
        remove_column(:blogs, "updated_on")
        #remove_column(:blogs, "project_id")
  end
end
