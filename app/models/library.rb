class Library < ActiveRecord::Base
  attr_accessible :title, :user_id, :user
  belongs_to :user
  has_many :snippets
end
