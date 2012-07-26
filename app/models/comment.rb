class Comment < ActiveRecord::Base
  attr_accessible :comment, :snippet_id, :user_id, :user, :snippet
  belongs_to :user
  belongs_to :snippet
end
